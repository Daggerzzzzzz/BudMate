import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/core/managers/usecase_manager.dart';

/// Expense state management service tracking spending transactions and filtering.
///
/// This presentation service wraps expense domain use cases to provide reactive
/// expense state for UI consumption. It maintains the full expense list and provides
/// in-memory filtering methods for category and date range queries without separate state.
///
/// State management:
/// - expenses: Full list of all expenses for current user (sorted by date descending)
/// - isLoading: Loading indicator for async expense operations
/// - lastError: Most recent error message for UI error display
///
/// Expense operations:
/// - loadExpenses: Fetch all user expenses for overview screens
/// - createExpense: Record new spending transaction
/// - updateExpense: Modify existing expense details
/// - deleteExpense: Remove expense record
/// - getExpensesByCategory: Filter in-memory by categoryId (no additional state)
/// - getExpensesByDateRange: Filter in-memory by date range (no additional state)
///
/// All mutation methods return Either type forcing explicit error handling at UI level.
/// Filter methods return List directly since they operate on cached in-memory state.
/// This service coordinates with BudgetService via callback for budget health auto-refresh.
class ExpenseService extends ChangeNotifier {
  final ExpenseUseCases _expenseUseCases;

  List<ExpenseEntity> _expenses = [];
  bool _isLoading = false;
  String? _lastError;

  // Callback for cross-service communication with BudgetService
  Function(String userId)? onExpenseChanged;

  ExpenseService({
    required ExpenseUseCases expenseUseCases,
  })  : _expenseUseCases = expenseUseCases;

  List<ExpenseEntity> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> loadExpenses(String userId) async {
    Logger.info('ExpenseService: Loading expenses for user: $userId');
    _setLoading(true);
    _clearError();

    final result = await _expenseUseCases.get.call(userId);

    result.fold(
      (failure) {
        Logger.error('ExpenseService: Failed to load expenses: ${failure.message}');
        _setError(failure.message);
        _expenses = [];
        _setLoading(false);
      },
      (expenses) {
        Logger.info('ExpenseService: Loaded ${expenses.length} expenses');
        _expenses = expenses;
        _setLoading(false);
      },
    );
  }

  Future<Either<DatabaseFailure, ExpenseEntity>> createExpense(
    ExpenseEntity expense,
  ) async {
    Logger.info('ExpenseService: Creating expense: ${expense.amount}');
    _setLoading(true);
    _clearError();

    final result = await _expenseUseCases.create.call(expense);

    result.fold(
      (failure) {
        Logger.error('ExpenseService: Failed to create expense: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (createdExpense) {
        Logger.info('ExpenseService: Expense created successfully: ${createdExpense.id}');
        _expenses = [..._expenses, createdExpense];
        _setLoading(false);
        // Trigger budget health refresh via callback
        onExpenseChanged?.call(expense.userId);
      },
    );

    return result;
  }

  Future<Either<DatabaseFailure, ExpenseEntity>> updateExpense(
    ExpenseEntity expense,
  ) async {
    Logger.info('ExpenseService: Updating expense: ${expense.id}');
    _setLoading(true);
    _clearError();

    final result = await _expenseUseCases.update.call(expense);

    result.fold(
      (failure) {
        Logger.error('ExpenseService: Failed to update expense: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (updatedExpense) {
        Logger.info('ExpenseService: Expense updated successfully: ${updatedExpense.id}');
        _expenses = _expenses
            .map((e) => e.id == updatedExpense.id ? updatedExpense : e)
            .toList();
        _setLoading(false);
        // Trigger budget health refresh via callback
        onExpenseChanged?.call(expense.userId);
      },
    );

    return result;
  }

  Future<Either<DatabaseFailure, void>> deleteExpense(String id, String userId) async {
    Logger.info('ExpenseService: Deleting expense: $id');
    _setLoading(true);
    _clearError();

    final result = await _expenseUseCases.delete.call(id);

    result.fold(
      (failure) {
        Logger.error('ExpenseService: Failed to delete expense: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (_) {
        Logger.info('ExpenseService: Expense deleted successfully: $id');
        _expenses = _expenses.where((e) => e.id != id).toList();
        _setLoading(false);
        // Trigger budget health refresh via callback
        onExpenseChanged?.call(userId);
      },
    );

    return result;
  }

  /// Filter expenses by category from in-memory cache.
  /// No additional state or loading required.
  List<ExpenseEntity> getExpensesByCategory(String categoryId) {
    Logger.info('ExpenseService: Filtering ${_expenses.length} expenses by category: $categoryId');
    final filtered = _expenses.where((e) => e.categoryId == categoryId).toList();
    Logger.info('ExpenseService: Found ${filtered.length} expenses for category');
    return filtered;
  }

  /// Filter expenses by date range from in-memory cache.
  /// No additional state or loading required.
  List<ExpenseEntity> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    Logger.info(
      'ExpenseService: Filtering ${_expenses.length} expenses by date range: '
      '${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
    );
    final filtered = _expenses.where((e) {
      return (e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate)) &&
          (e.date.isBefore(endDate) || e.date.isAtSameMomentAs(endDate));
    }).toList();
    Logger.info('ExpenseService: Found ${filtered.length} expenses in date range');
    return filtered;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
  }
}
