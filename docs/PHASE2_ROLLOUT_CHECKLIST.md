# Phase 2 Rollout Checklist (Firebase Auth + Sync)

Use this checklist before enabling cloud sync for broader testing or production users.

## Firebase Project Setup

- [ ] Firebase project selected: `q4-board-prod`
- [ ] Firestore database created (Native mode)
- [ ] Authentication enabled: **Anonymous**
- [ ] Authentication enabled: **Email/Password** (for portable cross-device sync)
- [ ] Authentication enabled: **Google**
- [ ] FlutterFire configured and `lib/firebase_options.dart` generated for this repo
- [ ] Android app package registered as `dev.abdallahgaber.q4board`
- [ ] macOS app bundle identifier registered as `dev.abdallahgaber.q4board` (if using macOS build)
- [ ] Android SHA-1 (and SHA-256 recommended) fingerprints added in Firebase Project Settings
- [ ] Re-download and replace config files after enabling Google sign-in:
  - [ ] `android/app/google-services.json`
  - [ ] `macos/Runner/GoogleService-Info.plist`
- [ ] Firebase Auth authorized domains include deployed web domain (e.g. `q4.abdallahgaber.dev`)

## Security Rules

- [ ] `firestore.rules` reviewed
- [ ] Rules deployed:

```bash
firebase deploy --only firestore:rules
```

- [ ] Verify anonymous user can only access `users/{uid}/notes/*`
- [ ] Verify invalid schema writes are rejected (missing title / invalid quadrant / bad timestamps)

## App Behavior Verification

- [ ] Guest sign-in works (anonymous)
- [ ] Google sign-in works
- [ ] Email/password sign-in works
- [ ] Email/password account creation works
- [ ] Guest account can be upgraded/linked to Google or Email/Password
- [ ] Sign in succeeds from Settings
- [ ] Manual `Push` uploads local notes
- [ ] Manual `Pull` restores notes on a clean device/profile
- [ ] Live sync applies remote edits after sign-in
- [ ] Auto sync on app resume works and is throttled
- [ ] Retry button recovers from transient failures
- [ ] Permission/network/auth errors show actionable UI messages
- [ ] Recent sync activity entries appear with counts and conflict details
- [ ] Conflict details sheet lists affected note IDs

## Sync Preferences Verification

- [ ] Cloud sync toggle disables actions and live sync when off
- [ ] Live sync toggle persists across restart
- [ ] Auto sync on resume toggle persists across restart
- [ ] Auto push local changes (default off) persists across restart
- [ ] Last sync summary persists across restart

## Emulator Test Path (Recommended)

Start emulators:

```bash
firebase emulators:start --only auth,firestore
```

Run the emulator integration test (disabled by default unless the flag is set):

```bash
flutter test integration_test/firebase_sync_emulator_test.dart \
  -d macos \
  --dart-define=RUN_FIREBASE_EMULATOR_SYNC_TEST=true \
  --dart-define=FIREBASE_EMULATOR_HOST=127.0.0.1 \
  --dart-define=FIRESTORE_EMULATOR_PORT=8080 \
  --dart-define=FIREBASE_AUTH_EMULATOR_PORT=9099
```

## Release Readiness Notes

- Keep **auto push local changes** off by default until product behavior is approved.
- Prefer testing in a non-cloud-synced local path for macOS integration tests (codesign may fail in OneDrive/iCloud-backed folders).
- If Firebase is unavailable or misconfigured, the app should remain usable in local-only mode.
