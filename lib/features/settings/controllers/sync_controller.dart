import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/providers/app_providers.dart';
import '../../../domain/entities/app_settings_entity.dart';
import '../../../domain/entities/note_entity.dart';
import '../../../domain/repositories/note_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/sync_repository.dart';
import '../../../domain/services/auth_service.dart';

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncControllerState>(
      (ref) => SyncController(
        authService: ref.watch(authServiceProvider),
        noteRepository: ref.watch(noteRepositoryProvider),
        syncRepository: ref.watch(syncRepositoryProvider),
        settingsRepository: ref.watch(settingsRepositoryProvider),
        bootstrapState: ref.watch(firebaseBootstrapStateProvider),
      ),
    );

class SyncControllerState {
  const SyncControllerState({
    required this.bootstrapState,
    required this.session,
    required this.syncStatus,
    required this.isBusy,
    required this.lastAction,
    required this.recentActivities,
    this.lastError,
  });

  final FirebaseBootstrapState bootstrapState;
  final AuthSession session;
  final SyncStatusSnapshot syncStatus;
  final bool isBusy;
  final SyncActionType? lastAction;
  final List<SyncActivityEntry> recentActivities;
  final SyncActionError? lastError;

  factory SyncControllerState.initial(FirebaseBootstrapState bootstrapState) =>
      SyncControllerState(
        bootstrapState: bootstrapState,
        session: const AuthSession(userId: null, isAuthenticated: false),
        syncStatus: bootstrapState.isAvailable
            ? SyncStatusSnapshot.idle
            : SyncStatusSnapshot.unavailable,
        isBusy: false,
        lastAction: null,
        recentActivities: const <SyncActivityEntry>[],
      );

