// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Q4 Board';

  @override
  String get board => 'Board';

  @override
  String get settings => 'Settings';

  @override
  String get searchHint => 'Search notes';

  @override
  String get showDone => 'Show done';

  @override
  String get filterAll => 'All';

  @override
  String get filterHideDone => 'Hide done';

  @override
  String get doneFilterControl => 'Done items filter';

  @override
  String get addNote => 'Add note';

  @override
  String get editNote => 'Edit note';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get dueDate => 'Due date';

  @override
  String get noDueDate => 'No due date';

  @override
  String get markDone => 'Done';

  @override
  String get moveTo => 'Move to';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get defaultShowDone => 'Default show done';

  @override
  String get syncComingSoon => 'Sync (coming soon)';

  @override
  String get syncComingSoonDesc =>
      'Firebase auth + cloud sync will be added in Phase 2.';

  @override
  String get syncSectionTitle => 'Cloud Sync';

  @override
  String get syncUnavailable => 'Cloud sync unavailable';

  @override
  String get syncConnected => 'Cloud sync ready';

  @override
  String get syncNotSignedIn => 'Sign in to enable cloud sync';

  @override
  String get syncDisabledByPreference =>
      'Cloud sync is disabled on this device';

  @override
  String get syncNotConfiguredHelp =>
      'Firebase is not configured yet. Run FlutterFire configure and replace firebase_options.dart.';

  @override
  String get syncEnableCloud => 'Enable cloud sync';

  @override
  String get syncEnableCloudDesc =>
      'Allow sign-in and cloud sync on this device.';

  @override
  String get syncEnableLive => 'Enable live sync';

  @override
  String get syncEnableLiveDesc =>
      'Apply remote changes automatically while signed in.';

  @override
  String get syncEnableAutoResume => 'Auto sync on app resume';

  @override
  String get syncEnableAutoResumeDesc =>
      'Automatically pull cloud changes when the app returns to foreground.';

  @override
  String get syncEnableAutoPush => 'Auto push local changes';

  @override
  String get syncEnableAutoPushDesc =>
      'Push local edits in the background after a short delay. Manual push/pull controls stay available.';

  @override
  String get syncRecentActivity => 'Recent sync activity';

  @override
  String get syncNoRecentActivity => 'No sync activity yet';

  @override
  String get syncActivityPush => 'Manual push';

  @override
  String get syncActivityAutoPush => 'Auto push (local changes)';

  @override
  String get syncActivityPull => 'Manual pull';

  @override
  String get syncActivityAutoPull => 'Auto pull (resume)';

  @override
  String get syncActivityLive => 'Live sync apply';

  @override
  String syncActivityFailed(String action) {
    return '$action failed';
  }

  @override
  String syncActivityErrorCode(String code) {
    return 'Error: $code';
  }

  @override
  String syncActivityCounts(
    String summary,
    int upserts,
    int deletes,
    int conflicts,
  ) {
    return '$summary • upserts: $upserts, deletes: $deletes, conflicts: $conflicts';
  }

  @override
  String get syncConflictLocalKeptHint =>
      'Conflicts resolved by keeping newer local changes.';

  @override
  String get syncConflictRemoteKeptHint =>
      'Conflicts resolved by keeping newer cloud changes.';

  @override
  String get syncConflictReviewHint =>
      'Review conflict details to inspect affected note IDs.';

  @override
  String get syncConflictDetailsAction => 'Conflict details';

  @override
  String get syncConflictDetailsTitle => 'Conflict details (note IDs)';

  @override
  String get syncSignInGuestAction => 'Continue as guest';

  @override
  String get syncSignInGoogleAction => 'Sign in with Google';

  @override
  String get syncEmailSignInAction => 'Sign in with email';

  @override
  String get syncEmailRegisterAction => 'Create account';

  @override
  String get syncUpgradeWithGoogle => 'Upgrade guest with Google';

  @override
  String get syncUpgradeWithEmail => 'Upgrade guest with email';

  @override
  String get syncGuestUpgradeHint =>
      'Guest accounts are device-specific. Upgrade to Google or email/password for cross-device sync.';

  @override
  String get syncAccountGuest => 'Account: Guest (anonymous)';

  @override
  String get syncAccountGoogle => 'Account: Google';

  @override
  String syncAccountGoogleEmail(String email) {
    return 'Account: Google ($email)';
  }

  @override
  String get syncAccountEmail => 'Account: Email/password';

  @override
  String syncAccountEmailValue(String email) {
    return 'Account: $email';
  }

  @override
  String get syncAccountApple => 'Account: Apple';

  @override
  String get syncAccountUnknown => 'Account: Signed in';

  @override
  String get syncSignIn => 'Sign in';

  @override
  String get syncSignOut => 'Sign out';

  @override
  String get syncPush => 'Push';

  @override
  String get syncPull => 'Pull';

  @override
  String get syncSignedInGuest => 'Signed in as guest';

  @override
  String get syncSignedInGoogle => 'Signed in with Google';

  @override
  String get syncSignedInEmail => 'Signed in with email/password';

  @override
  String get syncEmailRegistered => 'Email account created and linked';

  @override
  String get syncSignedIn => 'Signed in successfully';

  @override
  String get syncSignedOut => 'Signed out';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get syncErrorGeneric => 'Cloud sync action failed';

  @override
  String get syncErrorTimeout => 'Sync timed out. Please try again.';

  @override
  String get syncErrorTimeoutHelp =>
      'The operation took too long. Check your connection and retry.';

  @override
  String get syncErrorNetwork =>
      'Network unavailable. Check your connection and try again.';

  @override
  String get syncErrorNetworkHelp =>
      'Network issue detected. Verify connectivity, then retry.';

  @override
  String get syncErrorPermissionDenied =>
      'Cloud sync denied by Firestore rules';

  @override
  String get syncErrorPermissionDeniedHelp =>
      'Firestore rules blocked this action. Confirm rules allow users/<uid>/notes for the signed-in user.';

  @override
  String get syncErrorAuthRequired => 'Sign in is required before sync';

  @override
  String get syncErrorAuthOperationNotAllowed =>
      'Anonymous sign-in is disabled in Firebase Auth';

  @override
  String get syncErrorAuthOperationHelp =>
      'Enable Anonymous sign-in in Firebase Console > Authentication > Sign-in method.';

  @override
  String get syncErrorFirestoreSetup =>
      'Firestore is not ready for this project yet';

  @override
  String get syncErrorTooManyRequests =>
      'Too many requests. Please wait and retry.';

  @override
  String get syncErrorUserNotFound => 'No account found for this email';

  @override
  String get syncErrorInvalidCredentials => 'Email or password is incorrect';

  @override
  String get syncErrorEmailAlreadyInUse =>
      'This email is already in use. Sign in instead.';

  @override
  String get syncErrorWeakPassword =>
      'Password is too weak (minimum 6 characters).';

  @override
  String get syncErrorInvalidEmail => 'The email address is invalid.';

  @override
  String get syncErrorAccountExistsDifferentProvider =>
      'This email is already linked to another sign-in method.';

  @override
  String get syncErrorGoogleCanceled => 'Google sign-in was canceled.';

  @override
  String get syncErrorGoogleTokenMissing =>
      'Google sign-in did not return tokens. Refresh config files and retry.';

  @override
  String get syncErrorRetryHint =>
      'You can retry the last sync action after fixing the issue.';

  @override
  String get syncRetrySuccess => 'Retried sync action';

  @override
  String get retryAction => 'Retry';

  @override
  String get syncStatusUnavailable =>
      'Firebase is unavailable (local-only mode).';

  @override
  String get syncStatusIdle => 'Idle';

  @override
  String get syncStatusAuthRequired => 'Authentication required';

  @override
  String get syncStatusPushing => 'Pushing local notes to cloud...';

  @override
  String get syncStatusPulling => 'Pulling cloud notes to this device...';

  @override
  String get syncStatusLiveActive => 'Live sync is active';

  @override
  String get syncStatusLiveStopped => 'Live sync stopped';

  @override
  String get syncStatusLiveApplied => 'Live sync applied remote changes';

  @override
  String get syncStatusLiveAppliedConflicts =>
      'Live sync applied (newer local changes were kept)';

  @override
  String get syncLastSyncNever => 'Last sync: never';

  @override
  String syncLastSyncSummary(String date, String time, String summary) {
    return 'Last sync: $date $time ($summary)';
  }

  @override
  String get syncStatusSuccess => 'Sync completed';

  @override
  String get syncStatusError => 'Sync failed';

  @override
  String get syncStatusPushComplete => 'Push completed';

  @override
  String get syncStatusPullComplete => 'Pull completed';

  @override
  String get syncStatusPushCompleteConflicts =>
      'Push completed (newer cloud changes were kept)';

  @override
  String get syncStatusPullCompleteConflicts =>
      'Pull completed (newer local changes were kept)';

  @override
  String get syncStatusPullRemoteEmptyLocalKept =>
      'Cloud is empty; local notes were kept (safety check)';

  @override
  String syncUserId(String userId) {
    return 'User: $userId';
  }

  @override
  String syncPushDone(int upserts, int deletes, int skipped) {
    return 'Push complete: $upserts updated, $deletes removed, $skipped conflicts skipped';
  }

  @override
  String syncPullDone(int upserts, int deletes, int skipped) {
    return 'Pull complete: $upserts updated, $deletes removed locally, $skipped conflicts skipped';
  }

  @override
  String get q1Title => 'Important & Urgent';

  @override
  String get q2Title => 'Important & Not Urgent';

  @override
  String get q3Title => 'Not Important & Urgent';

  @override
  String get q4Title => 'Not Important & Not Urgent';

  @override
  String get q1Label => 'DO FIRST';

  @override
  String get q2Label => 'SCHEDULE';

  @override
  String get q3Label => 'DELEGATE';

  @override
  String get q4Label => 'DON\'T DO';

  @override
  String get q1TabSemantics => 'Do first quadrant';

  @override
  String get q2TabSemantics => 'Schedule quadrant';

  @override
  String get q3TabSemantics => 'Delegate quadrant';

  @override
  String get q4TabSemantics => 'Don\'t do quadrant';

  @override
  String get emptyQuadrant => 'No notes yet';

  @override
  String get emptySearch => 'No results for your search';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noteMoved => 'Note moved';

  @override
  String get requiredTitle => 'Title is required';

  @override
  String get clearDueDate => 'Clear date';

  @override
  String get pickDate => 'Pick date';

  @override
  String get doneChip => 'Done';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get loadDemoData => 'Load demo data';

  @override
  String get loadDemoDataDesc =>
      'Replace local notes with curated demo content for screenshots.';

  @override
  String demoDataLoaded(int count) {
    return '$count demo notes loaded';
  }

  @override
  String get resetLocalData => 'Reset local data';

  @override
  String get resetLocalDataDesc =>
      'Clear all notes and settings saved on this device.';

  @override
  String get resetLocalDataConfirmTitle => 'Reset local data?';

  @override
  String get resetLocalDataConfirmBody =>
      'This will permanently remove your notes and settings from this device.';

  @override
  String get resetAction => 'Reset';

  @override
  String get localDataResetSuccess => 'Local data has been reset';
}
