import 'package:flutter/material.dart';

/// Centralized theme helper utility for consistent theme-aware styling across the app.
///
/// Provides reusable methods to get appropriate colors based on current theme (light/dark).
/// All UI components should use these helpers instead of hardcoded colors to ensure
/// the app responds correctly to theme changes (light/dark mode).
///
/// Usage:
/// ```dart
/// Container(
///   color: ThemeHelper.getSurfaceColor(context),
///   child: Text(
///     'Hello',
///     style: TextStyle(color: ThemeHelper.getTextColor(context)),
///   ),
/// )
/// ```
class ThemeHelper {
  ThemeHelper._(); // Private constructor - utility class

  /// Get appropriate surface color based on theme (white in light, grey.900 in dark)
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get appropriate background color for main content areas
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get appropriate text color based on theme (dark text in light, white text in dark)
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get appropriate secondary text color (grey in light, lighter grey in dark)
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  /// Get appropriate border/divider color based on theme
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Get appropriate card background color based on theme
  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.white;
  }

  /// Get appropriate elevated surface color for modals and dialogs
  static Color getElevatedSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.white;
  }

  /// Check if current theme is dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get appropriate dropdown background color
  static Color getDropdownColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.white;
  }

  /// Get appropriate input fill color for text fields
  static Color getInputFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade50;
  }
}
