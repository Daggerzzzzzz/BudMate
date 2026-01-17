import 'package:flutter/material.dart';

/// Reusable email input field with validation and clear functionality.
///
/// This widget provides a Material Design 3 text field specifically for email
/// input with built-in validation, visual feedback, and clear button. It follows
/// the app's InputDecorationTheme from app_theme.dart for consistent styling.
///
/// Features:
/// - Email format validation using regex pattern
/// - Error text display below field (red, 12sp)
/// - Email icon prefix for visual context
/// - Clear button suffix (appears when text present)
/// - Email keyboard type for better UX
///
/// Validation:
/// - Triggers on field submission (onSubmitted)
/// - Checks for required field (not empty)
/// - Validates email format pattern
///
/// Use in sign-in and sign-up forms for consistent email input across the app.
class EmailTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool autofocus;

  const EmailTextField({
    super.key,
    required this.controller,
    this.autofocus = false,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  String? _errorText;

  /// Validates email format using regex pattern.
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
        errorText: _errorText,
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  setState(() {});
                },
              )
            : null,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (_) => setState(() {}), // Update suffixIcon visibility
      onSubmitted: (_) {
        setState(() {
          _errorText = _validateEmail(widget.controller.text);
        });
      },
    );
  }
}
