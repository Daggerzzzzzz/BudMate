import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/budget_entity.dart';
import 'package:budmate/repositories/interfaces/budget_repository.dart';

/// Update budget use case modifying existing budget configurations in the system.
///
/// This use case handles budget modification by delegating to BudgetRepository. It allows
/// users to adjust budget amounts, change period types, or update date ranges for active
/// budgets while preserving historical expense data and relationships.
///
/// Operation details:
/// - Validates budget exists before update attempt using budget ID
/// - Allows modification of amount, period, name, and date range fields
/// - Updates timestamp (updatedAt) to track modification history
/// - Returns DatabaseFailure if budget not found or update fails
///
/// Use cases: Adjusting monthly limits, extending budget end dates, or renaming budgets
/// without losing tracked expense history. Budget modifications are immediate and affect
/// real-time budget health calculations performed by BudgetManager.
///
/// Returns `Either<DatabaseFailure, BudgetEntity>` forcing callers to handle both success
/// and failure cases explicitly, preventing silent errors in the presentation layer.
class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  /// Execute budget update
  ///
  /// [budget] BudgetEntity with updated data
  /// [return] Either DatabaseFailure or updated BudgetEntity
  Future<Either<DatabaseFailure, BudgetEntity>> call(
    BudgetEntity budget,
  ) async {
    return await repository.update(budget);
  }
}
