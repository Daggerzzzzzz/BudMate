/// Use case for creating a new expense transaction record in the system.
///
/// Encapsulates the business logic for expense creation operations.
/// Follows the Single Responsibility Principle by handling only expense creation.
/// Delegates database persistence to the ExpenseRepository implementation.
/// Validates expense data including amount must be positive and category must exist.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns ExpenseEntity with the newly created expense data.
/// On failure, returns DatabaseFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Foreign key constraints ensure both userId and categoryId exist before creation.
/// The expense immediately impacts budget calculations and spending summaries.
/// All database errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';

class CreateExpense {
  final ExpenseRepository repository;

  CreateExpense(this.repository);

  /// Execute expense creation
  ///
  /// [expense] ExpenseEntity to create
  /// [return] Either DatabaseFailure or created ExpenseEntity
  Future<Either<DatabaseFailure, ExpenseEntity>> call(
    ExpenseEntity expense,
  ) async {
    return await repository.create(expense);
  }
}
