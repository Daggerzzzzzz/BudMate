import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';

/// Delete expense use case removing transaction records from the system.
///
/// This use case handles expense deletion by delegating to ExpenseRepository. It permanently
/// removes individual expense transactions from the database while preserving category and
/// budget configurations. Deleting expenses immediately impacts budget health calculations.
///
/// Operation details:
/// - Validates expense exists before deletion attempt using expense ID
/// - Permanently removes expense record from SQLite database
/// - Does NOT cascade to categories (category remains even if all expenses deleted)
/// - Immediately updates budget calculations by reducing spent amount
/// - Returns DatabaseFailure if expense not found or deletion fails
///
/// Impact on budget tracking: Removing an expense recalculates budget health percentages,
/// potentially changing alert status from "over budget" to "under budget" or vice versa.
/// BudgetManager will exclude deleted expenses from spending totals in future calculations.
///
/// WARNING: This operation is destructive and cannot be undone. Once deleted, transaction
/// history is permanently lost with no recovery option.
///
/// Returns Either DatabaseFailure or void forcing callers to handle both success
/// and failure cases explicitly, preventing silent errors in the presentation layer.
class DeleteExpense {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  /// Execute expense deletion
  ///
  /// [id] Expense ID to delete
  /// [return] Either DatabaseFailure or void
  Future<Either<DatabaseFailure, void>> call(String id) async {
    return await repository.delete(id);
  }
}
