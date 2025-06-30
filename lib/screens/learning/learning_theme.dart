import 'package:flutter/material.dart';

class LearningTheme {
  // --- A more modern, calm, and sophisticated color palette ---
  static const Color background = Color(0xFF16181D); // Deep, cool navy
  static const Color surface = Color(0xFF1F222A);   // Slightly lighter surface
  static const Color card = Color(0xFF292E39);       // For cards and elevated items

  // A single, vibrant accent for focus points
  static const Color accent = Color(0xFF00B2FF); // Electric Blue

  // Text colors for clarity and hierarchy
  static const Color textPrimary = Color(0xFFEAEBF0);   // Soft white
  static const Color textSecondary = Color(0xFF8A91A0); // Grey for hints/subtitles

  // Bubble colors for clear conversation flow
  static const Color userBubble = Color(0xFF292E39);
  static const Color aiBubble = Color(0xFF1F222A);
  static const Color errorBubble = Color(0xFF4F2B30);

  // Gradient for the accent color
  static LinearGradient get accentGradient => LinearGradient(
        colors: [accent, Color.lerp(accent, Colors.black, 0.3)!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // --- Main Theme Data ---
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: accent,
        scaffoldBackgroundColor: background,
        cardColor: card,
        fontFamily: 'Inter', // For a modern feel (add to pubspec.yaml if you have it)
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: surface,
          background: background,
          error: Color(0xFFF8526A),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.4),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // --- Common Decorations ---
  static BoxDecoration get inputDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(30),
      );

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}