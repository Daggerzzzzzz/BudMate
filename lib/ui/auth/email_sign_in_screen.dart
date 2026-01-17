import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/services/auth_service.dart';
import 'package:budmate/ui/shared/primary_button.dart';
import 'package:budmate/ui/shared/email_text_field.dart';
import 'package:budmate/ui/shared/password_text_field.dart';
import 'package:budmate/core/managers/ui_manager.dart';
import 'package:budmate/core/managers/navigation_manager.dart';
import 'package:budmate/core/logger.dart';

/// Email/password sign-in screen for existing users.
///
/// This screen provides authentication via email and password using Firebase
/// Auth with automatic profile sync to SQLite. It shows form validation,
/// loading states, and error handling via SnackBar feedback.
///
/// Form fields:
/// - Email input with validation (EmailTextField)
/// - Password input with visibility toggle (PasswordTextField)
/// - Submit button (disabled until fields filled)
///
/// Navigation:
/// - On success: Navigate to DashboardScreen (pushReplacement)
/// - "Sign Up" link: Navigate to SignUpScreen (pushReplacement)
/// - Back button: Return to LoginScreen (pop)
///
/// State binding:
/// - Consumer of AuthService for reactive loading/error states
/// - Button disabled during authentication (isLoading)
/// - Errors displayed via SnackBar (showErrorSnackbar helper)
///
/// All data synced to SQLite via AuthService (three-layer architecture).
class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFormValid = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  /// Validates form by checking if both fields have text.
  void _validateForm() {
    setState(() {
      _isFormValid = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  /// Handles email/password sign-in authentication.
  /// Navigation is handled automatically by MyApp's Consumer.
  Future<void> _handleSignIn() async {
    Logger.info('EmailSignInScreen: User initiated email sign-in');

    // Clear previous inline errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final authService = context.read<AuthService>();
    final result = await authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    result.fold(
      (failure) {
        Logger.error('EmailSignInScreen: Email sign-in failed: ${failure.message}');

        // Set inline errors based on error message
        if (mounted) {
          setState(() {
            final errorMessage = failure.message.toLowerCase();
            if (errorMessage.contains('no account found') ||
                errorMessage.contains('user not found') ||
                errorMessage.contains('user-not-found')) {
              _emailError = failure.message;
            } else if (errorMessage.contains('incorrect password') ||
                errorMessage.contains('wrong password') ||
                errorMessage.contains('wrong-password')) {
              _passwordError = failure.message;
            } else if (errorMessage.contains('invalid email') ||
                errorMessage.contains('invalid-email')) {
              _emailError = failure.message;
            }
            // For other errors, they'll still show in SnackBar via Consumer
          });
        }
      },
      (user) {
        Logger.info('EmailSignInScreen: Email sign-in successful for user: ${user.id}');
        // Navigation handled automatically by MyApp Consumer - no manual navigation needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In with Email'),
      ),
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            // Show error SnackBar when lastError changes
            if (authService.lastError != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                UIManager.showError(context, authService.lastError!);
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Email field
                  EmailTextField(
                    controller: _emailController,
                    autofocus: true,
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _emailError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Password field
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    validateStrength: false, // No strength check for sign-in
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Sign In button
                  PrimaryButton(
                    text: 'Sign In',
                    icon: Icons.login,
                    isLoading: authService.isLoading,
                    onPressed: _isFormValid && !authService.isLoading
                        ? _handleSignIn
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          NavigationManager.navigateToSignUp(context);
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
