# Q4 Board — Eisenhower Matrix

Q4 Board is a bilingual productivity app based on the Eisenhower Matrix.
Arabic name: **لوحة الأولويات (مصفوفة آيزنهاور)**.

It helps you classify tasks into 4 quadrants and prioritize execution with a sticky-note board experience.

## Live Demo

- Web (Vercel): [q4.abdallahgaber.dev](https://q4.abdallahgaber.dev/)

## Features (Phase 1)

- Local-first storage with Hive (offline by default)
- 4-quadrant Eisenhower board (Q1/Q2/Q3/Q4)
- Manual drag/reorder with persisted ordering
- Move notes between quadrants
- Search across notes
- Show/hide done filtering
- Undo for delete and move actions
- Arabic/English localization (RTL support)
- Light/Dark/System themes
- Responsive UX for web/mobile/desktop

## Phase 2 (In Progress)

- Firebase anonymous authentication (settings-driven sign in/out)
- Provider sign-in options (Google + Email/Password) for cross-device sync (Phase 2b in progress)
- Firestore cloud sync with manual actions (Push / Pull)
- Live sync listener after sign-in (remote changes pulled automatically)
- Auto-pull on app resume with throttling
- Persisted sync preferences (cloud on/off, live sync, resume auto-sync)
- Optional debounced auto-push for local changes (default off)
- Persisted last-sync summary in Settings
- Recent sync activity history with conflict details
- Local-only fallback when Firebase is not configured yet

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- Hive
- Flutter i18n (`arb`)

## Getting Started

### Prerequisites

- Flutter SDK installed
- A device/emulator/simulator for your target platform

### Install dependencies

```bash
flutter pub get
```

### Firebase setup (Phase 2)

Phase 2 code is wired, but the repo intentionally ships with a placeholder
`lib/firebase_options.dart` so the app remains runnable in local-only mode.

Configure Firebase for project `q4-board-prod`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=q4-board-prod
```

Then replace the placeholder `lib/firebase_options.dart` with the generated file.

### Cross-device sync note (important)

Anonymous auth is useful for testing and guest usage, but it is **not portable across devices**.  
For real cross-device sync, sign in with a persistent provider (Google or Email/Password).

### Google sign-in setup (Android/macOS/Web)

If Firebase shows a dialog asking you to download updated config files after enabling Google sign-in, do this:

1. Add Android SHA fingerprints in Firebase:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the **SHA-1** (and recommended SHA-256) for your app into Firebase Project Settings > Your Android app (`dev.abdallahgaber.q4board`).
2. Download and replace `android/app/google-services.json`.
3. Download and replace `macos/Runner/GoogleService-Info.plist`.
4. Re-run FlutterFire config so `lib/firebase_options.dart` includes the new OAuth clients:
   ```bash
   flutterfire configure --project=q4-board-prod
   ```
5. Add your deployed web domain to Firebase Auth authorized domains (for example `q4.abdallahgaber.dev`).

For macOS Google sign-in, you may also need to add the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` as a URL scheme in `macos/Runner/Info.plist`.

### Firestore rules (required for sync)

Deploy the included production-oriented rules before using Push/Pull sync:

```bash
firebase deploy --only firestore:rules
```

Rules file:
- `firestore.rules`

### Firebase Emulator smoke test (sync)

Start emulators:

```bash
firebase emulators:start --only auth,firestore
```

Run the emulator sync roundtrip test (disabled by default unless enabled):

```bash
flutter test integration_test/firebase_sync_emulator_test.dart -d macos \
  --dart-define=RUN_FIREBASE_EMULATOR_SYNC_TEST=true
```

### Run (Web)

```bash
flutter run -d chrome
```

### Run (Android)

```bash
flutter run -d android
```

### Run (iOS)

```bash
flutter run -d ios
```

### Run (macOS)

```bash
flutter run -d macos
```

## Project Structure

```text
lib/
  core/          # app-wide theme, routing, design tokens, helpers
  domain/        # entities + repository/service contracts
  data/          # Hive models/adapters + repository implementations
  features/      # board, note editor, settings
  l10n/          # ARB files + generated localization output

integration_test/ # end-to-end / smoke test flows

Docs/
  docs/          # roadmap, architecture, decisions, contributing
```

## Screenshots

### Web — Light Mode

<p align="center">
  <img src="docs/screenshots/board_light.png" alt="Q4 Board Web Light Mode" width="960">
</p>

### Web — Dark Mode

<p align="center">
  <img src="docs/screenshots/board_dark.png" alt="Q4 Board Web Dark Mode" width="960">
</p>

### Mobile — Android

<p align="center">
  <img src="docs/screenshots/mobile_quadrants.png" alt="Q4 Board Mobile Android Screenshot" width="360">
</p>

## Branding Assets (Temporary)

This repo currently uses a temporary generated Q4 mark for app icon/splash branding.

Generate branding source assets:

```bash
# Requires ImageMagick (`magick`) installed locally.
./tool/generate_branding_assets.sh
```

Regenerate platform icons and splash assets:

```bash
dart run flutter_launcher_icons
# Android + Web native splash (plugin config currently excludes iOS/macOS)
dart run flutter_native_splash:create
```

## Roadmap

- **Phase 1**: Local-first MVP (done)
- **Phase 2**: Authentication + cloud sync (in progress)
- **Later phases**: richer planning workflows, productivity insights, and integrations

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for details.
Deployment/setup checklist: [`docs/PHASE2_ROLLOUT_CHECKLIST.md`](docs/PHASE2_ROLLOUT_CHECKLIST.md)
Security guidance: [`docs/SECURITY.md`](docs/SECURITY.md)

## Known Issues

- Desktop/Web drag can still show a visual jump/snap at drag start in some cases. This is tracked and will be improved in a coming UI iteration.
- Minor drag-feel differences may appear across browsers because pointer/drag behavior differs by engine.
- macOS native splash customization is limited in the current generator setup; Android/Web splash is branded, macOS currently relies on icon + default startup window.
- Firestore sync supports manual `Push` / `Pull` plus a live listener (remote-to-local) after sign-in.
- Auto-push local changes is optional and disabled by default pending product approval.
- If Push/Pull returns `permission-denied`, your Firestore rules are blocking `users/{uid}/notes/{noteId}` for the signed-in user.

## Quality Checks

```bash
flutter analyze
flutter test
flutter test integration_test/app_smoke_test.dart -d macos
flutter test integration_test/firebase_sync_emulator_test.dart -d macos --dart-define=RUN_FIREBASE_EMULATOR_SYNC_TEST=true
```

Note: `integration_test` on macOS can fail when the repo is inside a cloud-synced folder (for example OneDrive) because injected file metadata may break codesigning of the temporary app bundle.
