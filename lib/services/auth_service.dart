import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/domain/user_entity.dart';
import 'package:budmate/core/managers/usecase_manager.dart';
import 'package:budmate/services/category_service.dart';

/// Authentication state management service for UI layer using Provider pattern.
///
/// This presentation service wraps domain use cases to provide reactive authentication
/// state for UI consumption. It maintains current user state via ChangeNotifier allowing
/// widgets to automatically rebuild when auth state changes without manual subscriptions.
///
/// State management:
/// - currentUser: Currently authenticated user entity
/// - isLoading: Loading indicator for auth operations in progress
/// - lastError: Most recent error message for UI display
/// - isUserLoggedIn: Convenience boolean for login state checks
///
/// Authentication operations:
/// - signInWithGoogle: Google OAuth authentication flow
/// - signInWithEmail: Email/password authentication
/// - signUpWithEmail: New user account creation
/// - signOut: Sign out and clear all cached data
/// - checkAuthState: Restore session on app startup with graceful degradation
///
/// All methods return Either type from domain layer forcing explicit error handling
/// at UI level to prevent silent failures. Business logic remains in use cases while
/// this service only manages state and coordinates UI concerns.
class AuthService extends ChangeNotifier {
  final AuthUseCases _authUseCases;
  final CategoryService _categoryService;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _lastError;
  bool _isInitialized = false;

  AuthService({
    required AuthUseCases authUseCases,
    required CategoryService categoryService,
  })  : _authUseCases = authUseCases,
        _categoryService = categoryService;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isUserLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  Future<Either<AuthFailure, UserEntity>> signInWithGoogle() async {
    Logger.info('AuthService: Initiating Google sign-in');
    _setLoading(true);
    _clearError();

    final result = await _authUseCases.signInWithGoogle.call();

    await result.fold(
      (failure) async {
        Logger.error('AuthService: Google sign-in failed: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (user) async {
        Logger.info('AuthService: Google sign-in successful for user: ${user.id}');
        _currentUser = user;
        _setLoading(false); // Immediately notify UI to trigger navigation

        // Initialize default categories in background
        await _categoryService.initializeDefaultCategories();
      },
    );

    return result;
  }

  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    Logger.info('AuthService: Initiating email sign-in for: $email');
    _setLoading(true);
    _clearError();

    final result = await _authUseCases.signInWithEmail.call(
      email: email,
      password: password,
    );

    await result.fold(
      (failure) async {
        Logger.error('AuthService: Email sign-in failed: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (user) async {
        Logger.info('AuthService: Email sign-in successful for user: ${user.id}');
        _currentUser = user;
        _setLoading(false); // Immediately notify UI to trigger navigation

        // Initialize default categories in background
        await _categoryService.initializeDefaultCategories();
      },
    );

    return result;
  }

  Future<Either<AuthFailure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    Logger.info('AuthService: Initiating email sign-up for: $email');
    _setLoading(true);
    _clearError();

    final result = await _authUseCases.signUpWithEmail.call(
      email: email,
      password: password,
      displayName: displayName,
    );

    await result.fold(
      (failure) async {
        Logger.error('AuthService: Email sign-up failed: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (user) async {
        Logger.info('AuthService: Email sign-up successful for user: ${user.id}');
        _currentUser = user;
        _setLoading(false); // Immediately notify UI to trigger navigation

        // Initialize default categories in background
        await _categoryService.initializeDefaultCategories();
      },
    );

    return result;
  }

  Future<Either<AuthFailure, void>> signOut() async {
    Logger.info('AuthService: Initiating sign-out');
    _setLoading(true);
    _clearError();

    final result = await _authUseCases.signOut.call();

    result.fold(
      (failure) {
        Logger.error('AuthService: Sign-out failed: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (_) {
        Logger.info('AuthService: Sign-out successful');
        _currentUser = null;
        _isInitialized = false; // Reset so next login works properly
        _setLoading(false);
      },
    );

    return result;
  }

  Future<void> checkAuthState() async {
    if (_isInitialized) {
      Logger.debug('AuthService: Already initialized, skipping checkAuthState');
      return;
    }

    Logger.info('AuthService: Checking auth state on startup');
    _setLoading(true);

    final result = await _authUseCases.getCurrentUser.call();

    result.fold(
      (failure) {
        Logger.info('AuthService: No user session found');
        _currentUser = null;
        _setLoading(false);
        _isInitialized = true;
      },
      (user) {
        if (user != null) {
          Logger.info('AuthService: User session restored for: ${user.id}');
          _currentUser = user;
        } else {
          Logger.info('AuthService: No cached user found');
          _currentUser = null;
        }
        _setLoading(false);
        _isInitialized = true;
      },
    );
  }

  Future<Either<AuthFailure, void>> sendVerificationEmail() async {
    Logger.info('AuthService: Sending verification email');
    _setLoading(true);
    _clearError();

    final result = await _authUseCases.sendVerificationEmail.call();

    result.fold(
      (failure) {
        Logger.error('AuthService: Send verification failed: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (_) {
        Logger.info('AuthService: Verification email sent successfully');
        _setLoading(false);
      },
    );

    return result;
  }

  Future<Either<AuthFailure, bool>> checkEmailVerified() async {
    Logger.info('AuthService: Checking email verification status');
    _setLoading(true);
    _clearError();

    final result = await _authUseCases.checkEmailVerified.call();

    result.fold(
      (failure) {
        Logger.error('AuthService: Check verified failed: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (isVerified) {
        Logger.info('AuthService: Email verified: $isVerified');

        // If verified, reload current user to update state
        if (isVerified) {
          _reloadCurrentUser();
        }
        _setLoading(false);
      },
    );

    return result;
  }

  Future<Either<AuthFailure, void>> clearAllData() async {
    Logger.info('AuthService: Clearing all data (debug operation)');
    _setLoading(true);
    _clearError();

    final result = await _authUseCases.clearAllData.call();

    result.fold(
      (failure) {
        Logger.error('AuthService: Clear all data failed: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (_) {
        Logger.info('AuthService: All data cleared successfully');
        _currentUser = null; // Clear current user state
        _setLoading(false);
      },
    );

    return result;
  }

  Future<void> _reloadCurrentUser() async {
    final result = await _authUseCases.getCurrentUser.call();
    result.fold(
      (failure) => Logger.error('Failed to reload user: ${failure.message}'),
      (user) {
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        }
      },
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
  }
}
