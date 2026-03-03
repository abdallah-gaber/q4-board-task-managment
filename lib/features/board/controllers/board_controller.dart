import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/order_index.dart';
import '../../../domain/entities/note_entity.dart';
import '../../../domain/enums/quadrant_type.dart';
import '../../../domain/repositories/note_repository.dart';
import '../../../domain/repositories/settings_repository.dart';

final boardControllerProvider =
    StateNotifierProvider<BoardController, BoardState>(
      (ref) => BoardController(
        noteRepository: ref.watch(noteRepositoryProvider),
        settingsRepository: ref.watch(settingsRepositoryProvider),
      ),
    );

class BoardState {
  const BoardState({
    required this.notes,
    required this.query,
    required this.showDone,
  });

  final List<NoteEntity> notes;
  final String query;
  final bool showDone;

  factory BoardState.initial() =>
      const BoardState(notes: <NoteEntity>[], query: '', showDone: true);

  BoardState copyWith({
    List<NoteEntity>? notes,
    String? query,
    bool? showDone,
  }) {
    return BoardState(
      notes: notes ?? this.notes,
      query: query ?? this.query,
      showDone: showDone ?? this.showDone,
    );
  }

  List<NoteEntity> orderedNotesForQuadrant(QuadrantType quadrant) {
    final list = notes
        .where((n) => n.quadrantType == quadrant)
        .toList(growable: false);
    list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return list;
  }

  List<NoteEntity> filteredNotesForQuadrant(QuadrantType quadrant) {
    final normalizedQuery = query.trim().toLowerCase();
    return orderedNotesForQuadrant(quadrant)
        .where((note) {
          if (!showDone && note.isDone) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          final inTitle = note.title.toLowerCase().contains(normalizedQuery);
          final inDescription =
              note.description?.toLowerCase().contains(normalizedQuery) ??
              false;
          return inTitle || inDescription;
        })
        .toList(growable: false);
  }
}

class MoveUndoData {
  const MoveUndoData({required this.originalNote});

  final NoteEntity originalNote;
}

class BoardController extends StateNotifier<BoardState> {
  BoardController({
    required NoteRepository noteRepository,
    required SettingsRepository settingsRepository,
  }) : _noteRepository = noteRepository,
       _settingsRepository = settingsRepository,
       super(BoardState.initial()) {
    _notesSub = _noteRepository.watchNotes().listen((notes) {
      state = state.copyWith(notes: notes);
    });
    _settingsSub = _settingsRepository.watchSettings().listen((settings) {
      state = state.copyWith(showDone: settings.defaultShowDone);
    });
  }

  final NoteRepository _noteRepository;
  final SettingsRepository _settingsRepository;
  final Uuid _uuid = const Uuid();

  late final StreamSubscription<List<NoteEntity>> _notesSub;
  late final StreamSubscription _settingsSub;

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  Future<void> setShowDone(bool value) async {
    state = state.copyWith(showDone: value);
    final settings = await _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(
      settings.copyWith(defaultShowDone: value),
    );
  }

  Future<void> saveNote({
    required String? noteId,
    required QuadrantType quadrantType,
    required String title,
    required String? description,
    required DateTime? dueAt,
    required bool isDone,
  }) async {
    final now = DateTime.now();
    final trimmedTitle = title.trim();
    final normalizedDescription =
        (description == null || description.trim().isEmpty)
        ? null
        : description.trim();

    final existing = noteId == null ? null : _findNote(noteId);

    if (existing == null) {
      final note = NoteEntity(
        id: _uuid.v4(),
        quadrantType: quadrantType,
        title: trimmedTitle,
        description: normalizedDescription,
        dueAt: dueAt,
        isDone: isDone,
        orderIndex: _nextOrderIndex(quadrantType),
        createdAt: now,
        updatedAt: now,
      );
      await _noteRepository.upsert(note);
      return;
    }

    final movedQuadrant = existing.quadrantType != quadrantType;
    final updated = existing.copyWith(
      quadrantType: quadrantType,
      title: trimmedTitle,
      description: normalizedDescription,
      dueAt: dueAt,
      clearDueAt: dueAt == null,
      isDone: isDone,
      orderIndex: movedQuadrant
          ? _nextOrderIndex(quadrantType)
          : existing.orderIndex,
      updatedAt: now,
    );

    await _noteRepository.upsert(updated);
    if (movedQuadrant) {
      await _normalizeIfNeeded(existing.quadrantType);
      await _normalizeIfNeeded(quadrantType);
    }
  }

  Future<void> toggleDone(String noteId, bool isDone) async {
    final note = _findNote(noteId);
    if (note == null) {
      return;
    }
    await _noteRepository.upsert(
      note.copyWith(isDone: isDone, updatedAt: DateTime.now()),
    );
  }

