import 'package:flutter_test/flutter_test.dart';
import 'package:q4_board/data/services/note_sync_merge_planner.dart';
import 'package:q4_board/domain/entities/note_entity.dart';
import 'package:q4_board/domain/enums/quadrant_type.dart';

void main() {
  group('NoteSyncMergePlanner', () {
    test('push prefers newer remote note and skips local conflict', () {
      final olderLocal = _note(id: 'a', updatedAt: DateTime(2026, 1, 1, 10));
      final newerRemote = _note(id: 'a', updatedAt: DateTime(2026, 1, 1, 11));
      final localOnly = _note(id: 'b', updatedAt: DateTime(2026, 1, 1, 12));

      final plan = NoteSyncMergePlanner.buildPushPlan(
        localNotes: [olderLocal, localOnly],
        remoteNotes: {
          newerRemote.id: newerRemote,
          'c': _note(id: 'c', updatedAt: DateTime(2026, 1, 1, 9)),
        },
      );

      expect(plan.upserts.map((e) => e.id), ['b']);
      expect(plan.deletes, ['c']);
      expect(plan.skippedConflicts, 1);
    });

    test('pull applies newer remote and keeps missing local notes', () {
      final localA = _note(id: 'a', updatedAt: DateTime(2026, 1, 1, 10));
      final localB = _note(id: 'b', updatedAt: DateTime(2026, 1, 1, 10));
      final remoteANewer = _note(id: 'a', updatedAt: DateTime(2026, 1, 1, 11));
      final remoteC = _note(id: 'c', updatedAt: DateTime(2026, 1, 1, 8));

      final plan = NoteSyncMergePlanner.buildPullPlan(
        localNotes: [localA, localB],
        remoteNotes: {remoteANewer.id: remoteANewer, remoteC.id: remoteC},
      );

      expect(plan.upserts.map((e) => e.id), ['a', 'c']);
      expect(plan.deletes, isEmpty);
      expect(plan.skippedConflicts, 0);
      expect(plan.skippedEmptyRemoteDelete, isFalse);
      expect(plan.skippedMissingRemoteDelete, isTrue);
    });

    test('pull does not wipe local notes when remote is empty', () {
      final localNotes = [
        _note(id: 'a', updatedAt: DateTime(2026, 1, 1, 10)),
        _note(id: 'b', updatedAt: DateTime(2026, 1, 1, 11)),
      ];

      final plan = NoteSyncMergePlanner.buildPullPlan(
        localNotes: localNotes,
        remoteNotes: const {},
      );

      expect(plan.upserts, isEmpty);
      expect(plan.deletes, isEmpty);
      expect(plan.skippedEmptyRemoteDelete, isTrue);
      expect(plan.skippedMissingRemoteDelete, isTrue);
    });
  });
}

NoteEntity _note({required String id, required DateTime updatedAt}) {
  return NoteEntity(
    id: id,
    quadrantType: QuadrantType.iu,
    title: 'Note $id',
    description: null,
    dueAt: null,
    isDone: false,
    orderIndex: 0,
    createdAt: updatedAt.subtract(const Duration(minutes: 1)),
    updatedAt: updatedAt,
  );
}
