// utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFF4DABF7);
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color surfaceColor = Color(0xFF161B22);
  static const Color cardColor = Color(0xFF1C2333);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF51CF66);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: accentColor,
          surface: surfaceColor,
          error: errorColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF30363D)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF30363D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor, width: 2),
          ),
          hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
          labelStyle: const TextStyle(color: textSecondary),
          errorStyle: const TextStyle(color: errorColor, fontSize: 12),
          prefixIconColor: textSecondary,
          suffixIconColor: textSecondary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentColor,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primaryColor;
            return Colors.transparent;
          }),
          side: const BorderSide(color: textSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(
              color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(
              color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          labelLarge: TextStyle(
              color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
}
