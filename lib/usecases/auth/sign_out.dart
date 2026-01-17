/// Use case for signing out the currently authenticated user from the application.
///
/// Encapsulates the business logic for user logout and session termination.
/// Follows the Single Responsibility Principle by handling only signout operations.
/// Delegates authentication cleanup to the AuthRepository implementation.
/// Signs out from both Firebase Authentication and Google Sign-In services.
/// Clears all locally cached user data and authentication tokens.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns void indicating successful logout.
/// On failure, returns AuthFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Ensures complete session cleanup to prevent security vulnerabilities.
/// All sign-out errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  /// Execute sign out
  ///
  /// [return] Either AuthFailure on left, void on right
  Future<Either<AuthFailure, void>> call() async {
    return await repository.signOut();
  }
}
