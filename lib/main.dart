import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_mode.dart';
import 'core/config/supabase_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnv();

  // Skip Supabase while building UI — set DEMO_MODE=true in assets/env/.env
  if (AppMode.isDemoMode) {
    if (kDebugMode) {
      debugPrint('DEMO_MODE: using offline demo (Supabase not initialized).');
    }
    runApp(const QuestioareEraApp(supabaseReady: false));
    return;
  }

  var supabaseReady = false;
  if (SupabaseEnv.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseEnv.url,
        anonKey: SupabaseEnv.anonKey,
      );
      supabaseReady = true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Supabase.initialize failed: $e');
        debugPrint('$st');
      }
      supabaseReady = false;
    }
  }
  runApp(QuestioareEraApp(supabaseReady: supabaseReady));
}

/// Loads template first, then optional local `assets/env/.env` (if present and listed in pubspec).
Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: 'assets/env/.env.example');
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Could not load assets/env/.env.example: $e');
    }
  }
  try {
    await dotenv.load(
      fileName: 'assets/env/.env',
      mergeWith: dotenv.env,
      isOptional: true,
    );
  } catch (_) {}
}
