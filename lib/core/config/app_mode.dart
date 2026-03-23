import 'package:flutter_dotenv/flutter_dotenv.dart';

/// When **true**, the app skips Supabase init and uses **demo mode** (offline flow:
/// name + username → home). Keep your `SUPABASE_*` keys in `.env` for later.
///
/// Enable via:
/// - `assets/env/.env`: `DEMO_MODE=true`
/// - or run: `flutter run --dart-define=DEMO_MODE=true`
class AppMode {
  AppMode._();

  static bool get isDemoMode {
    const fromDefine = String.fromEnvironment('DEMO_MODE', defaultValue: '');
    final d = fromDefine.trim().toLowerCase();
    if (d == 'true' || d == '1' || d == 'yes') return true;

    final v = dotenv.env['DEMO_MODE']?.trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }
}
