# Security Notes

## Firebase/API key exposure response

If Google sends an alert that an API key was publicly exposed, treat it as a key
rotation event.

1. In Google Cloud Console, open **APIs & Services > Credentials** for
   project `q4-board-prod`.
2. Find the leaked key and **Regenerate** it.
3. Add **application restrictions**:
   - Android key: restrict by package `dev.abdallahgaber.q4board` + SHA-1/SHA-256.
   - Apple/macOS key: restrict by bundle ID `dev.abdallahgaber.q4board`.
   - Web key: restrict by HTTP referrers (for example `localhost` and production domains).
4. Add **API restrictions** to only required Firebase APIs for this app.
5. Replace Firebase client config files:
   - `android/app/google-services.json`
   - `macos/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart` (via `flutterfire configure --project=q4-board-prod`)
6. Deploy and verify sign-in/sync on Web + Android + macOS.
7. Disable/delete old compromised key after rollout verification.

## Important clarification

Firebase client API keys are identifiers, not server secrets. They can appear in
client builds, but they still must be restricted to reduce abuse risk.

Never commit server credentials (service account JSON, private keys, OAuth
client secrets) into this repo.

## Preventive checklist

- Keep Firestore rules strict (`users/{uid}/notes/{noteId}` owner-only).
- Keep Firebase Auth provider/domain configuration up to date.
- Review Cloud Logging / billing after any alert.
- Rotate keys immediately when they appear in unintended public locations.
