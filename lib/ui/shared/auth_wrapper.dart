import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/services/auth_service.dart';
import 'package:budmate/ui/auth/login_screen.dart';
import 'package:budmate/ui/navigation/bottom_navigation_bar.dart';

/// Wrapper widget that handles authentication state and displays appropriate screen.
///
/// Listens to AuthService and shows:
/// - Loading indicator during initialization
/// - LoginScreen when user is not authenticated
/// - BottomNavigationBarScreen when user is authenticated
///
/// This widget lives inside MaterialApp to avoid recreating the navigator
/// when auth state changes. By placing the Consumer inside MaterialApp rather
/// than wrapping MaterialApp with Consumer, we ensure the MaterialApp instance
/// is stable and only the content switches based on auth state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Show loading during initialization
        if (authService.isLoading && !authService.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show appropriate screen based on auth state
        if (authService.isUserLoggedIn) {
          return const BottomNavigationBarScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
