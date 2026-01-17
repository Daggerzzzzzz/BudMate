import 'package:flutter/material.dart';

/// Plain text button for modal actions - no elevation, no outline.
///
/// Used in modals for both primary and secondary actions.
/// Simple text + optional icon layout with no background or elevation.
///
/// The `isPrimary` flag controls visual styling:
/// - Primary: Bold text + colored (primary color)
/// - Secondary: Normal weight + default color
///
/// Example usage:
/// ```dart
/// ModalTextButton(
///   text: 'Add Budget',
///   isPrimary: true,
///   isLoading: false,
///   onPressed: () {},
/// )
/// ```
class ModalTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;

  const ModalTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        // No minimum size constraints that cause overflow
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: onPressed == null
                    ? Colors.grey.shade400
                    : (isPrimary
                        ? Theme.of(context).colorScheme.primary
                        : null),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
