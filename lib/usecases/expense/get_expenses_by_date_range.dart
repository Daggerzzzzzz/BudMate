import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';

/// Get expenses by date range use case retrieving time-filtered transaction lists from the system.
///
/// This use case handles date-range-filtered expense queries by delegating to ExpenseRepository.
/// It returns all expenses within a specific time period, essential for budget health calculations,
/// monthly reports, and analyzing spending trends over time.
///
/// Operation details:
/// - Queries SQLite database with BETWEEN clause filtering by date milliseconds and userId
/// - Converts DateTime to millisecondsSinceEpoch for efficient integer comparison in SQLite
/// - Leverages composite index on (user_id, date) for optimal query performance
/// - Date range is INCLUSIVE on both startDate and endDate boundaries
/// - Returns expenses sorted by date in descending order (newest first)
/// - Returns empty list if no expenses in period (not an error condition)
///
/// Critical for BudgetManager: This use case powers budget health calculations by finding expenses
/// within budget periods (daily, weekly, monthly). The date range typically matches budget.startDate
/// to budget.endDate to calculate spending percentage and trigger 90% alerts.
///
/// Returns Either DatabaseFailure or List of ExpenseEntity forcing callers to handle both
/// success and failure cases explicitly, preventing silent errors in the presentation layer.
class GetExpensesByDateRange {
  final ExpenseRepository repository;

  GetExpensesByDateRange(this.repository);

  /// Execute get expenses by date range
  ///
  /// [userId] User ID
  /// [startDate] Start of date range (inclusive)
  /// [endDate] End of date range (inclusive)
  /// [return] Either DatabaseFailure or List of ExpenseEntity
  Future<Either<DatabaseFailure, List<ExpenseEntity>>> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await repository.getByDateRange(userId, startDate, endDate);
  }
}
