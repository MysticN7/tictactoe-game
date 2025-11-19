import 'package:flutter/material.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';

class AppTheme {
  static ThemeData getTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return lightTheme;
      case AppThemeType.dark:
        return darkTheme;
      case AppThemeType.liquidGlow:
        return liquidGlowTheme;
    }
  }

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2196F3),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white.withAlpha((0.8 * 255).round()),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Roboto',
        color: Color(0xFF2196F3),
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        color: Color(0xFF212121),
        fontSize: 16.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2196F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF64B5F6),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0x1AFFFFFF),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Roboto',
        color: Color(0xFF64B5F6),
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
        fontSize: 16.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF64B5F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static final ThemeData liquidGlowTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF00FF9D), // Neon Green
    scaffoldBackgroundColor: const Color(0xFF050505), // Almost Black
    cardColor: const Color(0x1AFFFFFF),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Roboto',
        color: Color(0xFF00FF9D),
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Color(0xFF00FF9D), blurRadius: 12.0),
        ],
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
        fontSize: 16.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFF00FF9D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 8.0,
        shadowColor: const Color(0xFF00FF9D),
      ),
    ),
  );

  // Glass morphism colors for different themes (iOS 16 style)
  static Color getGlassColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return Colors.white.withAlpha((0.3 * 255).round());
      case AppThemeType.dark:
        return Colors.white.withAlpha((0.12 * 255).round());
      case AppThemeType.liquidGlow:
        return const Color(0xFF1A1A1A).withAlpha((0.4 * 255).round());
    }
  }

  static Color getGlassBorderColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return Colors.white.withAlpha((0.5 * 255).round());
      case AppThemeType.dark:
        return const Color(0xFF64B5F6).withAlpha((0.5 * 255).round());
      case AppThemeType.liquidGlow:
        return const Color(0xFF00FF9D).withAlpha((0.3 * 255).round());
    }
  }

  static List<Color> getGradientColors(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return [
          const Color(0xFFE3F2FD),
          const Color(0xFFBBDEFB),
          const Color(0xFF90CAF9),
        ];
      case AppThemeType.dark:
        return [
          const Color(0xFF0A0A0F),
          const Color(0xFF14141A),
          const Color(0xFF1A1A24),
          const Color(0xFF0F0F12),
        ];
      case AppThemeType.liquidGlow:
        return [
          const Color(0xFF000000),
          const Color(0xFF0A0A0A),
          const Color(0xFF111111),
        ];
    }
  }

  static Color getNeonGlowColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return const Color(0xFF2196F3);
      case AppThemeType.dark:
        return const Color(0xFF64B5F6);
      case AppThemeType.liquidGlow:
        return const Color(0xFF00FF9D);
    }
  }

  static Color getWinningLineColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return const Color(0xFF4CAF50);
      case AppThemeType.dark:
        return const Color(0xFF81C784);
      case AppThemeType.liquidGlow:
        return const Color(0xFFFF00FF); // Neon Magenta
    }
  }

  static List<Color> getGlassSurfaceColors(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return [
          Colors.white.withAlpha((0.30 * 255).round()),
          Colors.white.withAlpha((0.22 * 255).round()),
        ];
      case AppThemeType.dark:
        return [
          Colors.white.withAlpha((0.16 * 255).round()),
          Colors.white.withAlpha((0.10 * 255).round()),
        ];
      case AppThemeType.liquidGlow:
        return [
          const Color(0xFF2A2A2A).withAlpha((0.5 * 255).round()),
          const Color(0xFF1A1A1A).withAlpha((0.5 * 255).round()),
        ];
    }
  }

  static Color getBackgroundOverlayColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return Colors.white.withAlpha((0.08 * 255).round());
      case AppThemeType.dark:
        return Colors.black.withAlpha((0.12 * 255).round());
      case AppThemeType.liquidGlow:
        return const Color(0xFF00FF9D).withAlpha((0.05 * 255).round());
    }
  }
}

enum AppThemeType { light, dark, liquidGlow }

extension GameThemeModeExtension on GameThemeMode {
  AppThemeType toAppThemeType() {
    switch (this) {
      case GameThemeMode.light:
        return AppThemeType.light;
      case GameThemeMode.dark:
        return AppThemeType.dark;
      case GameThemeMode.liquidGlow:
        return AppThemeType.liquidGlow;
    }
  }
}
