/// Use case for retrieving the currently authenticated user from session state.
///
/// Encapsulates the business logic for checking current authentication status.
/// Follows the Single Responsibility Principle by handling only user retrieval.
/// Delegates authentication state checking to the AuthRepository implementation.
/// First checks Firebase Authentication for current user session.
/// Falls back to locally cached user data when offline or network unavailable.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns UserEntity if authenticated or null if not logged in.
/// On failure, returns AuthFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Enables offline-first user experience through intelligent caching strategy.
/// All authentication state errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/user_entity.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  /// Execute get current user
  ///
  /// [return] Either AuthFailure on left, UserEntity or null on right (null if not authenticated)
  Future<Either<AuthFailure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}
