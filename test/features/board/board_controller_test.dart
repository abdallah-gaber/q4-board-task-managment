import 'package:flutter_test/flutter_test.dart';
import 'package:q4_board/domain/entities/app_settings_entity.dart';
import 'package:q4_board/domain/enums/app_language_mode.dart';
import 'package:q4_board/domain/enums/quadrant_type.dart';
import 'package:q4_board/domain/enums/theme_preference.dart';
import 'package:q4_board/features/board/controllers/board_controller.dart';

import '../../helpers/in_memory_repositories.dart';

void main() {
  late InMemoryNoteRepository noteRepository;
  late InMemorySettingsRepository settingsRepository;
  late BoardController controller;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUp(() {
    noteRepository = InMemoryNoteRepository();
    settingsRepository = InMemorySettingsRepository(
      initial: const AppSettingsEntity(
        themePreference: ThemePreference.system,
        languageMode: AppLanguageMode.english,
        defaultShowDone: true,
        cloudSyncEnabled: true,
        liveSyncEnabled: true,
        autoSyncOnResumeEnabled: true,
      ),
    );

    controller = BoardController(
      noteRepository: noteRepository,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    controller.dispose();
    await noteRepository.dispose();
    await settingsRepository.dispose();
  });

  test('saveNote creates note in requested quadrant', () async {
    await controller.saveNote(
      noteId: null,
      quadrantType: QuadrantType.iu,
      title: 'Critical task',
      description: 'Do it now',
      dueAt: null,
      isDone: false,
    );

    await flush();

    final notes = controller.state.orderedNotesForQuadrant(QuadrantType.iu);
    expect(notes, hasLength(1));
    expect(notes.first.title, 'Critical task');
  });

  test(
    'moveNote moves task to new quadrant and undo restores original',
    () async {
      await controller.saveNote(
        noteId: null,
        quadrantType: QuadrantType.iu,
        title: 'Move me',
        description: null,
        dueAt: null,
        isDone: false,
      );
      await flush();

      final note = controller.state
          .orderedNotesForQuadrant(QuadrantType.iu)
          .first;
      final undo = await controller.moveNote(
        noteId: note.id,
        toQuadrant: QuadrantType.ninu,
        toIndex: 0,
      );

      await flush();

      expect(
        controller.state.orderedNotesForQuadrant(QuadrantType.iu),
        isEmpty,
      );
      expect(
        controller.state.orderedNotesForQuadrant(QuadrantType.ninu),
        hasLength(1),
      );

      await controller.undoMove(undo!);
      await flush();

      expect(
        controller.state.orderedNotesForQuadrant(QuadrantType.iu),
        hasLength(1),
      );
      expect(
        controller.state.orderedNotesForQuadrant(QuadrantType.ninu),
        isEmpty,
      );
    },
  );

  test('setShowDone persists preference', () async {
    await controller.setShowDone(false);

    expect(controller.state.showDone, isFalse);
    final settings = await settingsRepository.getSettings();
    expect(settings.defaultShowDone, isFalse);
  });

  test(
    'reorderInQuadrant uses visible list mapping when done notes are hidden',
    () async {
      await controller.saveNote(
        noteId: null,
        quadrantType: QuadrantType.iu,
        title: 'Hidden done',
        description: null,
        dueAt: null,
        isDone: false,
      );
      await flush();
      await controller.saveNote(
        noteId: null,
        quadrantType: QuadrantType.iu,
        title: 'Visible A',
        description: null,
        dueAt: null,
        isDone: false,
      );
      await flush();
      await controller.saveNote(
        noteId: null,
        quadrantType: QuadrantType.iu,
        title: 'Visible B',
        description: null,
        dueAt: null,
        isDone: false,
      );
      await flush();

      final initial = controller.state.orderedNotesForQuadrant(QuadrantType.iu);
      await controller.toggleDone(initial.first.id, true);
      await controller.setShowDone(false);
      await flush();

      final visible = controller.state.filteredNotesForQuadrant(
        QuadrantType.iu,
      );
      expect(visible.map((note) => note.title), <String>[
        'Visible A',
        'Visible B',
      ]);

      await controller.reorderInQuadrant(
        QuadrantType.iu,
        1,
        0,
        visible.map((note) => note.id).toList(),
      );
      await flush();

      final reordered = (await noteRepository.getAllNotes())
          .where((note) => note.quadrantType == QuadrantType.iu)
          .toList(growable: false);
      expect(reordered.map((note) => note.title), <String>[
        'Hidden done',
        'Visible B',
        'Visible A',
      ]);
    },
  );

  test(
    'moveNote inserts relative to visible list when target has hidden notes',
    () async {
      await controller.saveNote(
        noteId: null,
        quadrantType: QuadrantType.iu,
        title: 'Hidden done',
        description: null,
        dueAt: null,
        isDone: false,
      );
      await flush();
      await controller.saveNote(
        noteId: null,
        quadrantType: QuadrantType.iu,
        title: 'Visible target',
        description: null,
        dueAt: null,
        isDone: false,
      );
      await flush();
      await controller.saveNote(
        noteId: null,
        quadrantType: QuadrantType.inu,
        title: 'Move me',
        description: null,
        dueAt: null,
        isDone: false,
      );
      await flush();

      final iuNotes = controller.state.orderedNotesForQuadrant(QuadrantType.iu);
      final hiddenDoneId = iuNotes.first.id;
      await controller.toggleDone(hiddenDoneId, true);
      await controller.setShowDone(false);
      await flush();

      final moveMe = controller.state
          .orderedNotesForQuadrant(QuadrantType.inu)
          .first;
      final visibleTarget = controller.state.filteredNotesForQuadrant(
        QuadrantType.iu,
      );
      await controller.moveNote(
        noteId: moveMe.id,
        toQuadrant: QuadrantType.iu,
        toIndex: 0,
        visibleNoteIds: visibleTarget.map((note) => note.id).toList(),
      );
      await flush();

      final reordered = controller.state.orderedNotesForQuadrant(
        QuadrantType.iu,
      );
      expect(reordered.map((note) => note.title), <String>[
        'Hidden done',
        'Move me',
        'Visible target',
      ]);
    },
  );
}
