import 'package:flutter/material.dart';
import '../../core/utils/theme_helper.dart';

/// Reusable settings list item widget following Mari Bank design pattern.
///
/// Creates a consistent list item layout for settings screens with:
/// - Leading icon in colored CircleAvatar
/// - Title and optional subtitle text
/// - Trailing widget (value text, switch, or arrow icon)
/// - Optional onTap callback for navigation
/// - Optional horizontal divider
///
/// Design matches existing ExpenseListItem pattern with responsive padding
/// and Material Design 3 styling. Uses NO hardcoded pixel values for consistency.
///
/// Example usage:
/// ```dart
/// SettingsListItem(
///   icon: Icons.language,
///   iconColor: Colors.blue.shade600,
///   title: 'Language',
///   subtitle: 'Choose your language',
///   trailing: Row(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       Text('English'),
///       Icon(Icons.chevron_right),
///     ],
///   ),
///   onTap: () => showLanguagePicker(),
/// )
/// ```
class SettingsListItem extends StatelessWidget {
  /// Icon to display in the leading CircleAvatar
  final IconData icon;

  /// Color for the icon and CircleAvatar background (15% opacity)
  final Color iconColor;

  /// Main title text (bold, 15sp)
  final String title;

  /// Optional subtitle text (grey, 13sp)
  final String? subtitle;

  /// Trailing widget (e.g., value text, Switch, or chevron icon)
  final Widget? trailing;

  /// Callback when item is tapped (if null, item is not tappable)
  final VoidCallback? onTap;

  /// Whether to show horizontal divider below item (default: true)
  final bool showDivider;

  const SettingsListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Leading icon in CircleAvatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title and optional subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeHelper.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget (value, switch, or arrow)
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),

        // Optional divider
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: ThemeHelper.getBorderColor(context),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
