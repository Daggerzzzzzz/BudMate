import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';

/// Get expenses by category use case retrieving filtered transaction lists from the system.
///
/// This use case handles category-filtered expense queries by delegating to ExpenseRepository.
/// It returns all expenses assigned to a specific category, useful for analyzing spending
/// patterns within categories like "Food", "Transport", or "Entertainment".
///
/// Operation details:
/// - Queries SQLite database with WHERE clause filtering by categoryId and userId
/// - Leverages composite index on (user_id, category_id) for optimal query performance
/// - Returns expenses sorted by date in descending order (newest first)
/// - Returns empty list if category has no expenses (not an error condition)
/// - Returns DatabaseFailure only on actual database errors or connection issues
///
/// Common use cases: Displaying all food expenses, generating category spending reports,
/// calculating category-specific totals, or identifying high-spending categories. Results
/// can be further processed by the presentation layer for charts and analytics.
///
/// Returns Either DatabaseFailure or List of ExpenseEntity forcing callers to handle both
/// success and failure cases explicitly, preventing silent errors in the presentation layer.
class GetExpensesByCategory {
  final ExpenseRepository repository;

  GetExpensesByCategory(this.repository);

  /// Execute get expenses by category
  ///
  /// [userId] User ID
  /// [categoryId] Category ID to filter by
  /// [return] Either DatabaseFailure or List of ExpenseEntity
  Future<Either<DatabaseFailure, List<ExpenseEntity>>> call(
    String userId,
    String categoryId,
  ) async {
    return await repository.getByCategory(userId, categoryId);
  }
}
