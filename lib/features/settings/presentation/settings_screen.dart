import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q4_board/l10n/app_localizations.dart';

import '../../../core/design/app_radii.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../domain/entities/app_settings_entity.dart';
import '../../../domain/enums/app_language_mode.dart';
import '../../../domain/enums/theme_preference.dart';
import '../../../domain/repositories/sync_repository.dart';
import '../../../domain/services/auth_service.dart';
import '../controllers/settings_controller.dart';
import '../controllers/sync_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(settingsControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider);
    final syncState = ref.watch(syncControllerProvider);
    final syncController = ref.read(syncControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionCard(
            title: l10n.themeMode,
            child: SegmentedButton<ThemePreference>(
              segments: [
                ButtonSegment(
                  value: ThemePreference.system,
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  label: Text(l10n.themeDark),
                ),
              ],
              selected: {settings.themePreference},
              onSelectionChanged: (selection) {
                controller.setThemePreference(selection.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: l10n.language,
            child: SegmentedButton<AppLanguageMode>(
              segments: [
                ButtonSegment(
                  value: AppLanguageMode.system,
                  label: Text(l10n.languageSystem),
                ),
                ButtonSegment(
                  value: AppLanguageMode.english,
                  label: Text(l10n.languageEnglish),
                ),
                ButtonSegment(
                  value: AppLanguageMode.arabic,
                  label: Text(l10n.languageArabic),
                ),
              ],
              selected: {settings.languageMode},
              onSelectionChanged: (selection) {
                controller.setLanguageMode(selection.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: l10n.board,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settings.defaultShowDone,
              title: Text(l10n.defaultShowDone),
              onChanged: controller.setDefaultShowDone,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: l10n.syncSectionTitle,
            child: _SyncSection(
              appSettings: settings,
              state: syncState,
              onSignInGuest: () => _onSyncSignInGuest(context, syncController),
              onSignInGoogle: () =>
                  _onSyncSignInGoogle(context, syncController),
              onSignInEmail: () =>
                  _onSyncEmailAuth(context, syncController, register: false),
              onRegisterEmail: () =>
                  _onSyncEmailAuth(context, syncController, register: true),
              onSignOut: () => _onSyncSignOut(context, syncController),
              onPush: () => _onSyncPush(context, syncController),
              onPull: () => _onSyncPull(context, syncController),
              onRetry: () => _onSyncRetry(context, syncController),
              onCloudSyncEnabledChanged: controller.setCloudSyncEnabled,
              onLiveSyncEnabledChanged: controller.setLiveSyncEnabled,
              onAutoSyncOnResumeEnabledChanged:
                  controller.setAutoSyncOnResumeEnabled,
              onAutoPushLocalChangesEnabledChanged:
                  controller.setAutoPushLocalChangesEnabled,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: ListTile(
                leading: const Icon(Icons.science_outlined),
                title: Text(l10n.loadDemoData),
                subtitle: Text(l10n.loadDemoDataDesc),
                trailing: FilledButton.tonal(
                  onPressed: () => _onLoadDemoDataPressed(context, ref),
                  child: Text(l10n.loadDemoData),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: Text(l10n.resetLocalData),
              subtitle: Text(l10n.resetLocalDataDesc),
              trailing: FilledButton.tonal(
                onPressed: () => _onResetDataPressed(context, ref),
                child: Text(l10n.resetAction),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onResetDataPressed(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.resetLocalDataConfirmTitle),
          content: Text(l10n.resetLocalDataConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.resetAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(localDataMaintenanceServiceProvider).resetAllLocalData();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.localDataResetSuccess)));
  }

  Future<void> _onSyncSignInGuest(
    BuildContext context,
    SyncController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.signIn();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.syncSignedInGuest)));
    } catch (error, stackTrace) {
      _logSyncError('signInGuest', error, stackTrace);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_syncErrorMessage(l10n, error))));
    }
  }

  Future<void> _onSyncSignInGoogle(
    BuildContext context,
    SyncController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.signInWithGoogle();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.syncSignedInGoogle)));
    } catch (error, stackTrace) {
      _logSyncError('signInGoogle', error, stackTrace);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_syncErrorMessage(l10n, error))));
    }
  }

  Future<void> _onSyncEmailAuth(
    BuildContext context,
    SyncController controller, {
    required bool register,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final credentials = await _showEmailAuthDialog(context, register: register);
    if (credentials == null || !context.mounted) {
      return;
    }

    try {
      if (register) {
        await controller.registerWithEmailPassword(
          email: credentials.email,
          password: credentials.password,
        );
      } else {
        await controller.signInWithEmailPassword(
          email: credentials.email,
          password: credentials.password,
        );
      }
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              register ? l10n.syncEmailRegistered : l10n.syncSignedInEmail,
            ),
          ),
        );
    } catch (error, stackTrace) {
      _logSyncError(
        register ? 'registerEmail' : 'signInEmail',
        error,
        stackTrace,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_syncErrorMessage(l10n, error))));
    }
  }

  Future<_EmailCredentials?> _showEmailAuthDialog(
    BuildContext context, {
    required bool register,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final result = await showDialog<_EmailCredentials>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            register
                ? l10n.syncEmailRegisterAction
                : l10n.syncEmailSignInAction,
          ),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(labelText: l10n.emailLabel),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return l10n.emailRequired;
                      }
                      if (!trimmed.contains('@') || !trimmed.contains('.')) {
                        return l10n.emailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    autofillHints: register
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    decoration: InputDecoration(labelText: l10n.passwordLabel),
                    validator: (value) {
                      final raw = value ?? '';
                      if (raw.isEmpty) {
                        return l10n.passwordRequired;
                      }
                      if (register && raw.length < 6) {
                        return l10n.passwordMinLength;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                Navigator.of(dialogContext).pop(
                  _EmailCredentials(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  ),
                );
              },
              child: Text(
                register
                    ? l10n.syncEmailRegisterAction
                    : l10n.syncEmailSignInAction,
              ),
            ),
          ],
        );
      },
    );

    emailController.dispose();
    passwordController.dispose();
    return result;
  }

  Future<void> _onSyncSignOut(
    BuildContext context,
    SyncController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.signOut();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.syncSignedOut)));
    } catch (error, stackTrace) {
      _logSyncError('signOut', error, stackTrace);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_syncErrorMessage(l10n, error))));
    }
  }

  Future<void> _onSyncPush(
    BuildContext context,
    SyncController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await controller.push();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.syncPushDone(
                result.upserts,
                result.deletes,
                result.skippedConflicts,
              ),
            ),
          ),
        );
    } catch (error, stackTrace) {
      _logSyncError('push', error, stackTrace);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_syncErrorMessage(l10n, error))));
    }
  }

  Future<void> _onSyncPull(
    BuildContext context,
    SyncController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await controller.pull();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.syncPullDone(
                result.upserts,
                result.deletes,
                result.skippedConflicts,
              ),
            ),
          ),
        );
    } catch (error, stackTrace) {
      _logSyncError('pull', error, stackTrace);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_syncErrorMessage(l10n, error))));
    }
  }

  Future<void> _onLoadDemoDataPressed(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final count = await ref
        .read(localDataMaintenanceServiceProvider)
        .loadDemoData();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.demoDataLoaded(count))));
  }

  void _logSyncError(String action, Object error, StackTrace stackTrace) {
    debugPrint('Q4Board sync $action failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  String _syncErrorMessage(AppLocalizations l10n, Object error) {
    if (error is TimeoutException) {
      return l10n.syncErrorTimeout;
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'operation-not-allowed':
          return l10n.syncErrorAuthOperationNotAllowed;
        case 'network-request-failed':
          return l10n.syncErrorNetwork;
        case 'too-many-requests':
          return l10n.syncErrorTooManyRequests;
        case 'user-not-found':
          return l10n.syncErrorUserNotFound;
        case 'wrong-password':
        case 'invalid-credential':
          return l10n.syncErrorInvalidCredentials;
        case 'email-already-in-use':
          return l10n.syncErrorEmailAlreadyInUse;
        case 'weak-password':
          return l10n.syncErrorWeakPassword;
        case 'invalid-email':
          return l10n.syncErrorInvalidEmail;
        case 'account-exists-with-different-credential':
          return l10n.syncErrorAccountExistsDifferentProvider;
        default:
          return '${l10n.syncErrorGeneric}: ${error.code}';
      }
    }
    final text = error.toString();
    if (text.contains('google-sign-in-cancelled')) {
      return l10n.syncErrorGoogleCanceled;
    }
    if (text.contains('google-sign-in-missing-token')) {
      return l10n.syncErrorGoogleTokenMissing;
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return l10n.syncErrorPermissionDenied;
        case 'unauthenticated':
          return l10n.syncErrorAuthRequired;
        case 'unavailable':
          return l10n.syncErrorNetwork;
        case 'failed-precondition':
          return l10n.syncErrorFirestoreSetup;
        default:
          return '${l10n.syncErrorGeneric}: ${error.code}';
      }
    }
    return l10n.syncErrorGeneric;
  }

  Future<void> _onSyncRetry(
    BuildContext context,
    SyncController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.retryLastAction();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.syncRetrySuccess)));
    } catch (error, stackTrace) {
      _logSyncError('retry', error, stackTrace);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_syncErrorMessage(l10n, error))));
    }
  }
}

