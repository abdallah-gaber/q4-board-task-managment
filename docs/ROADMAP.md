# Roadmap

## Phase 1 (Completed / Ongoing polish)

- Local-first Eisenhower board
- Hive persistence
- Responsive board UX
- AR/EN localization
- Theme switching
- Ongoing UI polish (icons, splash, docs, test hardening)

## Phase 2 (In Progress)

- Firebase anonymous auth integration
- Firestore-backed manual sync (Push / Pull)
- Live remote-to-local sync listener and app-resume auto-pull
- Conflict handling basics (last-write-wins with safety checks)
- Selective sync controls and persisted sync status metadata
- Conflict activity history + per-note conflict details in Settings
- Optional auto-push for local changes (debounced; default off)
- Next: provider auth portability (Google + Email/Password) with anonymous account upgrade/linking UX
- Next: emulator-backed sync CI/test automation and conflict resolution UX (beyond last-write-wins visibility)

## Phase 3+ (Candidate)

- Advanced reporting and insights
- Keyboard-first desktop flows
- Optional integrations (calendar/export)
