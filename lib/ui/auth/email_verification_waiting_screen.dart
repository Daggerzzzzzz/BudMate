import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/services/auth_service.dart';
import 'package:budmate/ui/shared/primary_button.dart';
import 'package:budmate/ui/shared/secondary_button.dart';
import 'package:budmate/core/managers/ui_manager.dart';
import 'package:budmate/core/managers/navigation_manager.dart';
import 'package:budmate/core/logger.dart';

/// Email verification waiting screen shown after signup.
///
/// This screen guides users through the email verification process using
/// Firebase's built-in email verification link. It displays the user's email
/// address, provides instructions to check inbox/spam, and offers two actions:
/// verify status check and resend verification email.
///
/// User flow:
/// 1. User signs up → verification email sent → navigates here
/// 2. User checks email inbox/spam folder
/// 3. User clicks verification link in email (Firebase verifies)
/// 4. User returns to app, clicks "I've Verified My Email"
/// 5. App checks Firebase verification status
/// 6. If verified → navigate to Dashboard
/// 7. If not verified → show error, allow resend
///
/// Features:
/// - Displays user's email address
/// - Clear instructions for email verification
/// - "I've Verified My Email" button (primary action)
/// - "Resend Verification Email" button (secondary action)
/// - Loading states for both buttons
/// - Error feedback via SnackBar
///
/// Navigation:
/// - On verification success: Navigate to Dashboard (via Consumer auto-navigation)
/// - No back button (prevents returning to signup)
class EmailVerificationWaitingScreen extends StatefulWidget {
  final String email;

  const EmailVerificationWaitingScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationWaitingScreen> createState() =>
      _EmailVerificationWaitingScreenState();
}

class _EmailVerificationWaitingScreenState
    extends State<EmailVerificationWaitingScreen> {
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          // Show error via SnackBar if present
          if (authService.lastError != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              UIManager.showError(context, authService.lastError!);
            });
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email icon
                  Icon(
                    Icons.email_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Verification Email Sent',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Email address
                  Text(
                    'We sent a verification link to:',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Instructions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Steps:',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            context,
                            '1',
                            'Check your email inbox',
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionStep(
                            context,
                            '2',
                            'Click the verification link',
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionStep(
                            context,
                            '3',
                            'Return here and tap "I\'ve Verified My Email"',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Note: Check your spam folder if you don\'t see the email.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // "I've Verified My Email" button (Primary action)
                  PrimaryButton(
                    text: 'I\'ve Verified My Email',
                    icon: Icons.check_circle_outline,
                    isLoading: _isCheckingVerification,
                    onPressed: _isCheckingVerification || _isResendingEmail
                        ? null
                        : _handleCheckVerification,
                  ),
                  const SizedBox(height: 16),

                  // "Resend Verification Email" button (Secondary action)
                  SecondaryButton(
                    text: 'Resend Verification Email',
                    icon: Icons.refresh,
                    isLoading: _isResendingEmail,
                    onPressed: _isCheckingVerification || _isResendingEmail
                        ? null
                        : _handleResendEmail,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCheckVerification() async {
    Logger.info('EmailVerificationWaitingScreen: Checking verification status');

    setState(() {
      _isCheckingVerification = true;
    });

    final authService = context.read<AuthService>();
    final result = await authService.checkEmailVerified();

    setState(() {
      _isCheckingVerification = false;
    });

    result.fold(
      (failure) {
        Logger.error(
            'EmailVerificationWaitingScreen: Verification check failed: ${failure.message}');
        // Error already displayed via authService.lastError in Consumer
      },
      (isVerified) {
        if (isVerified) {
          Logger.info(
              'EmailVerificationWaitingScreen: Email verified, navigating to main navigation');
          if (mounted) {
            UIManager.showSuccess(context, 'Email verified successfully!');
            // Navigation to main app happens automatically via MyApp Consumer
            // when authService.currentUser is updated by _reloadCurrentUser
            NavigationManager.navigateToMainNavigation(context);
          }
        } else {
          Logger.info(
              'EmailVerificationWaitingScreen: Email not yet verified');
          if (mounted) {
            UIManager.showError(
              context,
              'Email not verified yet. Please click the link in your email first.',
            );
          }
        }
      },
    );
  }

  Future<void> _handleResendEmail() async {
    Logger.info(
        'EmailVerificationWaitingScreen: Resending verification email');

    setState(() {
      _isResendingEmail = true;
    });

    final authService = context.read<AuthService>();
    final result = await authService.sendVerificationEmail();

    setState(() {
      _isResendingEmail = false;
    });

    result.fold(
      (failure) {
        Logger.error(
            'EmailVerificationWaitingScreen: Resend failed: ${failure.message}');
        // Error already displayed via authService.lastError in Consumer
      },
      (_) {
        Logger.info(
            'EmailVerificationWaitingScreen: Verification email resent successfully');
        if (mounted) {
          UIManager.showSuccess(
            context,
            'Verification email sent! Please check your inbox.',
          );
        }
      },
    );
  }
}
