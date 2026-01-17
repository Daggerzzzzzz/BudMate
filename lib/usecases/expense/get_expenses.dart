/// Use case for retrieving all expense transactions associated with a specific user.
///
/// Encapsulates the business logic for fetching user expense data.
/// Follows the Single Responsibility Principle by handling only expense retrieval.
/// Delegates database queries to the ExpenseRepository implementation.
/// Filters expenses by userId to ensure data isolation between users.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns List of ExpenseEntity containing all user expenses.
/// On failure, returns DatabaseFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Empty list is returned if user has no expenses rather than an error.
/// Expenses are retrieved from local SQLite database for offline access.
/// All database errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  /// Execute get all expenses
  ///
  /// [userId] User ID to filter expenses
  /// [return] Either DatabaseFailure or List of ExpenseEntity
  Future<Either<DatabaseFailure, List<ExpenseEntity>>> call(
    String userId,
  ) async {
    return await repository.getAll(userId);
  }
}
