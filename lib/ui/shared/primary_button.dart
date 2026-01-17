import 'package:flutter/material.dart';

/// Primary action button component with loading and disabled states.
///
/// This widget provides consistent styling for primary actions across the app
/// following Material Design 3 guidelines. Supports loading state with spinner,
/// disabled state, and optional leading icon.
///
/// Button states:
/// - Enabled: onPressed != null, full opacity
/// - Disabled: onPressed == null, reduced opacity
/// - Loading: shows CircularProgressIndicator, disabled
///
/// Use for primary actions like 'Save', 'Create', 'Submit' on forms and dialogs.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: backgroundColor != null
            ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
            : null,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
