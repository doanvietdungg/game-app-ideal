import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFFFFB347); // Peach Orange
  static const secondary = Color(0xFFA8E6CF); // Mint Green
  static const accent = Color(0xFFFFD3E8); // Baby Pink
  static const background = Color(0xFFFFFBF0); // Warm White
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF3D2B1F); // Warm Brown
  static const textLight = Color(0xFF8B7355);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: text,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: textLight,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2D6C5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
