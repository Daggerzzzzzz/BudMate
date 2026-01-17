/// Use case for authenticating users through Google Sign-In OAuth flow.
///
/// Encapsulates the business logic for Google authentication integration.
/// Follows the Single Responsibility Principle by handling only Google signin operations.
/// Delegates OAuth flow implementation details to the AuthRepository.
/// Manages the complete authentication process including user consent and token exchange.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns UserEntity containing the authenticated user profile.
/// On failure, returns AuthFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Handles both new user registration and existing user signin seamlessly.
/// All Google Sign-In errors are transformed into domain-friendly failures.
/// The repository handles platform-specific OAuth implementations for web and mobile.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/user_entity.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  /// Execute Google sign in
  ///
  /// [return] Either AuthFailure on left, UserEntity on right
  Future<Either<AuthFailure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
