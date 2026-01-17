import 'package:flutter/material.dart';

/// Reusable action buttons layout for modals with divider lines.
///
/// Displays a horizontal divider line above the buttons, then renders
/// the action buttons in a horizontal row with vertical dividers between them.
///
/// Similar to MaribankBudgetCard button pattern but adapted for modals.
/// Uses black dividers (subtle gradient/solid) to separate actions visually.
///
/// Example usage:
/// ```dart
/// ModalActionButtons(
///   actions: [
///     TextButton(onPressed: () {}, child: Text('Cancel')),
///     PrimaryButton(text: 'Submit', onPressed: () {}),
///   ],
/// )
/// ```
class ModalActionButtons extends StatelessWidget {
  final List<Widget> actions;

  const ModalActionButtons({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal divider above buttons
        _buildHorizontalDivider(),

        // Button row with vertical dividers (NO padding wrapper)
        IntrinsicHeight(
          child: Row(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                // Add vertical divider before each button except first
                if (i > 0) _buildVerticalDivider(),

                // Button
                Expanded(child: actions[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Horizontal divider line (black gradient, subtle)
  Widget _buildHorizontalDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.1),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  /// Vertical divider between buttons (black solid, subtle)
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.1),
    );
  }
}
