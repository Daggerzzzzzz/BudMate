import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';

/// Update expense use case modifying existing transaction records in the system.
///
/// This use case handles expense modification by delegating to ExpenseRepository. It allows
/// users to correct transaction amounts, change descriptions, reassign categories, or update
/// dates while maintaining data integrity through foreign key validation.
///
/// Operation details:
/// - Validates expense exists before update attempt using expense ID
/// - Allows modification of amount, description, categoryId, and date fields
/// - Validates categoryId references an existing category (foreign key constraint)
/// - Updates timestamp (updatedAt) to track modification history
/// - Immediately affects budget health calculations if amount or date changed
/// - Returns DatabaseFailure if expense not found, invalid category, or update fails
///
/// Common use cases: Fixing incorrect amounts, updating descriptions for clarity, moving
/// expenses to different categories, or adjusting transaction dates. Changes are reflected
/// immediately in budget tracking and expense reports.
///
/// Returns Either DatabaseFailure or ExpenseEntity forcing callers to handle both success
/// and failure cases explicitly, preventing silent errors in the presentation layer.
class UpdateExpense {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  /// Execute expense update
  ///
  /// [expense] ExpenseEntity with updated data
  /// [return] Either DatabaseFailure or updated ExpenseEntity
  Future<Either<DatabaseFailure, ExpenseEntity>> call(
    ExpenseEntity expense,
  ) async {
    return await repository.update(expense);
  }
}
