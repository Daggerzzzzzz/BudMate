import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'modal_action_buttons.dart';

/// Reusable base modal component with consistent styling and backdrop blur.
///
/// Provides standard AlertDialog structure with blurred background effect following
/// Maribank design patterns. Used by AddBudgetModal, PayExpenseModal, and AddExpenseModal
/// for consistency. The backdrop blur (sigma 5.0) creates subtle focus on the modal while
/// maintaining visual context of the underlying screen.
///
/// Key responsibilities:
/// - Provide static show() method with backdrop blur for all modals
/// - Maintain consistent AlertDialog structure across app
/// - Support optional title icons for visual categorization
/// - Ensure scrollable content for long forms
class BaseModal extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget content;
  final List<Widget> actions;

  const BaseModal({
    super.key,
    required this.title,
    this.titleIcon,
    required this.content,
    required this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    // Responsive values based on screen size
    final padding = screenHeight < 600 ? 16.0 : 20.0;
    final margin = screenHeight < 600 ? 16.0 : 24.0;
    final titleSpacing = screenHeight < 600 ? 12.0 : 16.0;
    final buttonSpacing = screenHeight < 600 ? 16.0 : 20.0;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.6, // Max 60% of screen height
            maxWidth: 600, // Max width for larger screens
          ),
          margin: EdgeInsets.symmetric(horizontal: margin),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Material(
              borderRadius: BorderRadius.circular(28),
              elevation: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padded content section
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with optional icon - CENTERED
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (titleIcon != null) ...[
                              Icon(titleIcon, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              title,
                              style: theme.textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        SizedBox(height: titleSpacing),
                        // Content with maxHeight constraint
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.6 - 200, // Reserve space for title/buttons
                          ),
                          child: SingleChildScrollView(
                            child: content,
                          ),
                        ),
                        SizedBox(height: buttonSpacing),
                      ],
                    ),
                  ),
                  // Action buttons with dividers - OUTSIDE padding
                  ModalActionButtons(actions: actions),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
