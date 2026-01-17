import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/budget_repository.dart';

/// Delete budget use case removing budget configurations from the system.
///
/// This use case handles budget deletion by delegating to BudgetRepository. Unlike category
/// deletion, budget deletion does NOT cascade to expenses since expenses are linked to
/// categories, not budgets. Deleting a budget only removes the spending limit configuration.
///
/// Operation details:
/// - Validates budget exists before deletion attempt using budget ID
/// - Permanently removes budget record from SQLite database
/// - Does NOT affect existing expenses (no CASCADE DELETE to expenses)
/// - Prevents budget health calculations for the deleted budget period
/// - Returns DatabaseFailure if budget not found or deletion fails
///
/// WARNING: This operation is destructive and cannot be undone. Once deleted, budget
/// limits and period configurations are permanently lost, though expense data remains intact.
///
/// Returns `Either<DatabaseFailure, void>` forcing callers to handle both success
/// and failure cases explicitly, preventing silent errors in the presentation layer.
class DeleteBudget {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  /// Execute budget deletion
  ///
  /// [id] Budget ID to delete
  /// [return] Either DatabaseFailure or void
  Future<Either<DatabaseFailure, void>> call(String id) async {
    return await repository.delete(id);
  }
}