  SyncControllerState copyWith({
    FirebaseBootstrapState? bootstrapState,
    AuthSession? session,
    SyncStatusSnapshot? syncStatus,
    bool? isBusy,
    SyncActionType? lastAction,
    bool clearLastAction = false,
    List<SyncActivityEntry>? recentActivities,
    SyncActionError? lastError,
    bool clearLastError = false,
  }) {
    return SyncControllerState(
      bootstrapState: bootstrapState ?? this.bootstrapState,
      session: session ?? this.session,
      syncStatus: syncStatus ?? this.syncStatus,
      isBusy: isBusy ?? this.isBusy,
      lastAction: clearLastAction ? null : (lastAction ?? this.lastAction),
      recentActivities: recentActivities ?? this.recentActivities,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  bool get canRetryLastAction => !isBusy && (lastError?.isRetryable ?? false);
}

enum SyncActionType {
  signIn,
  signInGoogle,
  signInEmail,
  registerEmail,
  signOut,
  push,
  pull,
}

enum SyncConflictResolution { localKept, remoteKept }

enum SyncActivityKind { push, autoPush, pull, autoPull, live }

class SyncActivityEntry {
  const SyncActivityEntry({
    required this.kind,
    required this.at,
    required this.isSuccess,
    required this.summaryKey,
    required this.upserts,
    required this.deletes,
    required this.skippedConflicts,
    required this.conflictNoteIds,
    this.conflictResolution,
    this.errorCode,
  });

  final SyncActivityKind kind;
  final DateTime at;
  final bool isSuccess;
  final String summaryKey;
  final int upserts;
  final int deletes;
  final int skippedConflicts;
  final List<String> conflictNoteIds;
  final SyncConflictResolution? conflictResolution;
  final String? errorCode;
}

class SyncActionError {
  const SyncActionError({
    required this.action,
    required this.rawError,
    required this.isTimeout,
    required this.isRetryable,
  });

  final SyncActionType action;
  final Object rawError;
  final bool isTimeout;
  final bool isRetryable;
}

class SyncController extends StateNotifier<SyncControllerState> {
  SyncController({
    required AuthService authService,
    required NoteRepository noteRepository,
    required SyncRepository syncRepository,
    required SettingsRepository settingsRepository,
    required FirebaseBootstrapState bootstrapState,
    Duration operationTimeout = const Duration(seconds: 20),
    Duration autoPushDebounce = const Duration(seconds: 2),
  }) : _authService = authService,
       _noteRepository = noteRepository,
       _syncRepository = syncRepository,
       _settingsRepository = settingsRepository,
       _operationTimeout = operationTimeout,
       _autoPushDebounce = autoPushDebounce,
       super(SyncControllerState.initial(bootstrapState)) {
    _settingsSub = _settingsRepository.watchSettings().listen((settings) {
      _settings = settings;
      unawaited(_applySyncPreferenceChanges());
    });
    _authSub = _authService.watchSession().listen((session) {
      state = state.copyWith(session: session);
      unawaited(_handleSessionChange(session));
    });
    _syncSub = _syncRepository.watchStatus().listen((syncStatus) {
      state = state.copyWith(syncStatus: syncStatus);
      _trackRemoteApplyForAutoPush(syncStatus);
      _recordLiveActivityIfNeeded(syncStatus);
      unawaited(_persistSyncMetadataIfNeeded(syncStatus));
    });
    _notesSub = _noteRepository.watchNotes().listen(_handleLocalNotesChanged);
  }

  final AuthService _authService;
  final NoteRepository _noteRepository;
  final SyncRepository _syncRepository;
  final SettingsRepository _settingsRepository;
  final Duration _operationTimeout;
  final Duration _autoPushDebounce;
  AppSettingsEntity _settings = AppSettingsEntity.defaults();
  DateTime? _lastAutoPullAt;
  DateTime? _suppressAutoPushUntil;
  bool _liveSyncRunning = false;
  bool _applyingPreferences = false;
  bool _pendingPreferences = false;
  SyncStatusSnapshot? _lastPersistedSuccessStatus;
  bool _persistingSyncMetadata = false;
  bool _pendingPersistSyncMetadata = false;
  bool _seenInitialNotesSnapshot = false;
  String? _lastNotesFingerprint;
  Timer? _autoPushDebounceTimer;
  late final StreamSubscription<AppSettingsEntity> _settingsSub;
  late final StreamSubscription<AuthSession> _authSub;
  late final StreamSubscription<SyncStatusSnapshot> _syncSub;
  late final StreamSubscription<List<NoteEntity>> _notesSub;

  Future<void> signIn() => _runBusy(SyncActionType.signIn, _authService.signIn);

  Future<void> signInWithGoogle() =>
      _runBusy(SyncActionType.signInGoogle, _authService.signInWithGoogle);

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) => _runBusy(
    SyncActionType.signInEmail,
    () =>
        _authService.signInWithEmailPassword(email: email, password: password),
  );

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) => _runBusy(
    SyncActionType.registerEmail,
    () => _authService.registerWithEmailPassword(
      email: email,
      password: password,
    ),
  );

  Future<void> signOut() =>
      _runBusy(SyncActionType.signOut, _authService.signOut);

  Future<SyncOperationResult> push() async {
    try {
      final result = await _runBusy(SyncActionType.push, _syncRepository.push);
      _recordActivityFromResult(
        kind: SyncActivityKind.push,
        result: result,
        summaryKey: 'push_complete',
        conflictResolution: SyncConflictResolution.remoteKept,
      );
      return result;
    } catch (error) {
      _recordFailedActivity(kind: SyncActivityKind.push, error: error);
      rethrow;
    }
  }

  Future<SyncOperationResult> pull() async {
    _suppressAutoPushUntil = DateTime.now().add(const Duration(seconds: 3));
    try {
      final result = await _runBusy(SyncActionType.pull, _syncRepository.pull);
      _recordActivityFromResult(
        kind: SyncActivityKind.pull,
        result: result,
        summaryKey: 'pull_complete',
        conflictResolution: SyncConflictResolution.localKept,
      );
      return result;
    } catch (error) {
      _recordFailedActivity(kind: SyncActivityKind.pull, error: error);
      rethrow;
    }
  }

