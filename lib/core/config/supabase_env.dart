import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase credentials for the Flutter client.
///
/// **Priority (highest first):**
/// 1. `--dart-define=SUPABASE_URL` / `--dart-define=SUPABASE_ANON_KEY` (CI/prod builds)
/// 2. `assets/env/.env` (optional; merge over example — add file to `pubspec.yaml` assets)
/// 3. `assets/env/.env.example` (committed template; safe placeholders)
///
/// **Do not** put `postgresql://` session pooler URLs or DB passwords here — use those only
/// on a backend server. See [docs/ENV_SETUP.md](../../docs/ENV_SETUP.md).
class SupabaseEnv {
  SupabaseEnv._();

  static const String _urlDefine = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String _anonDefine = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static String get url {
    if (_urlDefine.trim().isNotEmpty) return _urlDefine.trim();
    final fromDot = dotenv.env['SUPABASE_URL']?.trim();
    if (fromDot != null && fromDot.isNotEmpty) return fromDot;
    return '';
  }

  static String get anonKey {
    if (_anonDefine.trim().isNotEmpty) return _anonDefine.trim();
    final fromDot = dotenv.env['SUPABASE_ANON_KEY']?.trim();
    if (fromDot != null && fromDot.isNotEmpty) return fromDot;
    return '';
  }

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
