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
    cardColor: Colors.white.withOpacity(0.8),
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
    primaryColor: const Color(0xFF00FFFF),
    scaffoldBackgroundColor: const Color(0xFF0D0D2B),
    cardColor: const Color(0x1AFFFFFF),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Roboto',
        color: Color(0xFF00FFFF),
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
        backgroundColor: const Color(0xFFF50057),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: const BorderSide(color: Color(0xFF00FFFF), width: 2.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  // Glass morphism colors for different themes
  static Color getGlassColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return Colors.white.withOpacity(0.25);
      case AppThemeType.dark:
        return Colors.white.withOpacity(0.1);
      case AppThemeType.liquidGlow:
        return Colors.white.withOpacity(0.15);
    }
  }

  static Color getGlassBorderColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return Colors.white.withOpacity(0.4);
      case AppThemeType.dark:
        return Colors.white.withOpacity(0.2);
      case AppThemeType.liquidGlow:
        return const Color(0xFF00FFFF).withOpacity(0.5);
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
          const Color(0xFF1A1A1A),
          const Color(0xFF2D2D2D),
          const Color(0xFF1A1A1A),
        ];
      case AppThemeType.liquidGlow:
        return [
          const Color(0xFF0D0D2B),
          const Color(0xFF1A1A3E),
          const Color(0xFF2D1B4E),
          const Color(0xFF4A148C),
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
        return const Color(0xFF00FFFF);
    }
  }

  static Color getWinningLineColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return const Color(0xFF4CAF50);
      case AppThemeType.dark:
        return const Color(0xFF81C784);
      case AppThemeType.liquidGlow:
        return const Color(0xFFFF00FF);
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
