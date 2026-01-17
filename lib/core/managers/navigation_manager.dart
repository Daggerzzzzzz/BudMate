import 'package:flutter/material.dart';
import 'package:budmate/ui/auth/login_screen.dart';
import 'package:budmate/ui/navigation/dashboard_screen.dart';
import 'package:budmate/ui/auth/email_sign_in_screen.dart';
import 'package:budmate/ui/auth/sign_up_screen.dart';
import 'package:budmate/ui/auth/email_verification_waiting_screen.dart';
import 'package:budmate/ui/navigation/bottom_navigation_bar.dart';
import 'package:budmate/ui/navigation/modals/pay_expenses_modal.dart';

/// Centralized navigation manager - single source of truth for all app navigation.
///
/// Consolidates all navigation logic (screen transitions, modals, dialogs, back navigation)
/// into one place to eliminate Navigator boilerplate and enable consistent routing patterns.
/// Makes navigation testable, trackable, and easy to modify globally (transitions, analytics, deep linking).
///
/// Navigation categories:
/// - Screen navigation: navigateToLogin, navigateToMainNavigation, navigateToEmailSignIn
/// - Modal/Dialog management: showModal, closeModal, showConfirmDialog, showAlertDialog
/// - Specialized modals: showAddExpenseModal
/// - Tab navigation: navigateToTab (switches bottom nav tabs)
/// - Utility: goBack (safe back navigation with canPop check)
class NavigationManager {
  NavigationManager._();

  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  static void navigateToMainNavigation(BuildContext context, {int initialTab = 0}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavigationBarScreen(initialIndex: initialTab),
      ),
    );
  }

  @Deprecated('Use navigateToMainNavigation() instead')
  static void navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  static void navigateToEmailSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailSignInScreen()),
    );
  }

  static void navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  static void navigateToEmailVerification(BuildContext context, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmailVerificationWaitingScreen(email: email),
      ),
    );
  }

  static void navigateToTab(BuildContext context, int tabIndex) {
    navigateToMainNavigation(context, initialTab: tabIndex);
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void closeModal(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  static Future<T?> showModal<T>(BuildContext context, Widget child) {
    return showDialog<T>(
      context: context,
      builder: (context) => child,
    );
  }

  static Future<bool?> showPayExpensesModal(BuildContext context) {
    return PayExpensesModal.show(context);
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
