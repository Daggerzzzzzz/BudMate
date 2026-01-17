import 'package:flutter/material.dart';

/// Material Design 3 theme configuration for BudMate financial tracking app.
///
/// Provides centralized theme configuration with financial-focused color palette
/// optimized for budget tracking, expense management, and spending alerts.
///
/// Includes both light and dark themes for user preference.
///
/// Color semantics:
/// - Primary (teal): Budgets, positive actions, navigation
/// - Error (red): Over-budget alerts, critical warnings, delete actions
/// - Success (green): Under-budget status, successful operations
/// - Warning (orange): 90% threshold alerts, approaching limits
///
/// Typography uses Roboto for readability with monospace for currency amounts.
/// All spacing and sizing follows Material Design 3 guidelines for consistency.
class AppTheme {
  AppTheme._(); // Private constructor (utility class)

  // Financial-specific colors not in Material ColorScheme
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFF57C00);

  // Dark theme success and warning colors (brighter for visibility)
  static const Color successGreenDark = Color(0xFF66BB6A);
  static const Color warningOrangeDark = Color(0xFFFF9800);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: Colors.teal.shade600,
      primaryContainer: Colors.teal.shade100,
      secondary: Colors.teal.shade400,
      secondaryContainer: Colors.teal.shade50,
      error: Colors.red.shade700,
      errorContainer: Colors.red.shade100,
      surface: Colors.white,
      surfaceContainerHighest: Colors.grey.shade100,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: Colors.grey.shade900,
      outline: Colors.grey.shade300,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Colors.teal.shade400,
      primaryContainer: Colors.teal.shade700,
      secondary: Colors.teal.shade300,
      secondaryContainer: Colors.teal.shade800,
      error: Colors.red.shade400,
      errorContainer: Colors.red.shade800,
      surface: Colors.grey.shade900,
      surfaceContainerHighest: Colors.grey.shade800,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onError: Colors.black,
      onSurface: Colors.white,
      outline: Colors.grey.shade700,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade700,
      thickness: 1,
      space: 1,
    ),
  );
}
