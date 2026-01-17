/// Use case for creating new user accounts with email and password authentication.
///
/// Encapsulates the business logic for user registration using email credentials.
/// Follows the Single Responsibility Principle by handling only signup operations.
/// Delegates authentication implementation details to the AuthRepository.
/// Validates that password meets Firebase security requirements before submission.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns UserEntity containing the newly created user profile.
/// On failure, returns AuthFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// The optional displayName parameter allows setting user profile during registration.
/// All Firebase authentication errors are transformed into domain-friendly failures.
/// The use case ensures clean separation between business logic and framework code.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/user_entity.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  /// Execute sign up with email
  ///
  /// [email] User's email address
  /// [password] User's password (must meet Firebase security requirements)
  /// [displayName] Optional display name for user profile
  /// [return] Either AuthFailure on left, UserEntity on right
  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
