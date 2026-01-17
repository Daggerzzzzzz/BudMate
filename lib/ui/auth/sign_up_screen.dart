import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/services/auth_service.dart';
import 'package:budmate/ui/shared/primary_button.dart';
import 'package:budmate/ui/shared/email_text_field.dart';
import 'package:budmate/ui/shared/password_text_field.dart';
import 'package:budmate/core/managers/ui_manager.dart';
import 'package:budmate/core/managers/navigation_manager.dart';
import 'package:budmate/core/logger.dart';

/// User registration screen for creating new accounts.
///
/// v3 Architecture: Firebase Auth handles email/password registration and validates
/// email uniqueness. No local SQLite check needed - Firebase is source of truth.
///
/// Form fields:
/// - Display Name (optional, defaults to email username)
/// - Email input with validation (EmailTextField)
/// - Password input with 6-character requirement (PasswordTextField)
/// - Confirm Password with match validation
/// - Submit button (disabled until valid)
///
/// Navigation:
/// - On success: Navigate to EmailVerificationScreen for email confirmation
/// - "Sign In" link: Navigate to EmailSignInScreen (pushReplacement)
/// - Back button: Return to LoginScreen (pop)
///
/// State binding:
/// - Consumer of AuthService for reactive loading/error states
/// - Button disabled during registration (isLoading)
/// - Errors displayed via SnackBar (Firebase "email-already-in-use" handled automatically)
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isFormValid = false;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  /// Validates form by checking all fields and password match.
  void _validateForm() {
    setState(() {
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      _isFormValid = email.isNotEmpty &&
          password.isNotEmpty &&
          password.length >= 6 &&
          confirmPassword.isNotEmpty &&
          password == confirmPassword;

      // Update confirm password error for real-time feedback
      if (confirmPassword.isNotEmpty && password != confirmPassword) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  /// Handles user registration with email/password.
  /// Firebase Auth validates email uniqueness - no local SQLite check needed.
  Future<void> _handleSignUp() async {
    Logger.info('SignUpScreen: User initiated sign-up');

    final authService = context.read<AuthService>();
    final email = _emailController.text.trim();

    String? displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      displayName = email.split('@')[0];
    }

    final result = await authService.signUpWithEmail(
      email: email,
      password: _passwordController.text,
      displayName: displayName,
    );

    result.fold(
      (failure) {
        Logger.error('SignUpScreen: Sign-up failed: ${failure.message}');
        // Firebase will return "email-already-in-use" error if duplicate
        // Error already displayed via authService.lastError in Consumer
      },
      (user) async {
        Logger.info('SignUpScreen: Sign-up successful for user: ${user.id}');

        // Send verification email
        final verificationResult = await authService.sendVerificationEmail();

        verificationResult.fold(
          (failure) {
            Logger.error(
                'SignUpScreen: Verification email failed: ${failure.message}');
            if (context.mounted) {
              UIManager.showError(
                context,
                'Account created but failed to send verification email. Please try again.',
              );
            }
          },
          (_) {
            Logger.info('SignUpScreen: Verification email sent');

            // Navigate to verification waiting screen
            if (context.mounted) {
              NavigationManager.navigateToEmailVerification(context, email);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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

                  // Display Name field (optional)
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name (Optional)',
                      prefixIcon: Icon(Icons.person),
                      helperText: 'Defaults to email username if not provided',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  EmailTextField(
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    validateStrength: true, // Enforce 6 char minimum
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    validateStrength: false, // No strength check, just match
                  ),
                  if (_confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _confirmPasswordError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Sign Up button
                  PrimaryButton(
                    text: 'Sign Up',
                    icon: Icons.person_add,
                    isLoading: authService.isLoading,
                    onPressed: _isFormValid && !authService.isLoading
                        ? _handleSignUp
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Sign In link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          NavigationManager.navigateToEmailSignIn(context);
                        },
                        child: const Text('Sign In'),
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
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
