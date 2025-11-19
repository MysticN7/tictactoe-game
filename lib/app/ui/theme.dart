import 'package:flutter/material.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';

enum AppThemeType {
  glassmorphism,
  liquidGlass,
  neonGlass,
}

extension ThemeModeExtension on GameThemeMode {
  AppThemeType toAppThemeType() {
    switch (this) {
      case GameThemeMode.glassmorphism:
        return AppThemeType.glassmorphism;
      case GameThemeMode.neonGlass:
        return AppThemeType.neonGlass;
      case GameThemeMode.liquidGlass:
        return AppThemeType.liquidGlass;
    }
  }
}

class AppTheme {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.glassmorphism:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blueAccent,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto', // Or your custom font
          useMaterial3: true,
        );
      case AppThemeType.liquidGlass:
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.cyanAccent,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Roboto',
          useMaterial3: true,
        );
      case AppThemeType.neonGlass:
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.purpleAccent,
          scaffoldBackgroundColor: const Color(0xFF050510),
          fontFamily: 'Roboto',
          useMaterial3: true,
        );
    }
  }

  static List<Color> getGradientColors(AppThemeType type) {
    switch (type) {
      case AppThemeType.glassmorphism:
        return [
          const Color(0xFFE0C3FC), // Soft Purple
          const Color(0xFF8EC5FC), // Soft Blue
        ];
      case AppThemeType.liquidGlass:
        return [
          const Color(0xFF0F2027), // Deep Dark Blue
          const Color(0xFF203A43),
          const Color(0xFF2C5364), // Liquid Blue-Grey
        ];
      case AppThemeType.neonGlass:
        return [
          const Color(0xFF240b36), // Deep Purple
          const Color(0xFFc31432), // Neon Red/Pink
        ];
    }
  }

  static Color getGlassColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.glassmorphism:
        return Colors.white.withOpacity(0.25);
      case AppThemeType.liquidGlass:
        return Colors.white.withOpacity(0.12);
      case AppThemeType.neonGlass:
        return Colors.black.withOpacity(0.4);
    }
  }

  static Color getGlassBorderColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.glassmorphism:
        return Colors.white.withOpacity(0.6);
      case AppThemeType.liquidGlass:
        return Colors.cyanAccent.withOpacity(0.3);
      case AppThemeType.neonGlass:
        return Colors.purpleAccent.withOpacity(0.5);
    }
  }

  static List<Color> getGlassSurfaceColors(AppThemeType type) {
    switch (type) {
      case AppThemeType.glassmorphism:
        return [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.1),
        ];
      case AppThemeType.liquidGlass:
        return [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ];
      case AppThemeType.neonGlass:
        return [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.02),
        ];
    }
  }

  static Color getBackgroundOverlayColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.glassmorphism:
        return Colors.white.withOpacity(0.1);
      case AppThemeType.liquidGlass:
        return Colors.black.withOpacity(0.3);
      case AppThemeType.neonGlass:
        return Colors.black.withOpacity(0.6);
    }
  }

  static Color getNeonGlowColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.glassmorphism:
        return Colors.blueAccent;
      case AppThemeType.liquidGlass:
        return Colors.cyanAccent;
      case AppThemeType.neonGlass:
        return Colors.purpleAccent;
    }
  }
  
  static Color getWinningLineColor(AppThemeType type) {
     switch (type) {
      case AppThemeType.glassmorphism:
        return Colors.deepPurpleAccent;
      case AppThemeType.liquidGlass:
        return Colors.cyanAccent;
      case AppThemeType.neonGlass:
        return Colors.amberAccent;
    }
  }
}
