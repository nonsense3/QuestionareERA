# Questioare ERA

Flutter app for Questioare ERA (quiz, chat, community, rewards).

## Supabase & secrets

1. Copy `assets/env/.env.example` → `assets/env/.env` and fill `SUPABASE_URL` + `SUPABASE_ANON_KEY`.
2. Uncomment `- assets/env/.env` in `pubspec.yaml` under `flutter: assets:` so the app can load your keys.
3. **Demo mode (offline):** set `DEMO_MODE=true` in `assets/env/.env` to skip Supabase while you work on UI. Set `false` when you want real sign-in again.
4. Read **[docs/ENV_SETUP.md](docs/ENV_SETUP.md)** and **[SECURITY.md](SECURITY.md)** for what belongs in the app vs. on a server (PostgreSQL session pooler URL, etc.).

Run without a file using defines:

`flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
