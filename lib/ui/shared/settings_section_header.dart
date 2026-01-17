import 'package:flutter/material.dart';

/// Section header for grouping settings in the profile screen.
///
/// Displays a left-aligned title text with consistent styling and padding.
/// Used to separate different categories of settings like "Preferences" and "Account".
///
/// Design:
/// - Left-aligned text
/// - Grey color (theme.textTheme.titleSmall)
/// - Bold font weight
/// - Padding: 16px horizontal, 16px top, 8px bottom
///
/// Example usage:
/// ```dart
/// SettingsSectionHeader(title: 'Preferences'),
/// SettingsListItem(...),
/// SettingsListItem(...),
/// ```
class SettingsSectionHeader extends StatelessWidget {
  /// The section title text
  final String title;

  const SettingsSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
      ),
    );
  }
}
