import 'package:flutter/material.dart';

/// Secondary action button component with loading and disabled states.
///
/// This widget provides consistent styling for secondary actions across the app
/// following Material Design 3 guidelines. Uses outlined button style to visually
/// differentiate from primary actions. Supports loading state with spinner,
/// disabled state, and optional leading icon.
///
/// Button states:
/// - Enabled: onPressed != null, full opacity
/// - Disabled: onPressed == null, reduced opacity
/// - Loading: shows CircularProgressIndicator, disabled
///
/// Use for secondary actions like 'Cancel', 'Resend', 'Skip' on forms and dialogs.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}