  Future<void> retryLastAction() async {
    switch (state.lastAction) {
      case SyncActionType.signIn:
        return signIn();
      case SyncActionType.signInGoogle:
        return signInWithGoogle();
      case SyncActionType.signInEmail:
      case SyncActionType.registerEmail:
        return;
      case SyncActionType.signOut:
        return signOut();
      case SyncActionType.push:
        await push();
        return;
      case SyncActionType.pull:
        await pull();
        return;
      case null:
        return;
    }
  }

  Future<void> onAppResumed() async {
    if (!state.bootstrapState.isAvailable ||
        !state.session.isAuthenticated ||
        state.isBusy ||
        !_settings.cloudSyncEnabled ||
        !_settings.autoSyncOnResumeEnabled) {
      return;
    }
    final now = DateTime.now();
    if (_lastAutoPullAt != null &&
        now.difference(_lastAutoPullAt!) < const Duration(seconds: 20)) {
      return;
    }
    _lastAutoPullAt = now;
    _suppressAutoPushUntil = now.add(const Duration(seconds: 3));
    try {
      final result = await _runBusy(SyncActionType.pull, _syncRepository.pull);
      _recordActivityFromResult(
        kind: SyncActivityKind.autoPull,
        result: result,
        summaryKey: 'pull_complete',
        conflictResolution: SyncConflictResolution.localKept,
      );
    } catch (error) {
      _recordFailedActivity(kind: SyncActivityKind.autoPull, error: error);
      // App-resume auto sync failures are surfaced in controller status/UI.
    }
  }

