import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.spaceGroteskTextTheme().copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
      headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      bodyLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.hotRed,
        secondary: AppColors.vividYellow,
        surface: Colors.white,
        onSurface: AppColors.neoBlack,
      ),
      // Avoid M3 tint/shadow on solid neo buttons (fixes “glitched” fills in light mode).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      // ── Fix switch / checkbox light-mode rendering ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neoBlack;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.vividYellow;
          }
          return AppColors.neoBlack.withValues(alpha: 0.15);
        }),
        trackOutlineColor: WidgetStateProperty.all(AppColors.neoBlack),
        trackOutlineWidth: WidgetStateProperty.all(2),
        overlayColor:
            WidgetStateProperty.all(AppColors.hotRed.withValues(alpha: 0.12)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.hotRed;
          return Colors.white;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.neoBlack, width: 2.5),
        shape: const RoundedRectangleBorder(),
        overlayColor:
            WidgetStateProperty.all(AppColors.hotRed.withValues(alpha: 0.12)),
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.neoBlack,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme)
        .copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
      headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      bodyLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF171717),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.vividYellow,
        secondary: AppColors.softViolet,
        surface: Color(0xFF252525),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      // ── Dark-mode switch / checkbox ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF444444);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.softViolet;
          }
          return Colors.white.withValues(alpha: 0.18);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.white),
        trackOutlineWidth: WidgetStateProperty.all(2),
        overlayColor: WidgetStateProperty.all(
            AppColors.vividYellow.withValues(alpha: 0.12)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.softViolet;
          }
          return const Color(0xFF252525);
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Colors.white, width: 2.5),
        shape: const RoundedRectangleBorder(),
        overlayColor: WidgetStateProperty.all(
            AppColors.vividYellow.withValues(alpha: 0.12)),
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF171717),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
