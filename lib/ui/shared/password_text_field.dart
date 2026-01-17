import 'package:flutter/material.dart';

/// Reusable password input field with visibility toggle and validation.
///
/// This widget provides a Material Design 3 text field for password input with
/// show/hide functionality, optional strength validation, and visual feedback.
/// It follows the app's InputDecorationTheme from app_theme.dart for styling.
///
/// Features:
/// - Password visibility toggle (eye icon)
/// - Obscured text by default for security
/// - Lock icon prefix for visual context
/// - Optional password strength validation (6 characters minimum)
/// - Error text display below field
///
/// Validation:
/// - Triggers on field submission (onSubmitted)
/// - Always checks for required field
/// - Optionally validates minimum length (Firebase requirement: 6 chars)
///
/// Use validateStrength = true for sign-up forms, false for sign-in forms.
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool validateStrength;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validateStrength = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  String? _errorText;

  /// Validates password based on requirements.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (widget.validateStrength && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: const Icon(Icons.lock),
        errorText: _errorText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      onChanged: (_) {
        // Clear error on user input
        if (_errorText != null) {
          setState(() => _errorText = null);
        }
      },
      onSubmitted: (_) {
        setState(() {
          _errorText = _validatePassword(widget.controller.text);
        });
      },
    );
  }
}
