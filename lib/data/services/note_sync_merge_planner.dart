import '../../domain/entities/note_entity.dart';

class SyncMergePlan {
  const SyncMergePlan({
    required this.upserts,
    required this.deletes,
    required this.skippedConflicts,
    required this.skippedConflictNoteIds,
    this.skippedEmptyRemoteDelete = false,
    this.skippedMissingRemoteDelete = false,
  });

  final List<NoteEntity> upserts;
  final List<String> deletes;
  final int skippedConflicts;
  final List<String> skippedConflictNoteIds;
  final bool skippedEmptyRemoteDelete;
  final bool skippedMissingRemoteDelete;
}

class NoteSyncMergePlanner {
  const NoteSyncMergePlanner._();

  static SyncMergePlan buildPushPlan({
    required List<NoteEntity> localNotes,
    required Map<String, NoteEntity> remoteNotes,
  }) {
    final upserts = <NoteEntity>[];
    var skippedConflicts = 0;
    final skippedConflictNoteIds = <String>[];

    final localIds = <String>{};
    for (final local in localNotes) {
      localIds.add(local.id);
      final remote = remoteNotes[local.id];
      if (remote == null || !remote.updatedAt.isAfter(local.updatedAt)) {
        upserts.add(local);
      } else {
        skippedConflicts += 1;
        skippedConflictNoteIds.add(local.id);
      }
    }

    final deletes = remoteNotes.keys
        .where((id) => !localIds.contains(id))
        .toList(growable: false);

    return SyncMergePlan(
      upserts: upserts,
      deletes: deletes,
      skippedConflicts: skippedConflicts,
      skippedConflictNoteIds: skippedConflictNoteIds,
    );
  }

  static SyncMergePlan buildPullPlan({
    required List<NoteEntity> localNotes,
    required Map<String, NoteEntity> remoteNotes,
  }) {
    final localById = {for (final note in localNotes) note.id: note};
    final upserts = <NoteEntity>[];
    var skippedConflicts = 0;
    final skippedConflictNoteIds = <String>[];

    for (final remote in remoteNotes.values) {
      final local = localById[remote.id];
      if (local == null || !local.updatedAt.isAfter(remote.updatedAt)) {
        upserts.add(remote);
      } else {
        skippedConflicts += 1;
        skippedConflictNoteIds.add(remote.id);
      }
    }

    final localIds = localById.keys.toSet();
    final remoteIds = remoteNotes.keys.toSet();

    // Safety: avoid deleting local notes when cloud is empty. This protects
    // first-time sign-in or an uninitialized remote workspace from wiping data.
    if (remoteIds.isEmpty && localIds.isNotEmpty) {
      return SyncMergePlan(
        upserts: upserts,
        deletes: const <String>[],
        skippedConflicts: skippedConflicts,
        skippedConflictNoteIds: skippedConflictNoteIds,
        skippedEmptyRemoteDelete: true,
        skippedMissingRemoteDelete: localIds.isNotEmpty,
      );
    }

    // Safety: pull is non-destructive by default. Remote-missing IDs are kept
    // locally to avoid accidental local data loss when cloud writes fail or
    // when switching accounts.
    final missingRemoteLocalIds = localIds
        .where((id) => !remoteIds.contains(id))
        .toList(growable: false);

    return SyncMergePlan(
      upserts: upserts,
      deletes: const <String>[],
      skippedConflicts: skippedConflicts,
      skippedConflictNoteIds: skippedConflictNoteIds,
      skippedMissingRemoteDelete: missingRemoteLocalIds.isNotEmpty,
    );
  }
}