  Future<R> _runBusy<R>(
    SyncActionType actionType,
    Future<R> Function() action,
  ) async {
    state = state.copyWith(
      isBusy: true,
      lastAction: actionType,
      clearLastError: true,
    );
    try {
      return await action().timeout(_operationTimeout);
    } on TimeoutException catch (error) {
      state = state.copyWith(
        lastError: SyncActionError(
          action: actionType,
          rawError: error,
          isTimeout: true,
          isRetryable: true,
        ),
      );
      rethrow;
    } catch (error) {
      state = state.copyWith(
        lastError: SyncActionError(
          action: actionType,
          rawError: error,
          isTimeout: false,
          isRetryable:
              actionType != SyncActionType.signOut &&
              actionType != SyncActionType.signInEmail &&
              actionType != SyncActionType.registerEmail,
        ),
      );
      rethrow;
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<void> _handleSessionChange(AuthSession session) async {
    if (!state.bootstrapState.isAvailable) {
      return;
    }
    if (!session.isAuthenticated) {
      await _stopLiveSyncIfNeeded();
      _lastAutoPullAt = null;
      _cancelAutoPushDebounce();
      return;
    }
    try {
      await _applySyncPreferenceChanges();
      if (_settings.cloudSyncEnabled) {
        await onAppResumed();
      }
    } catch (error) {
      state = state.copyWith(
        lastError: SyncActionError(
          action: SyncActionType.pull,
          rawError: error,
          isTimeout: false,
          isRetryable: true,
        ),
      );
    }
  }

  Future<void> _applySyncPreferenceChanges() async {
    if (_applyingPreferences) {
      _pendingPreferences = true;
      return;
    }
    _applyingPreferences = true;
    try {
      do {
        _pendingPreferences = false;
        final shouldRunLiveSync =
            state.bootstrapState.isAvailable &&
            state.session.isAuthenticated &&
            _settings.cloudSyncEnabled &&
            _settings.liveSyncEnabled;
        if (shouldRunLiveSync) {
          await _startLiveSyncIfNeeded();
        } else {
          await _stopLiveSyncIfNeeded();
        }
        if (!_canAutoPushLocalChanges) {
          _cancelAutoPushDebounce();
        }
      } while (_pendingPreferences);
    } finally {
      _applyingPreferences = false;
    }
  }

  Future<void> _startLiveSyncIfNeeded() async {
    if (_liveSyncRunning) {
      return;
    }
    await _syncRepository.startLiveSync();
    _liveSyncRunning = true;
  }

  Future<void> _stopLiveSyncIfNeeded() async {
    if (!_liveSyncRunning) {
      return;
    }
    await _syncRepository.stopLiveSync();
    _liveSyncRunning = false;
  }

  Future<void> _persistSyncMetadataIfNeeded(
    SyncStatusSnapshot syncStatus,
  ) async {
    final isSuccessLike =
        syncStatus.code == SyncStatusCode.success ||
        syncStatus.code == SyncStatusCode.liveListening;
    if (!isSuccessLike || syncStatus.lastSuccessAt == null) {
      return;
    }
    final messageKey = syncStatus.lastMessage;
    if (messageKey == 'live_sync_active' || messageKey == 'live_sync_stopped') {
      return;
    }

    final sameAsLast =
        _lastPersistedSuccessStatus?.code == syncStatus.code &&
        _lastPersistedSuccessStatus?.lastMessage == messageKey &&
        _lastPersistedSuccessStatus?.lastSuccessAt == syncStatus.lastSuccessAt;
    if (sameAsLast) {
      return;
    }

    if (_persistingSyncMetadata) {
      _pendingPersistSyncMetadata = true;
      return;
    }

    _persistingSyncMetadata = true;
    try {
      do {
        _pendingPersistSyncMetadata = false;
        final latestSettings = await _settingsRepository.getSettings();
        await _settingsRepository.saveSettings(
          latestSettings.copyWith(
            lastSyncAt: syncStatus.lastSuccessAt,
            lastSyncStatusKey: messageKey ?? syncStatus.code.name,
          ),
        );
        _lastPersistedSuccessStatus = syncStatus;
      } while (_pendingPersistSyncMetadata);
    } finally {
      _persistingSyncMetadata = false;
    }
  }

  void _recordActivityFromResult({
    required SyncActivityKind kind,
    required SyncOperationResult result,
    required String summaryKey,
    required SyncConflictResolution conflictResolution,
  }) {
    final effectiveSummaryKey = result.skippedConflicts > 0
        ? (kind == SyncActivityKind.push
              ? 'push_conflicts_skipped'
              : 'pull_conflicts_skipped')
        : summaryKey;
    _prependActivity(
      SyncActivityEntry(
        kind: kind,
        at: DateTime.now(),
        isSuccess: true,
        summaryKey: effectiveSummaryKey,
        upserts: result.upserts,
        deletes: result.deletes,
        skippedConflicts: result.skippedConflicts,
        conflictNoteIds: result.conflictNoteIds,
        conflictResolution: result.skippedConflicts > 0
            ? conflictResolution
            : null,
      ),
    );
  }

  void _recordFailedActivity({
    required SyncActivityKind kind,
    required Object error,
  }) {
    _prependActivity(
      SyncActivityEntry(
        kind: kind,
        at: DateTime.now(),
        isSuccess: false,
        summaryKey: 'sync_error',
        upserts: 0,
        deletes: 0,
        skippedConflicts: 0,
        conflictNoteIds: const <String>[],
        errorCode: _errorCode(error),
      ),
    );
  }

  void _recordLiveActivityIfNeeded(SyncStatusSnapshot status) {
    if (status.code != SyncStatusCode.liveListening) {
      return;
    }
    final key = status.lastMessage;
    if (key != 'live_sync_applied' && key != 'live_sync_applied_conflicts') {
      return;
    }
    final nonNullKey = key!;
    final latest = state.recentActivities.isNotEmpty
        ? state.recentActivities.first
        : null;
    if (latest != null &&
        latest.kind == SyncActivityKind.live &&
        latest.summaryKey == key &&
        status.lastSuccessAt != null &&
        latest.at.difference(status.lastSuccessAt!).inMilliseconds == 0) {
      return;
    }
    _prependActivity(
      SyncActivityEntry(
        kind: SyncActivityKind.live,
        at: status.lastSuccessAt ?? DateTime.now(),
        isSuccess: true,
        summaryKey: nonNullKey,
        upserts: 0,
        deletes: 0,
        skippedConflicts: 0,
        conflictNoteIds: const <String>[],
        conflictResolution: nonNullKey == 'live_sync_applied_conflicts'
            ? SyncConflictResolution.localKept
            : null,
      ),
    );
  }

  void _prependActivity(SyncActivityEntry entry) {
    final updated = <SyncActivityEntry>[entry, ...state.recentActivities];
    if (updated.length > 12) {
      updated.removeRange(12, updated.length);
    }
    state = state.copyWith(recentActivities: updated);
  }

  String? _errorCode(Object error) {
    final text = error.toString();
    final match = RegExp(r'\[([a-z_]+/[a-z\-]+)\]').firstMatch(text);
    return match?.group(1);
  }

  bool get _canAutoPushLocalChanges =>
      state.bootstrapState.isAvailable &&
      state.session.isAuthenticated &&
      _settings.cloudSyncEnabled &&
      _settings.autoPushLocalChangesEnabled;

  void _handleLocalNotesChanged(List<NoteEntity> notes) {
    final fingerprint = _notesFingerprint(notes);
    if (!_seenInitialNotesSnapshot) {
      _seenInitialNotesSnapshot = true;
      _lastNotesFingerprint = fingerprint;
      return;
    }
    if (fingerprint == _lastNotesFingerprint) {
      return;
    }
    _lastNotesFingerprint = fingerprint;

    if (!_canAutoPushLocalChanges) {
      return;
    }
    final now = DateTime.now();
    if (_suppressAutoPushUntil != null &&
        now.isBefore(_suppressAutoPushUntil!)) {
      return;
    }
    _scheduleAutoPush();
  }

  void _scheduleAutoPush() {
    _autoPushDebounceTimer?.cancel();
    _autoPushDebounceTimer = Timer(_autoPushDebounce, () {
      unawaited(_runAutoPushIfEligible());
    });
  }

  void _cancelAutoPushDebounce() {
    _autoPushDebounceTimer?.cancel();
    _autoPushDebounceTimer = null;
  }

  Future<void> _runAutoPushIfEligible() async {
    if (!_canAutoPushLocalChanges) {
      return;
    }
    final now = DateTime.now();
    if (_suppressAutoPushUntil != null &&
        now.isBefore(_suppressAutoPushUntil!)) {
      return;
    }
    if (state.isBusy) {
      _scheduleAutoPush();
      return;
    }
    try {
      final result = await _runBusy(SyncActionType.push, _syncRepository.push);
      _recordActivityFromResult(
        kind: SyncActivityKind.autoPush,
        result: result,
        summaryKey: 'push_complete',
        conflictResolution: SyncConflictResolution.remoteKept,
      );
    } catch (error) {
      _recordFailedActivity(kind: SyncActivityKind.autoPush, error: error);
      // Errors surface in existing sync status and retry UI.
    }
  }

  void _trackRemoteApplyForAutoPush(SyncStatusSnapshot status) {
    final key = status.lastMessage;
    final remoteApplied =
        (status.code == SyncStatusCode.success &&
            (key == 'pull_complete' ||
                key == 'pull_conflicts_skipped' ||
                key == 'pull_remote_empty_local_kept')) ||
        (status.code == SyncStatusCode.liveListening &&
            (key == 'live_sync_applied' ||
                key == 'live_sync_applied_conflicts' ||
                key == 'live_sync_remote_empty_local_kept'));
    if (!remoteApplied) {
      return;
    }
    _suppressAutoPushUntil = DateTime.now().add(const Duration(seconds: 3));
  }

  String _notesFingerprint(List<NoteEntity> notes) {
    final buffer = StringBuffer();
    for (final note in notes) {
      buffer
        ..write(note.id)
        ..write('|')
        ..write(note.updatedAt.microsecondsSinceEpoch)
        ..write('|')
        ..write(note.quadrantType.index)
        ..write('|')
        ..write(note.orderIndex)
        ..write(';');
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    unawaited(_syncRepository.stopLiveSync());
    _cancelAutoPushDebounce();
    _notesSub.cancel();
    _settingsSub.cancel();
    _authSub.cancel();
    _syncSub.cancel();
    super.dispose();
  }
}
