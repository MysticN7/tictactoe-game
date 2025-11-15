import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData liquidGlowTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF00FFFF),
    scaffoldBackgroundColor: const Color(0xFF0D0D2B),
    cardColor: const Color(0x1AFFFFFF),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Neon', color: Color(0xFF00FFFF), fontSize: 48.0),
      bodyLarge: TextStyle(fontFamily: 'Exo', color: Colors.white, fontSize: 16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFF50057),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: const BorderSide(color: Color(0xFF00FFFF), width: 2.0),
        ),
      ),
    ),
  );
}
