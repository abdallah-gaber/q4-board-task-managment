# Contributing

## Setup

```bash
flutter pub get
flutter analyze
flutter test
flutter test integration_test/app_smoke_test.dart -d macos
# Optional (requires Firebase Emulator Suite running)
flutter test integration_test/firebase_sync_emulator_test.dart -d macos --dart-define=RUN_FIREBASE_EMULATOR_SYNC_TEST=true
```

## Firebase (Phase 2) Local Setup

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=q4-board-prod
```

The repo may include a placeholder `lib/firebase_options.dart` for local-only mode.
Replace it with the generated FlutterFire file when working on cloud features.

### Provider auth (Google / Email) for cross-device sync

- Anonymous auth is not portable across devices. Use Google or Email/Password for real cross-device sync.
- After enabling Google sign-in in Firebase Auth, Firebase creates OAuth clients and you must refresh config files:
  - add Android SHA-1/SHA-256 fingerprints (via `./gradlew signingReport`)
  - replace `android/app/google-services.json`
  - replace `macos/Runner/GoogleService-Info.plist`
  - rerun `flutterfire configure --project=q4-board-prod`
- Add deployed web domains (e.g. `q4.abdallahgaber.dev`) to Firebase Auth authorized domains.
- For macOS Google sign-in, add `REVERSED_CLIENT_ID` URL scheme in `macos/Runner/Info.plist` if sign-in does not return to the app.

## Firestore Rules

- Rules are defined in `firestore.rules`.
- Deploy before testing sync:

```bash
firebase deploy --only firestore:rules
```

## Firebase Emulator Sync Test (Phase 2)

Start the local emulators before running the emulator integration test:

```bash
firebase emulators:start --only auth,firestore
```

The test is skipped by default unless `RUN_FIREBASE_EMULATOR_SYNC_TEST=true` is provided.

## Development Guidelines

- Keep changes scoped and reviewable.
- Add/update localization strings for user-facing text.
- Add tests for logic/data behavior changes.
- Keep UI changes consistent with existing design tokens.
- Update docs when user-facing behavior, developer workflow, or assets change.

## Branding / Visual Assets

Temporary branding assets are generated in-repo.

```bash
# Requires ImageMagick (`magick`).
./tool/generate_branding_assets.sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

If macOS integration tests fail with a codesign "resource fork / Finder information" error, run them from a non-cloud-synced path (OneDrive/iCloud metadata can contaminate the built app bundle).

## Pull Requests

- Use clear PR titles and summaries.
- Include screenshots for visible UI changes.
- Confirm `flutter analyze` and `flutter test` pass locally.
- Prefer adding/maintaining integration smoke tests for critical user flows.
- For sync changes, cover timeout/retry and preference-driven behavior in controller tests.
- For sync changes, also verify conflict activity entries and any auto-sync behavior (debounce/suppression) in controller tests.
