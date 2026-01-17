/// Use case for checking if current user's email is verified.
///
/// Encapsulates the business logic for verifying email verification status.
/// Follows the Single Responsibility Principle by handling only verification checks.
/// Delegates Firebase operations to the AuthRepository.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns boolean indicating verification status (true if verified).
/// On failure, returns AuthFailure with descriptive error messages.
/// This use case should be called after user clicks verification link to confirm status.
/// Firebase automatically reloads user data to get fresh verification state.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

class CheckEmailVerified {
  final AuthRepository repository;

  CheckEmailVerified(this.repository);

  /// Check if current user's email is verified
  ///
  /// [return] Either AuthFailure on left, bool on right (true if verified, false if not)
  Future<Either<AuthFailure, bool>> call() async {
    return await repository.checkEmailVerified();
  }
}