class _SyncSection extends StatelessWidget {
  const _SyncSection({
    required this.appSettings,
    required this.state,
    required this.onSignInGuest,
    required this.onSignInGoogle,
    required this.onSignInEmail,
    required this.onRegisterEmail,
    required this.onSignOut,
    required this.onPush,
    required this.onPull,
    required this.onRetry,
    required this.onCloudSyncEnabledChanged,
    required this.onLiveSyncEnabledChanged,
    required this.onAutoSyncOnResumeEnabledChanged,
    required this.onAutoPushLocalChangesEnabledChanged,
  });

  final AppSettingsEntity appSettings;
  final SyncControllerState state;
  final VoidCallback onSignInGuest;
  final VoidCallback onSignInGoogle;
  final VoidCallback onSignInEmail;
  final VoidCallback onRegisterEmail;
  final VoidCallback onSignOut;
  final VoidCallback onPush;
  final VoidCallback onPull;
  final VoidCallback onRetry;
  final ValueChanged<bool> onCloudSyncEnabledChanged;
  final ValueChanged<bool> onLiveSyncEnabledChanged;
  final ValueChanged<bool> onAutoSyncOnResumeEnabledChanged;
  final ValueChanged<bool> onAutoPushLocalChangesEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canUseCloud = state.bootstrapState.isAvailable;
    final isSignedIn = state.session.isAuthenticated;
    final cloudSyncEnabled = appSettings.cloudSyncEnabled;
    final liveSyncEnabled = appSettings.liveSyncEnabled;
    final autoSyncOnResumeEnabled = appSettings.autoSyncOnResumeEnabled;
    final autoPushLocalChangesEnabled = appSettings.autoPushLocalChangesEnabled;
    final actionsEnabled = canUseCloud && cloudSyncEnabled;
    final canAuthButtons = actionsEnabled && !state.isBusy;
    final isAnonymous =
        state.session.isAuthenticated && state.session.isAnonymous;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              canUseCloud
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                canUseCloud
                    ? (cloudSyncEnabled
                          ? (isSignedIn
                                ? l10n.syncConnected
                                : l10n.syncNotSignedIn)
                          : l10n.syncDisabledByPreference)
                    : l10n.syncUnavailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: cloudSyncEnabled,
          onChanged: canUseCloud ? onCloudSyncEnabledChanged : null,
          title: Text(l10n.syncEnableCloud),
          subtitle: Text(l10n.syncEnableCloudDesc),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: liveSyncEnabled,
          onChanged: (actionsEnabled && !state.isBusy)
              ? onLiveSyncEnabledChanged
              : null,
          title: Text(l10n.syncEnableLive),
          subtitle: Text(l10n.syncEnableLiveDesc),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: autoSyncOnResumeEnabled,
          onChanged: (actionsEnabled && !state.isBusy)
              ? onAutoSyncOnResumeEnabledChanged
              : null,
          title: Text(l10n.syncEnableAutoResume),
          subtitle: Text(l10n.syncEnableAutoResumeDesc),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: autoPushLocalChangesEnabled,
          onChanged: (actionsEnabled && !state.isBusy && isSignedIn)
              ? onAutoPushLocalChangesEnabledChanged
              : null,
          title: Text(l10n.syncEnableAutoPush),
          subtitle: Text(l10n.syncEnableAutoPushDesc),
        ),
        if (state.session.userId != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _accountSummaryText(context, state.session),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.syncUserId(state.session.userId!),
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (isAnonymous) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.syncGuestUpgradeHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
        if (appSettings.lastSyncAt != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _lastSyncText(context, appSettings),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (!canUseCloud) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.syncNotConfiguredHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FilledButton.tonalIcon(
              onPressed: (!canAuthButtons || isSignedIn) ? null : onSignInGuest,
              icon: const Icon(Icons.login_outlined),
              label: Text(l10n.syncSignInGuestAction),
            ),
            FilledButton.tonalIcon(
              onPressed: !canAuthButtons ? null : onSignInGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: Text(
                isAnonymous
                    ? l10n.syncUpgradeWithGoogle
                    : l10n.syncSignInGoogleAction,
              ),
            ),
            OutlinedButton.icon(
              onPressed: !canAuthButtons ? null : onSignInEmail,
              icon: const Icon(Icons.alternate_email_outlined),
              label: Text(
                isAnonymous
                    ? l10n.syncUpgradeWithEmail
                    : l10n.syncEmailSignInAction,
              ),
            ),
            OutlinedButton.icon(
              onPressed: !canAuthButtons ? null : onRegisterEmail,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l10n.syncEmailRegisterAction),
            ),
            FilledButton.tonalIcon(
              onPressed: (!actionsEnabled || state.isBusy || !isSignedIn)
                  ? null
                  : onSignOut,
              icon: const Icon(Icons.logout_outlined),
              label: Text(l10n.syncSignOut),
            ),
            FilledButton.tonalIcon(
              onPressed: (!actionsEnabled || state.isBusy || !isSignedIn)
                  ? null
                  : onPush,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(l10n.syncPush),
            ),
            FilledButton.tonalIcon(
              onPressed: (!actionsEnabled || state.isBusy || !isSignedIn)
                  ? null
                  : onPull,
              icon: const Icon(Icons.cloud_download_outlined),
              label: Text(l10n.syncPull),
            ),
            OutlinedButton.icon(
              onPressed:
                  (!actionsEnabled || state.isBusy || !state.canRetryLastAction)
                  ? null
                  : onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retryAction),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (state.isBusy) ...[
          const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (state.lastError != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              _errorHintText(context, state.lastError!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            if (state.isBusy) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                _syncStatusText(context, state.syncStatus),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.syncRecentActivity,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (state.recentActivities.isEmpty)
          Text(
            l10n.syncNoRecentActivity,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Column(
            children: state.recentActivities
                .take(6)
                .map((entry) => _buildActivityTile(context, entry))
                .toList(growable: false),
          ),
      ],
    );
  }

  String _syncStatusText(BuildContext context, SyncStatusSnapshot status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.code) {
      case SyncStatusCode.unavailable:
        return l10n.syncStatusUnavailable;
      case SyncStatusCode.idle:
        return l10n.syncStatusIdle;
      case SyncStatusCode.authRequired:
        return l10n.syncStatusAuthRequired;
      case SyncStatusCode.liveListening:
        return _syncLiveText(l10n, status);
      case SyncStatusCode.pushing:
        return l10n.syncStatusPushing;
      case SyncStatusCode.pulling:
        return l10n.syncStatusPulling;
      case SyncStatusCode.success:
        return _syncSuccessText(l10n, status);
      case SyncStatusCode.error:
        return l10n.syncStatusError;
    }
  }

  String _accountSummaryText(BuildContext context, AuthSession session) {
    final l10n = AppLocalizations.of(context)!;
    if (!session.isAuthenticated) {
      return l10n.syncNotSignedIn;
    }
    return switch (session.providerKind) {
      AuthProviderKind.anonymous => l10n.syncAccountGuest,
      AuthProviderKind.google =>
        session.email == null
            ? l10n.syncAccountGoogle
            : l10n.syncAccountGoogleEmail(session.email!),
      AuthProviderKind.emailPassword =>
        session.email == null
            ? l10n.syncAccountEmail
            : l10n.syncAccountEmailValue(session.email!),
      AuthProviderKind.apple => l10n.syncAccountApple,
      AuthProviderKind.none || AuthProviderKind.unknown =>
        session.email == null
            ? l10n.syncAccountUnknown
            : l10n.syncAccountEmailValue(session.email!),
    };
  }

  String _syncSuccessText(AppLocalizations l10n, SyncStatusSnapshot status) {
    final key = status.lastMessage;
    if (key == 'push_conflicts_skipped') {
      return l10n.syncStatusPushCompleteConflicts;
    }
    if (key == 'pull_conflicts_skipped') {
      return l10n.syncStatusPullCompleteConflicts;
    }
    if (key == 'pull_remote_empty_local_kept') {
      return l10n.syncStatusPullRemoteEmptyLocalKept;
    }
    if (key == 'push_complete') {
      return l10n.syncStatusPushComplete;
    }
    if (key == 'pull_complete') {
      return l10n.syncStatusPullComplete;
    }
    return l10n.syncStatusSuccess;
  }

  String _syncLiveText(AppLocalizations l10n, SyncStatusSnapshot status) {
    final key = status.lastMessage;
    if (key == 'live_sync_active') {
      return l10n.syncStatusLiveActive;
    }
    if (key == 'live_sync_stopped') {
      return l10n.syncStatusLiveStopped;
    }
    if (key == 'live_sync_applied') {
      return l10n.syncStatusLiveApplied;
    }
    if (key == 'live_sync_applied_conflicts') {
      return l10n.syncStatusLiveAppliedConflicts;
    }
    if (key == 'live_sync_remote_empty_local_kept') {
      return l10n.syncStatusPullRemoteEmptyLocalKept;
    }
    return l10n.syncStatusLiveActive;
  }

  String _errorHintText(BuildContext context, SyncActionError error) {
    final l10n = AppLocalizations.of(context)!;
    if (error.isTimeout) {
      return l10n.syncErrorTimeoutHelp;
    }
    final raw = error.rawError.toString();
    if (raw.contains('permission-denied')) {
      return l10n.syncErrorPermissionDeniedHelp;
    }
    if (raw.contains('operation-not-allowed')) {
      return l10n.syncErrorAuthOperationHelp;
    }
    if (raw.contains('network-request-failed') || raw.contains('unavailable')) {
      return l10n.syncErrorNetworkHelp;
    }
    return l10n.syncErrorRetryHint;
  }

  String _lastSyncText(BuildContext context, AppSettingsEntity settings) {
    final l10n = AppLocalizations.of(context)!;
    final at = settings.lastSyncAt;
    if (at == null) {
      return l10n.syncLastSyncNever;
    }
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(at);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(at));
    final summary = _lastSyncStatusSummary(l10n, settings.lastSyncStatusKey);
    return l10n.syncLastSyncSummary(date, time, summary);
  }

  String _lastSyncStatusSummary(AppLocalizations l10n, String? key) {
    switch (key) {
      case 'push_complete':
        return l10n.syncStatusPushComplete;
      case 'push_conflicts_skipped':
        return l10n.syncStatusPushCompleteConflicts;
      case 'pull_complete':
        return l10n.syncStatusPullComplete;
      case 'pull_conflicts_skipped':
        return l10n.syncStatusPullCompleteConflicts;
      case 'pull_remote_empty_local_kept':
        return l10n.syncStatusPullRemoteEmptyLocalKept;
      case 'live_sync_active':
        return l10n.syncStatusLiveActive;
      case 'live_sync_applied':
        return l10n.syncStatusLiveApplied;
      case 'live_sync_applied_conflicts':
        return l10n.syncStatusLiveAppliedConflicts;
      case 'live_sync_remote_empty_local_kept':
        return l10n.syncStatusPullRemoteEmptyLocalKept;
      case 'live_sync_stopped':
        return l10n.syncStatusLiveStopped;
      default:
        return l10n.syncStatusIdle;
    }
  }

  Widget _buildActivityTile(BuildContext context, SyncActivityEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final localizations = MaterialLocalizations.of(context);
    final atText =
        '${localizations.formatShortDate(entry.at)} ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(entry.at))}';
    final title = _activityTitle(l10n, entry);
    final subtitle = _activitySubtitle(l10n, entry);
    final conflictHint = _activityConflictHint(l10n, entry);

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                entry.isSuccess
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                size: 16,
                color: entry.isSuccess
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(atText, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          if (conflictHint != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              conflictHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
          if (entry.conflictNoteIds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _showConflictDetails(context, entry),
                icon: const Icon(Icons.rule_folder_outlined, size: 18),
                label: Text(l10n.syncConflictDetailsAction),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _activityTitle(AppLocalizations l10n, SyncActivityEntry entry) {
    final prefix = switch (entry.kind) {
      SyncActivityKind.push => l10n.syncActivityPush,
      SyncActivityKind.autoPush => l10n.syncActivityAutoPush,
      SyncActivityKind.pull => l10n.syncActivityPull,
      SyncActivityKind.autoPull => l10n.syncActivityAutoPull,
      SyncActivityKind.live => l10n.syncActivityLive,
    };
    if (!entry.isSuccess) {
      return l10n.syncActivityFailed(prefix);
    }
    return prefix;
  }

  String _activitySubtitle(AppLocalizations l10n, SyncActivityEntry entry) {
    if (!entry.isSuccess) {
      return l10n.syncActivityErrorCode(
        entry.errorCode ?? l10n.syncErrorGeneric,
      );
    }
    final summary = _lastSyncStatusSummary(l10n, entry.summaryKey);
    return l10n.syncActivityCounts(
      summary,
      entry.upserts,
      entry.deletes,
      entry.skippedConflicts,
    );
  }

  String? _activityConflictHint(
    AppLocalizations l10n,
    SyncActivityEntry entry,
  ) {
    if (!entry.isSuccess || entry.skippedConflicts <= 0) {
      return null;
    }
    return switch (entry.conflictResolution) {
      SyncConflictResolution.localKept => l10n.syncConflictLocalKeptHint,
      SyncConflictResolution.remoteKept => l10n.syncConflictRemoteKeptHint,
      null => l10n.syncConflictReviewHint,
    };
  }

  Future<void> _showConflictDetails(
    BuildContext context,
    SyncActivityEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.syncConflictDetailsTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _activityConflictHint(l10n, entry) ??
                      l10n.syncConflictReviewHint,
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: entry.conflictNoteIds.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: AppSpacing.sm),
                    itemBuilder: (_, index) => SelectableText(
                      entry.conflictNoteIds[index],
                      style: Theme.of(sheetContext).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmailCredentials {
  const _EmailCredentials({required this.email, required this.password});

  final String email;
  final String password;
}
