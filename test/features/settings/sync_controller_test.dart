import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:q4_board/core/firebase/firebase_bootstrap.dart';
import 'package:q4_board/domain/entities/app_settings_entity.dart';
import 'package:q4_board/domain/entities/note_entity.dart';
import 'package:q4_board/domain/enums/quadrant_type.dart';
import 'package:q4_board/domain/repositories/note_repository.dart';
import 'package:q4_board/domain/repositories/sync_repository.dart';
import 'package:q4_board/domain/repositories/settings_repository.dart';
import 'package:q4_board/domain/services/auth_service.dart';
import 'package:q4_board/features/settings/controllers/sync_controller.dart';

void main() {
  group('SyncController', () {
    test('records timeout error and clears busy state', () async {
      final notes = _FakeNoteRepository();
      final controller = SyncController(
        authService: _FakeAuthService(),
        noteRepository: notes,
        syncRepository: _NeverCompletesSyncRepository(),
        settingsRepository: _FakeSettingsRepository(),
        bootstrapState: const FirebaseBootstrapState(
          isAvailable: true,
          isConfigured: true,
        ),
        operationTimeout: const Duration(milliseconds: 10),
      );
      addTearDown(() async {
        controller.dispose();
        await notes.dispose();
      });

      expect(controller.state.isBusy, isFalse);

      await expectLater(controller.push(), throwsA(isA<TimeoutException>()));

      expect(controller.state.isBusy, isFalse);
      expect(controller.state.lastError, isNotNull);
      expect(controller.state.lastError!.isTimeout, isTrue);
      expect(controller.state.canRetryLastAction, isTrue);
    });

    test('retryLastAction reruns last failed action', () async {
      final repo = _FlakySyncRepository();
      final notes = _FakeNoteRepository();
      final controller = SyncController(
        authService: _FakeAuthService(),
        noteRepository: notes,
        syncRepository: repo,
        settingsRepository: _FakeSettingsRepository(),
        bootstrapState: const FirebaseBootstrapState(
          isAvailable: true,
          isConfigured: true,
        ),
      );
      addTearDown(() async {
        controller.dispose();
        await notes.dispose();
      });

      await expectLater(controller.push(), throwsA(isA<StateError>()));
      expect(repo.pushCalls, 1);
      expect(controller.state.canRetryLastAction, isTrue);

      await controller.retryLastAction();

      expect(repo.pushCalls, 2);
      expect(controller.state.isBusy, isFalse);
    });

    test('google sign-in is not forced to sync timeout window', () async {
      final auth = _DelayedGoogleAuthService();
      final notes = _FakeNoteRepository();
      final controller = SyncController(
        authService: auth,
        noteRepository: notes,
        syncRepository: _TrackingSyncRepository(),
        settingsRepository: _FakeSettingsRepository(),
        bootstrapState: const FirebaseBootstrapState(
          isAvailable: true,
          isConfigured: true,
        ),
        operationTimeout: const Duration(milliseconds: 10),
      );
      addTearDown(() async {
        controller.dispose();
        await notes.dispose();
        await auth.dispose();
      });

      final future = controller.signInWithGoogle();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(controller.state.isBusy, isTrue);
      expect(controller.state.lastError, isNull);

      auth.complete();
      await future;

      expect(controller.state.isBusy, isFalse);
      expect(controller.state.lastError, isNull);
    });

    test('starts live sync on sign in and stops on sign out', () async {
      final auth = _MutableAuthService();
      final repo = _TrackingSyncRepository();
      final notes = _FakeNoteRepository();
      final controller = SyncController(
        authService: auth,
        noteRepository: notes,
        syncRepository: repo,
        settingsRepository: _FakeSettingsRepository(),
        bootstrapState: const FirebaseBootstrapState(
          isAvailable: true,
          isConfigured: true,
        ),
      );
      addTearDown(() async {
        await auth.dispose();
        controller.dispose();
        await notes.dispose();
      });

      auth.emit(const AuthSession(userId: 'u1', isAuthenticated: true));
      await Future<void>.delayed(Duration.zero);

      expect(repo.startLiveSyncCalls, 1);

      auth.emit(const AuthSession(userId: null, isAuthenticated: false));
      await Future<void>.delayed(Duration.zero);

      expect(repo.stopLiveSyncCalls, greaterThanOrEqualTo(1));
    });

    test('app resume auto-pull is throttled', () async {
      final repo = _TrackingSyncRepository();
      final notes = _FakeNoteRepository();
      final controller = SyncController(
        authService: _FakeAuthService(),
        noteRepository: notes,
        syncRepository: repo,
        settingsRepository: _FakeSettingsRepository(),
        bootstrapState: const FirebaseBootstrapState(
          isAvailable: true,
          isConfigured: true,
        ),
      );
      addTearDown(() async {
        controller.dispose();
        await notes.dispose();
      });

      await controller.onAppResumed();
      await controller.onAppResumed();

      expect(repo.pullCalls, 1);
    });

    test('auto push local changes runs only when enabled', () async {
      final repo = _TrackingSyncRepository();
      final notes = _FakeNoteRepository();
      final controller = SyncController(
        authService: _FakeAuthService(),
        noteRepository: notes,
        syncRepository: repo,
        settingsRepository: _FakeSettingsRepository(
          initial: AppSettingsEntity.defaults().copyWith(
            autoPushLocalChangesEnabled: true,
            autoSyncOnResumeEnabled: false,
          ),
        ),
        bootstrapState: const FirebaseBootstrapState(
          isAvailable: true,
          isConfigured: true,
        ),
        autoPushDebounce: const Duration(milliseconds: 10),
      );
      addTearDown(() async {
        controller.dispose();
        await notes.dispose();
      });

      notes.emit([_testNote('n1')]);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(repo.pushCalls, 1);
    });

    test('auto push is suppressed after pull-applied status', () async {
      final repo = _ControllableSyncRepository();
      final notes = _FakeNoteRepository();
      final controller = SyncController(
        authService: _FakeAuthService(),
        noteRepository: notes,
        syncRepository: repo,
        settingsRepository: _FakeSettingsRepository(
          initial: AppSettingsEntity.defaults().copyWith(
            autoPushLocalChangesEnabled: true,
            autoSyncOnResumeEnabled: false,
          ),
        ),
        bootstrapState: const FirebaseBootstrapState(
          isAvailable: true,
          isConfigured: true,
        ),
        autoPushDebounce: const Duration(milliseconds: 10),
      );
      addTearDown(() async {
        controller.dispose();
        await notes.dispose();
        await repo.dispose();
      });

      repo.emitStatus(
        SyncStatusSnapshot(
          code: SyncStatusCode.success,
          lastMessage: 'pull_complete',
          lastSuccessAt: DateTime.now(),
        ),
      );
      notes.emit([_testNote('n2')]);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(repo.pushCalls, 0);
    });
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({AppSettingsEntity? initial})
    : _settings = initial ?? AppSettingsEntity.defaults();

  AppSettingsEntity _settings;
  final _controller = StreamController<AppSettingsEntity>.broadcast();

  @override
  Future<AppSettingsEntity> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettingsEntity settings) async {
    _settings = settings;
    _controller.add(settings);
  }

  @override
  Stream<AppSettingsEntity> watchSettings() =>
      Stream<AppSettingsEntity>.multi((multi) {
        multi.add(_settings);
        final sub = _controller.stream.listen(multi.add);
        multi.onCancel = sub.cancel;
      });
}

class _FakeNoteRepository implements NoteRepository {
  final List<NoteEntity> _notes = <NoteEntity>[];
  final _controller = StreamController<List<NoteEntity>>.broadcast();

  @override
  Stream<List<NoteEntity>> watchNotes() =>
      Stream<List<NoteEntity>>.multi((multi) {
        multi.add(List<NoteEntity>.unmodifiable(_notes));
        final sub = _controller.stream.listen(multi.add);
        multi.onCancel = sub.cancel;
      });

  void emit(List<NoteEntity> notes) {
    _notes
      ..clear()
      ..addAll(notes);
    _controller.add(List<NoteEntity>.unmodifiable(_notes));
  }

  @override
  Future<List<NoteEntity>> getAllNotes() async => List<NoteEntity>.of(_notes);

  @override
  Future<NoteEntity?> getById(String id) async {
    for (final note in _notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  @override
  Future<void> upsert(NoteEntity note) async {
    final index = _notes.indexWhere((element) => element.id == note.id);
    if (index == -1) {
      _notes.add(note);
    } else {
      _notes[index] = note;
    }
    _controller.add(List<NoteEntity>.unmodifiable(_notes));
  }

  @override
  Future<void> deleteById(String id) async {
    _notes.removeWhere((element) => element.id == id);
    _controller.add(List<NoteEntity>.unmodifiable(_notes));
  }

  Future<void> dispose() => _controller.close();
}

class _FakeAuthService implements AuthService {
  @override
  AuthAvailability get availability => AuthAvailability.enabled;

  @override
  AuthSession get currentSession =>
      const AuthSession(userId: 'u1', isAuthenticated: true);

  @override
  Future<void> signIn() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthSession> watchSession() =>
      Stream<AuthSession>.value(currentSession);
}

class _NeverCompletesSyncRepository implements SyncRepository {
  @override
  Future<SyncOperationResult> pull() => Completer<SyncOperationResult>().future;

  @override
  Future<SyncOperationResult> push() => Completer<SyncOperationResult>().future;

  @override
  Stream<SyncStatusSnapshot> watchStatus() =>
      Stream<SyncStatusSnapshot>.value(SyncStatusSnapshot.idle);

  @override
  Future<void> startLiveSync() async {}

  @override
  Future<void> stopLiveSync() async {}
}

class _FlakySyncRepository implements SyncRepository {
  int pushCalls = 0;

  @override
  Future<SyncOperationResult> pull() async => const SyncOperationResult(
    upserts: 0,
    deletes: 0,
    skippedConflicts: 0,
    didMutate: false,
  );

  @override
  Future<SyncOperationResult> push() async {
    pushCalls += 1;
    if (pushCalls == 1) {
      throw StateError('temporary failure');
    }
    return const SyncOperationResult(
      upserts: 1,
      deletes: 0,
      skippedConflicts: 0,
      didMutate: true,
    );
  }

  @override
  Stream<SyncStatusSnapshot> watchStatus() =>
      Stream<SyncStatusSnapshot>.value(SyncStatusSnapshot.idle);

  @override
  Future<void> startLiveSync() async {}

  @override
  Future<void> stopLiveSync() async {}
}

class _TrackingSyncRepository implements SyncRepository {
  int pushCalls = 0;
  int pullCalls = 0;
  int startLiveSyncCalls = 0;
  int stopLiveSyncCalls = 0;

  @override
  Future<SyncOperationResult> pull() async {
    pullCalls += 1;
    return const SyncOperationResult(
      upserts: 0,
      deletes: 0,
      skippedConflicts: 0,
      didMutate: false,
    );
  }

  @override
  Future<SyncOperationResult> push() async {
    pushCalls += 1;
    return const SyncOperationResult(
      upserts: 0,
      deletes: 0,
      skippedConflicts: 0,
      didMutate: false,
    );
  }

  @override
  Future<void> startLiveSync() async {
    startLiveSyncCalls += 1;
  }

  @override
  Future<void> stopLiveSync() async {
    stopLiveSyncCalls += 1;
  }

  @override
  Stream<SyncStatusSnapshot> watchStatus() =>
      Stream<SyncStatusSnapshot>.value(SyncStatusSnapshot.idle);
}

class _ControllableSyncRepository extends _TrackingSyncRepository {
  final _statusController = StreamController<SyncStatusSnapshot>.broadcast();

  void emitStatus(SyncStatusSnapshot status) {
    _statusController.add(status);
  }

  @override
  Stream<SyncStatusSnapshot> watchStatus() =>
      Stream<SyncStatusSnapshot>.multi((multi) {
        multi.add(SyncStatusSnapshot.idle);
        final sub = _statusController.stream.listen(multi.add);
        multi.onCancel = sub.cancel;
      });

  Future<void> dispose() => _statusController.close();
}

class _MutableAuthService implements AuthService {
  final _controller = StreamController<AuthSession>.broadcast();
  AuthSession _current = const AuthSession(
    userId: null,
    isAuthenticated: false,
  );

  @override
  AuthAvailability get availability => AuthAvailability.enabled;

  @override
  AuthSession get currentSession => _current;

  void emit(AuthSession session) {
    _current = session;
    _controller.add(session);
  }

  @override
  Future<void> signIn() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthSession> watchSession() => Stream<AuthSession>.multi((multi) {
    multi.add(_current);
    final sub = _controller.stream.listen(multi.add);
    multi.onCancel = sub.cancel;
  });

  Future<void> dispose() => _controller.close();
}

class _DelayedGoogleAuthService implements AuthService {
  final _googleCompleter = Completer<void>();

  @override
  AuthAvailability get availability => AuthAvailability.enabled;

  @override
  AuthSession get currentSession =>
      const AuthSession(userId: null, isAuthenticated: false);

  void complete() {
    if (!_googleCompleter.isCompleted) {
      _googleCompleter.complete();
    }
  }

  @override
  Future<void> signIn() async {}

  @override
  Future<void> signInWithGoogle() => _googleCompleter.future;

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthSession> watchSession() =>
      Stream<AuthSession>.value(currentSession);

  Future<void> dispose() async {
    complete();
  }
}

NoteEntity _testNote(String id) {
  final now = DateTime(2026, 1, 1, 12);
  return NoteEntity(
    id: id,
    quadrantType: QuadrantType.iu,
    title: 'T$id',
    description: null,
    dueAt: null,
    isDone: false,
    orderIndex: 1,
    createdAt: now,
    updatedAt: now,
  );
}
