import 'package:flutter/material.dart';

/// App-wide theme mode notifier.
/// Starts with [ThemeMode.system]; the profile toggle switches between
/// [ThemeMode.light] and [ThemeMode.dark].
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  bool get isDark => value == ThemeMode.dark;

  void toggle(bool dark) => value = dark ? ThemeMode.dark : ThemeMode.light;

  /// Sync initial value with current platform brightness (called once at app
  /// start so the profile toggle reflects the actual state).
  void syncWithPlatform(Brightness platformBrightness) {
    if (value == ThemeMode.system) {
      value = platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    }
  }
}

/// Single global instance — simple and sufficient for this app.
final themeNotifier = ThemeNotifier();
