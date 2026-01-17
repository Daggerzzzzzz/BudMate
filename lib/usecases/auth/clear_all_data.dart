/// Use case for clearing all data from cache and database (debug/testing purposes).
///
/// Encapsulates the business logic for complete data removal from the application.
/// Follows the Single Responsibility Principle by handling only data clearing operations.
/// Delegates data cleanup to the AuthRepository implementation which coordinates
/// clearing both SharedPreferences cache and SQLite database.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns void indicating all data successfully cleared.
/// On failure, returns AuthFailure with descriptive error messages.
/// This use case should only be invoked during debugging/testing.
/// WARNING: This operation is irreversible - all user data will be permanently deleted.
/// All clearing errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

class ClearAllData {
  final AuthRepository repository;

  ClearAllData(this.repository);

  /// Execute data clearing
  ///
  /// [return] Either AuthFailure on left, void on right
  Future<Either<AuthFailure, void>> call() async {
    return await repository.clearAllData();
  }
}
