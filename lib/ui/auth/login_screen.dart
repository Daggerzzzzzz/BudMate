import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/services/auth_service.dart';
import 'package:budmate/ui/shared/primary_button.dart';
import 'package:budmate/core/managers/ui_manager.dart';
import 'package:budmate/core/managers/navigation_manager.dart';
import 'package:budmate/core/logger.dart';
import '../../l10n/app_localizations.dart';

/// Login screen with Google OAuth authentication.
///
/// This screen provides the authentication entry point for the BudMate app
/// using Firebase Google Sign-In with automatic SQLite profile sync.
///
/// Authentication flow:
/// - User taps "Sign In with Google"
/// - Firebase handles OAuth via Google Sign-In SDK
/// - On success: User synced to SQLite + cached in SharedPreferences
/// - Navigates to dashboard on successful authentication
///
/// State binding:
/// - Consumer of AuthService for reactive loading/error states
/// - Button disabled during authentication (isLoading)
/// - Errors displayed via SnackBar (showErrorSnackbar helper)
///
/// Uses Material Design 3 theme with teal primary color and financial branding.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            // Show error SnackBar when lastError changes
            if (authService.lastError != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                UIManager.showError(context, authService.lastError!);
              });
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Icon
                    Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      'BudMate',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      AppLocalizations.of(context)!.appTagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Google Sign-In Button
                    PrimaryButton(
                      text: 'Sign In with Google',
                      icon: Icons.login,
                      isLoading: authService.isLoading,
                      onPressed: authService.isLoading
                          ? null
                          : () => _handleGoogleSignIn(context),
                    ),
                    const SizedBox(height: 16),

                    // Email Sign-In Button
                    PrimaryButton(
                      text: 'Sign In with Email',
                      icon: Icons.email,
                      onPressed: () {
                        NavigationManager.navigateToEmailSignIn(context);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sign Up Button
                    PrimaryButton(
                      text: 'Sign Up',
                      icon: Icons.person_add,
                      onPressed: () {
                        NavigationManager.navigateToSignUp(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Handles Google Sign-In authentication flow.
  /// Navigation is handled automatically by MyApp's Consumer.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    Logger.info('LoginScreen: User initiated Google sign-in');

    final authService = context.read<AuthService>();
    final result = await authService.signInWithGoogle();

    result.fold(
      (failure) {
        Logger.error(
            'LoginScreen: Google sign-in failed: ${failure.message}');
        // Error already displayed via authService.lastError in Consumer
      },
      (user) {
        Logger.info(
            'LoginScreen: Google sign-in successful for user: ${user.id}');
        // Navigation handled automatically by MyApp Consumer - no manual navigation needed
      },
    );
  }
}
