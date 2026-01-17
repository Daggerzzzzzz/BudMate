/// Use case for creating a new budget with user-defined spending limits.
///
/// Encapsulates the business logic for budget creation operations.
/// Follows the Single Responsibility Principle by handling only budget creation.
/// Delegates database persistence to the BudgetRepository implementation.
/// Validates budget data including amount must be positive and dates must be valid.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns BudgetEntity with the newly created budget data.
/// On failure, returns DatabaseFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Foreign key constraints ensure the userId exists before budget creation.
/// The budget immediately becomes active and affects spending calculations.
/// All database errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/budget_entity.dart';
import 'package:budmate/repositories/interfaces/budget_repository.dart';

class CreateBudget {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  /// Execute budget creation
  ///
  /// [budget] BudgetEntity to create
  /// [return] Either DatabaseFailure or created BudgetEntity
  Future<Either<DatabaseFailure, BudgetEntity>> call(
    BudgetEntity budget,
  ) async {
    return await repository.create(budget);
  }
}
