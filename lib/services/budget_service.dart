import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/domain/budget_entity.dart';
import 'package:budmate/domain/budget_health_result.dart';
import 'package:budmate/core/managers/usecase_manager.dart';
import 'package:budmate/core/managers/budget_manager.dart';

/// Budget state management service coordinating budget CRUD and health monitoring.
///
/// This presentation service wraps budget domain use cases and BudgetManager service
/// to provide reactive budget state for UI consumption. It maintains budget lists and
/// health metrics via ChangeNotifier allowing widgets to rebuild on state changes.
///
/// State management:
/// - budgets: List of all budgets for current user (sorted by startDate descending)
/// - budgetHealth: Current budget health calculation result with spending analytics
/// - isLoading: Loading indicator for async budget operations
/// - lastError: Most recent error message for UI error display
///
/// Budget operations:
/// - loadBudgets: Fetch all user budgets and auto-refresh health metrics
/// - createBudget: Create new budget with validation and health refresh
/// - updateBudget: Modify existing budget and recalculate health
/// - deleteBudget: Remove budget and refresh health state
/// - refreshBudgetHealth: Internal auto-called method updating spending analytics
///
/// All methods return Either type forcing explicit error handling at UI level.
/// BudgetManager integration provides spending percentage, alerts, and over-budget flags.
/// This service auto-refreshes budget health after any budget or expense mutations.
class BudgetService extends ChangeNotifier {
  final BudgetUseCases _budgetUseCases;
  final BudgetManager _budgetManager;

  List<BudgetEntity> _budgets = [];
  BudgetHealthResult? _budgetHealth;
  bool _isLoading = false;
  String? _lastError;

  BudgetService({
    required BudgetUseCases budgetUseCases,
    required BudgetManager budgetManager,
  })  : _budgetUseCases = budgetUseCases,
        _budgetManager = budgetManager;

  List<BudgetEntity> get budgets => _budgets;
  BudgetHealthResult? get budgetHealth => _budgetHealth;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> loadBudgets(String userId) async {
    Logger.info('BudgetService: Loading budgets for user: $userId');
    _setLoading(true);
    _clearError();

    final result = await _budgetUseCases.get.call(userId);

    result.fold(
      (failure) {
        Logger.error('BudgetService: Failed to load budgets: ${failure.message}');
        _setErrorSilent(failure.message);
        _budgets = [];
        _setLoading(false);  // Final notify
      },
      (budgets) {
        Logger.info('BudgetService: Loaded ${budgets.length} budgets');
        _budgets = budgets;
        _setLoadingSilent(false);  // Silent - health refresh will notify
        // Auto-refresh health after loading budgets
        refreshBudgetHealth(userId);  // Final notify
      },
    );
  }

  Future<Either<DatabaseFailure, BudgetEntity>> createBudget(
    BudgetEntity budget,
  ) async {
    Logger.info('BudgetService: Creating budget with amount: ${budget.amount}');
    _setLoading(true);
    _clearError();

    final result = await _budgetUseCases.create.call(budget);

    await result.fold(
      (failure) async {
        Logger.error('BudgetService: Failed to create budget: ${failure.message}');
        _setErrorSilent(failure.message);
        _setLoading(false);  // Final notify
      },
      (createdBudget) async {
        Logger.info('BudgetService: Budget created successfully: ${createdBudget.id}');
        _budgets = [..._budgets, createdBudget];
        _setLoadingSilent(false);  // Silent - health refresh will notify
        // Auto-refresh health after creating budget
        await refreshBudgetHealth(budget.userId);  // Final notify
      },
    );

    return result;
  }

  Future<Either<DatabaseFailure, BudgetEntity>> updateBudget(
    BudgetEntity budget,
  ) async {
    Logger.info('BudgetService: Updating budget: ${budget.id}');
    _setLoading(true);
    _clearError();

    final result = await _budgetUseCases.update.call(budget);

    await result.fold(
      (failure) async {
        Logger.error('BudgetService: Failed to update budget: ${failure.message}');
        _setErrorSilent(failure.message);
        _setLoading(false);  // Final notify
      },
      (updatedBudget) async {
        Logger.info('BudgetService: Budget updated successfully: ${updatedBudget.id}');
        _budgets = _budgets
            .map((b) => b.id == updatedBudget.id ? updatedBudget : b)
            .toList();
        _setLoadingSilent(false);  // Silent - health refresh will notify
        // Auto-refresh health after updating budget
        await refreshBudgetHealth(budget.userId);  // Final notify
      },
    );

    return result;
  }

  Future<Either<DatabaseFailure, void>> deleteBudget(String id, String userId) async {
    Logger.info('BudgetService: Deleting budget: $id');
    _setLoading(true);
    _clearError();

    final result = await _budgetUseCases.delete.call(id);

    result.fold(
      (failure) {
        Logger.error('BudgetService: Failed to delete budget: ${failure.message}');
        _setErrorSilent(failure.message);
        _setLoading(false);  // Final notify
      },
      (_) {
        Logger.info('BudgetService: Budget deleted successfully: $id');
        _budgets = _budgets.where((b) => b.id != id).toList();
        _setLoadingSilent(false);  // Silent - health refresh will notify
        // Auto-refresh health after deleting budget
        refreshBudgetHealth(userId);  // Final notify
      },
    );

    return result;
  }

  /// Internal method to refresh budget health calculation.
  /// Called automatically after budget/expense mutations.
  Future<void> refreshBudgetHealth(String userId) async {
    Logger.info('BudgetService: Refreshing budget health for user: $userId');

    final result = await _budgetManager.calculateBudgetHealth(userId);

    result.fold(
      (failure) {
        Logger.error('BudgetService: Failed to refresh budget health: ${failure.message}');
        _budgetHealth = null;
        notifyListeners();
      },
      (health) {
        Logger.info(
          'BudgetService: Budget health refreshed - '
          '${health.percentageUsed.toStringAsFixed(1)}% used',
        );
        _budgetHealth = health;
        notifyListeners();
      },
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingSilent(bool loading) {
    _isLoading = loading;
    // No notifyListeners() - silent state update
  }

  void _setErrorSilent(String error) {
    _lastError = error;
    // No notifyListeners() - silent state update
  }

  void _clearError() {
    _lastError = null;
  }
}