  Future<NoteEntity?> deleteNote(String noteId) async {
    final note = _findNote(noteId);
    if (note == null) {
      return null;
    }
    await _noteRepository.deleteById(noteId);
    await _normalizeIfNeeded(note.quadrantType);
    return note;
  }

  Future<void> restoreDeletedNote(NoteEntity note) async {
    await _noteRepository.upsert(note.copyWith(updatedAt: DateTime.now()));
    await _normalizeIfNeeded(note.quadrantType);
  }

  Future<MoveUndoData?> moveNote({
    required String noteId,
    required QuadrantType toQuadrant,
    required int toIndex,
    List<String>? visibleNoteIds,
  }) async {
    final current = _findNote(noteId);
    if (current == null) {
      return null;
    }

    final target = state
        .orderedNotesForQuadrant(toQuadrant)
        .where((n) => n.id != current.id)
        .toList(growable: false);

    final clampedIndex = _resolveTargetIndex(
      targetNotes: target,
      toIndex: toIndex,
      movingNoteId: current.id,
      visibleNoteIds: visibleNoteIds,
    );
    final updated = current.copyWith(
      quadrantType: toQuadrant,
      orderIndex: OrderIndex.forInsert(target, clampedIndex),
      updatedAt: DateTime.now(),
    );

    await _noteRepository.upsert(updated);
    await _normalizeIfNeeded(toQuadrant);
    if (current.quadrantType != toQuadrant) {
      await _normalizeIfNeeded(current.quadrantType);
    }

    return MoveUndoData(originalNote: current);
  }

  Future<void> undoMove(MoveUndoData moveUndo) async {
    await _noteRepository.upsert(
      moveUndo.originalNote.copyWith(updatedAt: DateTime.now()),
    );
    await _normalizeIfNeeded(moveUndo.originalNote.quadrantType);
  }

  Future<void> reorderInQuadrant(
    QuadrantType quadrant,
    int oldIndex,
    int newIndex,
    List<String>? visibleNoteIds,
  ) async {
    final notes = state.orderedNotesForQuadrant(quadrant);
    if (notes.isEmpty) {
      return;
    }

    final notesById = {for (final note in notes) note.id: note};
    final visibleIds = (visibleNoteIds ?? notes.map((note) => note.id))
        .where(notesById.containsKey)
        .toList(growable: true);

    if (visibleIds.isEmpty || oldIndex < 0 || oldIndex >= visibleIds.length) {
      return;
    }

    final noteId = visibleIds.removeAt(oldIndex);
    final adjustedNew = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final clampedNew = adjustedNew.clamp(0, visibleIds.length);
    await moveNote(
      noteId: noteId,
      toQuadrant: quadrant,
      toIndex: clampedNew,
      visibleNoteIds: visibleIds,
    );
  }

  NoteEntity? _findNote(String id) {
    for (final note in state.notes) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }

  double _nextOrderIndex(QuadrantType quadrant) {
    final notes = state.orderedNotesForQuadrant(quadrant);
    if (notes.isEmpty) {
      return 0;
    }
    return notes.last.orderIndex + 1024;
  }

  int _resolveTargetIndex({
    required List<NoteEntity> targetNotes,
    required int toIndex,
    required String movingNoteId,
    List<String>? visibleNoteIds,
  }) {
    if (visibleNoteIds == null) {
      return toIndex.clamp(0, targetNotes.length);
    }

    final targetIndexById = <String, int>{
      for (var i = 0; i < targetNotes.length; i++) targetNotes[i].id: i,
    };
    final visibleIds = visibleNoteIds
        .where((id) => id != movingNoteId && targetIndexById.containsKey(id))
        .toList(growable: false);

    if (visibleIds.isEmpty) {
      return targetNotes.length;
    }

    final clampedVisibleIndex = toIndex.clamp(0, visibleIds.length);
    if (clampedVisibleIndex == 0) {
      return targetIndexById[visibleIds.first]!;
    }
    if (clampedVisibleIndex >= visibleIds.length) {
      return targetIndexById[visibleIds.last]! + 1;
    }
    return targetIndexById[visibleIds[clampedVisibleIndex]]!;
  }

  Future<void> _normalizeIfNeeded(QuadrantType quadrant) async {
    final notes = state.orderedNotesForQuadrant(quadrant);
    if (notes.length < 2) {
      return;
    }

    var needNormalize = false;
    for (var i = 1; i < notes.length; i++) {
      if ((notes[i].orderIndex - notes[i - 1].orderIndex).abs() < 0.000001) {
        needNormalize = true;
        break;
      }
    }
    if (!needNormalize) {
      return;
    }

    for (var i = 0; i < notes.length; i++) {
      final normalizedOrder = i * 1024.0;
      if (notes[i].orderIndex == normalizedOrder) {
        continue;
      }
      await _noteRepository.upsert(
        notes[i].copyWith(
          orderIndex: normalizedOrder,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesSub.cancel();
    _settingsSub.cancel();
    super.dispose();
  }
}
