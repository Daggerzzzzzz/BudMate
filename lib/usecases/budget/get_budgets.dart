/// Use case for retrieving all budgets associated with a specific user.
///
/// Encapsulates the business logic for fetching user budget data.
/// Follows the Single Responsibility Principle by handling only budget retrieval.
/// Delegates database queries to the BudgetRepository implementation.
/// Filters budgets by userId to ensure data isolation between users.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns List of BudgetEntity containing all user budgets.
/// On failure, returns DatabaseFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Empty list is returned if user has no budgets rather than an error.
/// Budgets are retrieved from local SQLite database for offline access.
/// All database errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/budget_entity.dart';
import 'package:budmate/repositories/interfaces/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  /// Execute get all budgets
  ///
  /// [userId] User ID to filter budgets
  /// [return] Either DatabaseFailure or List of BudgetEntity
  Future<Either<DatabaseFailure, List<BudgetEntity>>> call(
    String userId,
  ) async {
    return await repository.getAll(userId);
  }
}
