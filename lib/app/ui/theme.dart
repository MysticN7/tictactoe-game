import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/settings_provider.dart';

enum AppThemeType { liquidGlass, nebula, crystal }

extension AppThemeTypeExtension on AppThemeType {
  String get name {
    switch (this) {
      case AppThemeType.liquidGlass: return 'Liquid Glass';
      case AppThemeType.nebula: return 'Nebula';
      case AppThemeType.crystal: return 'Crystal';
    }
  }
}

extension GameThemeModeExtension on GameThemeMode {
  AppThemeType toAppThemeType() {
    switch (this) {
      case GameThemeMode.light: return AppThemeType.crystal;
      case GameThemeMode.dark: return AppThemeType.nebula;
      case GameThemeMode.liquidGlow: return AppThemeType.liquidGlass;
    }
  }
}

class AppTheme {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return _liquidGlassTheme;
      case AppThemeType.nebula:
        return _nebulaTheme;
      case AppThemeType.crystal:
        return _crystalTheme;
    }
  }

  // --- Theme Definitions ---

  static final ThemeData _liquidGlassTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0A84FF), // iOS Blue-ish
    scaffoldBackgroundColor: const Color(0xFF000000),
    textTheme: GoogleFonts.sfProDisplayTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0A84FF),
      secondary: Color(0xFF5E5CE6),
      surface: Color(0xFF1C1C1E),
    ),
  );

  static final ThemeData _nebulaTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFBF5AF2), // Purple
    scaffoldBackgroundColor: const Color(0xFF0D0D2B),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFBF5AF2),
      secondary: Color(0xFF64D2FF),
      surface: Color(0xFF151522),
    ),
  );

  static final ThemeData _crystalTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF30D158), // Green
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF30D158),
      secondary: Color(0xFF0A84FF),
      surface: Color(0xFFFFFFFF),
    ),
  );

  // --- Dynamic Properties ---

  static List<Color> getGradientColors(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return [const Color(0xFF2E2E40), const Color(0xFF050505)];
      case AppThemeType.nebula:
        return [const Color(0xFF2E0249), const Color(0xFF000000)];
      case AppThemeType.crystal:
        return [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)];
    }
  }

  static Color getBackgroundOverlayColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return Colors.black.withOpacity(0.3);
      case AppThemeType.nebula:
        return const Color(0xFF1A0B2E).withOpacity(0.4);
      case AppThemeType.crystal:
        return Colors.white.withOpacity(0.1);
    }
  }

  static List<Color> getGlassSurfaceColors(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.06)];
      case AppThemeType.nebula:
        return [const Color(0xFF6A4C93).withOpacity(0.15), const Color(0xFF6A4C93).withOpacity(0.05)];
      case AppThemeType.crystal:
        return [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0.4)];
    }
  }

  static Color getGlassBorderColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return Colors.white.withOpacity(0.15);
      case AppThemeType.nebula:
        return const Color(0xFFBF5AF2).withOpacity(0.3);
      case AppThemeType.crystal:
        return Colors.white.withOpacity(0.8);
    }
  }

  static Color getGlassColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return const Color(0xFF1C1C1E).withOpacity(0.6);
      case AppThemeType.nebula:
        return const Color(0xFF2D1B4E).withOpacity(0.6);
      case AppThemeType.crystal:
        return const Color(0xFFFFFFFF).withOpacity(0.65);
    }
  }

  static Color getNeonGlowColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return const Color(0xFF0A84FF);
      case AppThemeType.nebula:
        return const Color(0xFFBF5AF2);
      case AppThemeType.crystal:
        return const Color(0xFF30D158);
    }
  }

  static Color getWinningLineColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.liquidGlass:
        return const Color(0xFF32D74B); // iOS Green
      case AppThemeType.nebula:
        return const Color(0xFFFFD60A); // Yellow
      case AppThemeType.crystal:
        return const Color(0xFFFF375F); // Pink
    }
  }
  
  static Color getTextColor(AppThemeType type) {
     switch (type) {
      case AppThemeType.liquidGlass:
      case AppThemeType.nebula:
        return Colors.white;
      case AppThemeType.crystal:
        return Colors.black87;
    }
  }
}
