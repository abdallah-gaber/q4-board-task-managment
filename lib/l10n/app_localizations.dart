import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Q4 Board'**
  String get appTitle;

  /// No description provided for @board.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get board;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchHint;

  /// No description provided for @showDone.
  ///
  /// In en, this message translates to:
  /// **'Show done'**
  String get showDone;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterHideDone.
  ///
  /// In en, this message translates to:
  /// **'Hide done'**
  String get filterHideDone;

  /// No description provided for @doneFilterControl.
  ///
  /// In en, this message translates to:
  /// **'Done items filter'**
  String get doneFilterControl;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get markDone;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get moveTo;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @defaultShowDone.
  ///
  /// In en, this message translates to:
  /// **'Default show done'**
  String get defaultShowDone;

  /// No description provided for @syncComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sync (coming soon)'**
  String get syncComingSoon;

  /// No description provided for @syncComingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'Firebase auth + cloud sync will be added in Phase 2.'**
  String get syncComingSoonDesc;

  /// No description provided for @syncSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get syncSectionTitle;

  /// No description provided for @syncUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync unavailable'**
  String get syncUnavailable;

  /// No description provided for @syncConnected.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync ready'**
  String get syncConnected;

  /// No description provided for @syncNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to enable cloud sync'**
  String get syncNotSignedIn;

  /// No description provided for @syncDisabledByPreference.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is disabled on this device'**
  String get syncDisabledByPreference;

  /// No description provided for @syncNotConfiguredHelp.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured yet. Run FlutterFire configure and replace firebase_options.dart.'**
  String get syncNotConfiguredHelp;

  /// No description provided for @syncEnableCloud.
  ///
  /// In en, this message translates to:
  /// **'Enable cloud sync'**
  String get syncEnableCloud;

  /// No description provided for @syncEnableCloudDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow sign-in and cloud sync on this device.'**
  String get syncEnableCloudDesc;

  /// No description provided for @syncEnableLive.
  ///
  /// In en, this message translates to:
  /// **'Enable live sync'**
  String get syncEnableLive;

  /// No description provided for @syncEnableLiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Apply remote changes automatically while signed in.'**
  String get syncEnableLiveDesc;

  /// No description provided for @syncEnableAutoResume.
  ///
  /// In en, this message translates to:
  /// **'Auto sync on app resume'**
  String get syncEnableAutoResume;

  /// No description provided for @syncEnableAutoResumeDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically pull cloud changes when the app returns to foreground.'**
  String get syncEnableAutoResumeDesc;

  /// No description provided for @syncEnableAutoPush.
  ///
  /// In en, this message translates to:
  /// **'Auto push local changes'**
  String get syncEnableAutoPush;

  /// No description provided for @syncEnableAutoPushDesc.
  ///
  /// In en, this message translates to:
  /// **'Push local edits in the background after a short delay. Manual push/pull controls stay available.'**
  String get syncEnableAutoPushDesc;

  /// No description provided for @syncRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent sync activity'**
  String get syncRecentActivity;

  /// No description provided for @syncNoRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No sync activity yet'**
  String get syncNoRecentActivity;

  /// No description provided for @syncActivityPush.
  ///
  /// In en, this message translates to:
  /// **'Manual push'**
  String get syncActivityPush;

  /// No description provided for @syncActivityAutoPush.
  ///
  /// In en, this message translates to:
  /// **'Auto push (local changes)'**
  String get syncActivityAutoPush;

  /// No description provided for @syncActivityPull.
  ///
  /// In en, this message translates to:
  /// **'Manual pull'**
  String get syncActivityPull;

  /// No description provided for @syncActivityAutoPull.
  ///
  /// In en, this message translates to:
  /// **'Auto pull (resume)'**
  String get syncActivityAutoPull;

  /// No description provided for @syncActivityLive.
  ///
  /// In en, this message translates to:
  /// **'Live sync apply'**
  String get syncActivityLive;

  /// No description provided for @syncActivityFailed.
  ///
  /// In en, this message translates to:
  /// **'{action} failed'**
  String syncActivityFailed(String action);

  /// No description provided for @syncActivityErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Error: {code}'**
  String syncActivityErrorCode(String code);

  /// No description provided for @syncActivityCounts.
  ///
  /// In en, this message translates to:
  /// **'{summary} • upserts: {upserts}, deletes: {deletes}, conflicts: {conflicts}'**
  String syncActivityCounts(
    String summary,
    int upserts,
    int deletes,
    int conflicts,
  );

  /// No description provided for @syncConflictLocalKeptHint.
  ///
  /// In en, this message translates to:
  /// **'Conflicts resolved by keeping newer local changes.'**
  String get syncConflictLocalKeptHint;

  /// No description provided for @syncConflictRemoteKeptHint.
  ///
  /// In en, this message translates to:
  /// **'Conflicts resolved by keeping newer cloud changes.'**
  String get syncConflictRemoteKeptHint;

  /// No description provided for @syncConflictReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Review conflict details to inspect affected note IDs.'**
  String get syncConflictReviewHint;

  /// No description provided for @syncConflictDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Conflict details'**
  String get syncConflictDetailsAction;

  /// No description provided for @syncConflictDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflict details (note IDs)'**
  String get syncConflictDetailsTitle;

  /// No description provided for @syncSignInGuestAction.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get syncSignInGuestAction;

  /// No description provided for @syncSignInGoogleAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get syncSignInGoogleAction;

  /// No description provided for @syncEmailSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get syncEmailSignInAction;

  /// No description provided for @syncEmailRegisterAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get syncEmailRegisterAction;

  /// No description provided for @syncUpgradeWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade guest with Google'**
  String get syncUpgradeWithGoogle;

  /// No description provided for @syncUpgradeWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Upgrade guest with email'**
  String get syncUpgradeWithEmail;

  /// No description provided for @syncGuestUpgradeHint.
  ///
  /// In en, this message translates to:
  /// **'Guest accounts are device-specific. Upgrade to Google or email/password for cross-device sync.'**
  String get syncGuestUpgradeHint;

  /// No description provided for @syncAccountGuest.
  ///
  /// In en, this message translates to:
  /// **'Account: Guest (anonymous)'**
  String get syncAccountGuest;

  /// No description provided for @syncAccountGoogle.
  ///
  /// In en, this message translates to:
  /// **'Account: Google'**
  String get syncAccountGoogle;

  /// No description provided for @syncAccountGoogleEmail.
  ///
  /// In en, this message translates to:
  /// **'Account: Google ({email})'**
  String syncAccountGoogleEmail(String email);

  /// No description provided for @syncAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account: Email/password'**
  String get syncAccountEmail;

  /// No description provided for @syncAccountEmailValue.
  ///
  /// In en, this message translates to:
  /// **'Account: {email}'**
  String syncAccountEmailValue(String email);

  /// No description provided for @syncAccountApple.
  ///
  /// In en, this message translates to:
  /// **'Account: Apple'**
  String get syncAccountApple;

  /// No description provided for @syncAccountUnknown.
  ///
  /// In en, this message translates to:
  /// **'Account: Signed in'**
  String get syncAccountUnknown;

  /// No description provided for @syncSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get syncSignIn;

  /// No description provided for @syncSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get syncSignOut;

  /// No description provided for @syncPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get syncPush;

  /// No description provided for @syncPull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get syncPull;

  /// No description provided for @syncSignedInGuest.
  ///
  /// In en, this message translates to:
  /// **'Signed in as guest'**
  String get syncSignedInGuest;

  /// No description provided for @syncSignedInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get syncSignedInGoogle;

  /// No description provided for @syncSignedInEmail.
  ///
  /// In en, this message translates to:
  /// **'Signed in with email/password'**
  String get syncSignedInEmail;

  /// No description provided for @syncEmailRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email account created and linked'**
  String get syncEmailRegistered;

  /// No description provided for @syncSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully'**
  String get syncSignedIn;

  /// No description provided for @syncSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get syncSignedOut;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @syncErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync action failed'**
  String get syncErrorGeneric;

  /// No description provided for @syncErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Sync timed out. Please try again.'**
  String get syncErrorTimeout;

  /// No description provided for @syncErrorTimeoutHelp.
  ///
  /// In en, this message translates to:
  /// **'The operation took too long. Check your connection and retry.'**
  String get syncErrorTimeoutHelp;

  /// No description provided for @syncErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network unavailable. Check your connection and try again.'**
  String get syncErrorNetwork;

  /// No description provided for @syncErrorNetworkHelp.
  ///
  /// In en, this message translates to:
  /// **'Network issue detected. Verify connectivity, then retry.'**
  String get syncErrorNetworkHelp;

  /// No description provided for @syncErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync denied by Firestore rules'**
  String get syncErrorPermissionDenied;

  /// No description provided for @syncErrorPermissionDeniedHelp.
  ///
  /// In en, this message translates to:
  /// **'Firestore rules blocked this action. Confirm rules allow users/<uid>/notes for the signed-in user.'**
  String get syncErrorPermissionDeniedHelp;

  /// No description provided for @syncErrorAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in is required before sync'**
  String get syncErrorAuthRequired;

  /// No description provided for @syncErrorAuthOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Anonymous sign-in is disabled in Firebase Auth'**
  String get syncErrorAuthOperationNotAllowed;

  /// No description provided for @syncErrorAuthOperationHelp.
  ///
  /// In en, this message translates to:
  /// **'Enable Anonymous sign-in in Firebase Console > Authentication > Sign-in method.'**
  String get syncErrorAuthOperationHelp;

  /// No description provided for @syncErrorFirestoreSetup.
  ///
  /// In en, this message translates to:
  /// **'Firestore is not ready for this project yet'**
  String get syncErrorFirestoreSetup;

  /// No description provided for @syncErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait and retry.'**
  String get syncErrorTooManyRequests;

  /// No description provided for @syncErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for this email'**
  String get syncErrorUserNotFound;

  /// No description provided for @syncErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get syncErrorInvalidCredentials;

  /// No description provided for @syncErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Sign in instead.'**
  String get syncErrorEmailAlreadyInUse;

  /// No description provided for @syncErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak (minimum 6 characters).'**
  String get syncErrorWeakPassword;

  /// No description provided for @syncErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get syncErrorInvalidEmail;

  /// No description provided for @syncErrorAccountExistsDifferentProvider.
  ///
  /// In en, this message translates to:
  /// **'This email is already linked to another sign-in method.'**
  String get syncErrorAccountExistsDifferentProvider;

  /// No description provided for @syncErrorGoogleCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was canceled.'**
  String get syncErrorGoogleCanceled;

  /// No description provided for @syncErrorGoogleTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in did not return tokens. Refresh config files and retry.'**
  String get syncErrorGoogleTokenMissing;

  /// No description provided for @syncErrorRetryHint.
  ///
  /// In en, this message translates to:
  /// **'You can retry the last sync action after fixing the issue.'**
  String get syncErrorRetryHint;

  /// No description provided for @syncRetrySuccess.
  ///
  /// In en, this message translates to:
  /// **'Retried sync action'**
  String get syncRetrySuccess;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @syncStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Firebase is unavailable (local-only mode).'**
  String get syncStatusUnavailable;

  /// No description provided for @syncStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get syncStatusIdle;

  /// No description provided for @syncStatusAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get syncStatusAuthRequired;

  /// No description provided for @syncStatusPushing.
  ///
  /// In en, this message translates to:
  /// **'Pushing local notes to cloud...'**
  String get syncStatusPushing;

  /// No description provided for @syncStatusPulling.
  ///
  /// In en, this message translates to:
  /// **'Pulling cloud notes to this device...'**
  String get syncStatusPulling;

  /// No description provided for @syncStatusLiveActive.
  ///
  /// In en, this message translates to:
  /// **'Live sync is active'**
  String get syncStatusLiveActive;

  /// No description provided for @syncStatusLiveStopped.
  ///
  /// In en, this message translates to:
  /// **'Live sync stopped'**
  String get syncStatusLiveStopped;

  /// No description provided for @syncStatusLiveApplied.
  ///
  /// In en, this message translates to:
  /// **'Live sync applied remote changes'**
  String get syncStatusLiveApplied;

  /// No description provided for @syncStatusLiveAppliedConflicts.
  ///
  /// In en, this message translates to:
  /// **'Live sync applied (newer local changes were kept)'**
  String get syncStatusLiveAppliedConflicts;

  /// No description provided for @syncLastSyncNever.
  ///
  /// In en, this message translates to:
  /// **'Last sync: never'**
  String get syncLastSyncNever;

  /// No description provided for @syncLastSyncSummary.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {date} {time} ({summary})'**
  String syncLastSyncSummary(String date, String time, String summary);

  /// No description provided for @syncStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get syncStatusSuccess;

  /// No description provided for @syncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncStatusError;

  /// No description provided for @syncStatusPushComplete.
  ///
  /// In en, this message translates to:
  /// **'Push completed'**
  String get syncStatusPushComplete;

  /// No description provided for @syncStatusPullComplete.
  ///
  /// In en, this message translates to:
  /// **'Pull completed'**
  String get syncStatusPullComplete;

  /// No description provided for @syncStatusPushCompleteConflicts.
  ///
  /// In en, this message translates to:
  /// **'Push completed (newer cloud changes were kept)'**
  String get syncStatusPushCompleteConflicts;

  /// No description provided for @syncStatusPullCompleteConflicts.
  ///
  /// In en, this message translates to:
  /// **'Pull completed (newer local changes were kept)'**
  String get syncStatusPullCompleteConflicts;

  /// No description provided for @syncStatusPullRemoteEmptyLocalKept.
  ///
  /// In en, this message translates to:
  /// **'Cloud is empty; local notes were kept (safety check)'**
  String get syncStatusPullRemoteEmptyLocalKept;

  /// No description provided for @syncUserId.
  ///
  /// In en, this message translates to:
  /// **'User: {userId}'**
  String syncUserId(String userId);

  /// No description provided for @syncPushDone.
  ///
  /// In en, this message translates to:
  /// **'Push complete: {upserts} updated, {deletes} removed, {skipped} conflicts skipped'**
  String syncPushDone(int upserts, int deletes, int skipped);

  /// No description provided for @syncPullDone.
  ///
  /// In en, this message translates to:
  /// **'Pull complete: {upserts} updated, {deletes} removed locally, {skipped} conflicts skipped'**
  String syncPullDone(int upserts, int deletes, int skipped);

  /// No description provided for @q1Title.
  ///
  /// In en, this message translates to:
  /// **'Important & Urgent'**
  String get q1Title;

  /// No description provided for @q2Title.
  ///
  /// In en, this message translates to:
  /// **'Important & Not Urgent'**
  String get q2Title;

  /// No description provided for @q3Title.
  ///
  /// In en, this message translates to:
  /// **'Not Important & Urgent'**
  String get q3Title;

  /// No description provided for @q4Title.
  ///
  /// In en, this message translates to:
  /// **'Not Important & Not Urgent'**
  String get q4Title;

  /// No description provided for @q1Label.
  ///
  /// In en, this message translates to:
  /// **'DO FIRST'**
  String get q1Label;

  /// No description provided for @q2Label.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULE'**
  String get q2Label;

  /// No description provided for @q3Label.
  ///
  /// In en, this message translates to:
  /// **'DELEGATE'**
  String get q3Label;

  /// No description provided for @q4Label.
  ///
  /// In en, this message translates to:
  /// **'DON\'T DO'**
  String get q4Label;

  /// No description provided for @q1TabSemantics.
  ///
  /// In en, this message translates to:
  /// **'Do first quadrant'**
  String get q1TabSemantics;

  /// No description provided for @q2TabSemantics.
  ///
  /// In en, this message translates to:
  /// **'Schedule quadrant'**
  String get q2TabSemantics;

  /// No description provided for @q3TabSemantics.
  ///
  /// In en, this message translates to:
  /// **'Delegate quadrant'**
  String get q3TabSemantics;

  /// No description provided for @q4TabSemantics.
  ///
  /// In en, this message translates to:
  /// **'Don\'t do quadrant'**
  String get q4TabSemantics;

  /// No description provided for @emptyQuadrant.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get emptyQuadrant;

  /// No description provided for @emptySearch.
  ///
  /// In en, this message translates to:
  /// **'No results for your search'**
  String get emptySearch;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// No description provided for @noteMoved.
  ///
  /// In en, this message translates to:
  /// **'Note moved'**
  String get noteMoved;

  /// No description provided for @requiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get requiredTitle;

  /// No description provided for @clearDueDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDueDate;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @doneChip.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneChip;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @loadDemoData.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get loadDemoData;

  /// No description provided for @loadDemoDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Replace local notes with curated demo content for screenshots.'**
  String get loadDemoDataDesc;

  /// No description provided for @demoDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count} demo notes loaded'**
  String demoDataLoaded(int count);

  /// No description provided for @resetLocalData.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get resetLocalData;

  /// No description provided for @resetLocalDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear all notes and settings saved on this device.'**
  String get resetLocalDataDesc;

  /// No description provided for @resetLocalDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset local data?'**
  String get resetLocalDataConfirmTitle;

  /// No description provided for @resetLocalDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove your notes and settings from this device.'**
  String get resetLocalDataConfirmBody;

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetAction;

  /// No description provided for @localDataResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local data has been reset'**
  String get localDataResetSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
