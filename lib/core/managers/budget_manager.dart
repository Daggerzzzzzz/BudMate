import 'package:dartz/dartz.dart';
import 'package:budmate/core/constants.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/core/managers/repository_manager.dart';
import 'package:budmate/domain/budget_health_result.dart';
import 'package:budmate/domain/expense_entity.dart';

/// Domain service for calculating budget health metrics and spending alerts.
///
/// Aggregates data from BudgetRepository and ExpenseRepository to compute real-time
/// budget health indicators. Unlike use cases (single user actions), this service
/// provides reusable cross-cutting business logic spanning multiple domains. It calculates
/// spending percentages, identifies over-budget situations, and triggers 90% threshold alerts.
///
/// Key responsibilities:
/// - calculateBudgetHealth: Computes totalExpenses vs budgetAmount with percentage tracking
/// - checkAlertTriggers: Returns boolean indicating 90% spending threshold reached
/// - Cross-domain calculations: Combines budget limits + expense tracking data
///
/// Used by: BudgetService, Dashboard widgets, Alert notifications
class BudgetManager {
  final BudgetRepository _budgetRepository;
  final ExpenseRepository _expenseRepository;

  BudgetManager({
    required BudgetRepository budgetRepository,
    required ExpenseRepository expenseRepository,
  })  : _budgetRepository = budgetRepository,
        _expenseRepository = expenseRepository;

  Future<Either<DatabaseFailure, BudgetHealthResult>> calculateBudgetHealth(
    String userId,
  ) async {
    try {
      Logger.info('BudgetManager: Calculating budget health for user: $userId');

      final budgetsResult = await _budgetRepository.getAll(userId);

      return await budgetsResult.fold(
        (failure) {
          Logger.error('BudgetManager: Failed to get budgets: ${failure.message}');
          return Left(failure);
        },
        (budgets) async {
          if (budgets.isEmpty) {
            Logger.info('BudgetManager: No budget found, returning default health');
            // Return default zero state instead of error - provides clean UX
            return Right(BudgetHealthResult(
              userId: userId,
              totalExpenses: 0.0,
              budgetAmount: 0.0,
              percentageUsed: 0.0,
              isOverBudget: false,
              shouldAlert: false,
              calculatedAt: DateTime.now(),
            ));
          }

          final budget = budgets.first; // Only one budget per user

          if (budget.amount <= 0) {
            const error = 'Budget amount must be greater than zero';
            Logger.error('BudgetManager: $error');
            return const Left(DatabaseFailure(error));
          }

          // Get ALL expenses for user (no date range)
          final expensesResult = await _expenseRepository.getAll(userId);

          return expensesResult.fold(
            (failure) {
              Logger.error('BudgetManager: Failed to get expenses: ${failure.message}');
              return Left(failure);
            },
            (expenses) {
              // Only count PAID expenses for budget calculation
              final paidExpenses = expenses.where((e) => e.status == ExpenseStatus.paid).toList();

              final totalExpenses = paidExpenses.fold<double>(
                0.0,
                (sum, expense) => sum + expense.amount,
              );

              final percentageUsed = (totalExpenses / budget.amount) * 100;
              final shouldAlert = (totalExpenses / budget.amount) >=
                  AppConstants.budgetAlertThreshold;
              final isOverBudget = totalExpenses > budget.amount;

              final result = BudgetHealthResult(
                userId: userId,
                totalExpenses: totalExpenses,
                budgetAmount: budget.amount,
                percentageUsed: percentageUsed,
                isOverBudget: isOverBudget,
                shouldAlert: shouldAlert,
                calculatedAt: DateTime.now(),
              );

              Logger.info(
                'BudgetManager: Budget health calculated - '
                '${percentageUsed.toStringAsFixed(1)}% used, '
                'alert: $shouldAlert',
              );

              return Right(result);
            },
          );
        },
      );
    } catch (e, stackTrace) {
      Logger.error('BudgetManager: Unexpected error', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Failed to calculate budget health: $e'));
    }
  }

  Future<Either<DatabaseFailure, bool>> checkAlertTriggers(
    String userId,
  ) async {
    Logger.info('BudgetManager: Checking alert triggers for user: $userId');

    final healthResult = await calculateBudgetHealth(userId);

    return healthResult.fold(
      (failure) => Left(failure),
      (result) {
        Logger.info(
          'BudgetManager: Alert check result for user $userId: '
          '${result.shouldAlert}',
        );
        return Right(result.shouldAlert);
      },
    );
  }
}
