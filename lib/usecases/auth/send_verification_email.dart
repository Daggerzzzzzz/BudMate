/// Use case for sending Firebase email verification link.
///
/// Encapsulates the business logic for sending verification emails to users.
/// Follows the Single Responsibility Principle by handling only email verification requests.
/// Delegates Firebase operations to the AuthRepository.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns void (verification email sent successfully).
/// On failure, returns AuthFailure with descriptive error messages.
/// This use case should be called after successful signup to verify email ownership.
/// Firebase automatically handles verification link generation and email delivery.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

class SendVerificationEmail {
  final AuthRepository repository;

  SendVerificationEmail(this.repository);

  /// Send email verification link to current user
  ///
  /// [return] Either AuthFailure on left, void on right (email sent successfully)
  Future<Either<AuthFailure, void>> call() async {
    return await repository.sendVerificationEmail();
  }
}
