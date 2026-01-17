/// Budget health calculation result domain entity for aggregated spending analytics.
///
/// This domain entity encapsulates comprehensive budget health metrics calculated by
/// BudgetManager service combining budget limits with actual expense totals. It provides
/// a complete snapshot of spending status including usage percentage, alert flags, and
/// remaining budget calculations at a specific point in time.
///
/// Core metrics:
/// - totalExpenses: Aggregate sum of all expenses within the budget period
/// - budgetAmount: Maximum spending limit configured for the period
/// - percentageUsed: Spending ratio (can exceed 100% when over budget)
/// - isOverBudget: Boolean flag when expenses surpass the limit
/// - shouldAlert: Triggers at 90% threshold per AppConstants.budgetAlertThreshold
///
/// The remainingAmount getter provides calculated business logic returning positive
/// values for under-budget scenarios and negative values when overspending occurs.
/// This entity uses Equatable for value-based equality enabling efficient state
/// comparisons in presentation layer budget displays and real-time spending alerts.
library;

import 'package:equatable/equatable.dart';

class BudgetHealthResult extends Equatable {
  final String userId;
  final double totalExpenses;
  final double budgetAmount;
  final double percentageUsed;
  final bool isOverBudget;
  final bool shouldAlert;
  final DateTime calculatedAt;

  const BudgetHealthResult({
    required this.userId,
    required this.totalExpenses,
    required this.budgetAmount,
    required this.percentageUsed,
    required this.isOverBudget,
    required this.shouldAlert,
    required this.calculatedAt,
  });

  double get remainingAmount => budgetAmount - totalExpenses;

  @override
  List<Object> get props => [
        userId,
        totalExpenses,
        budgetAmount,
        percentageUsed,
        isOverBudget,
        shouldAlert,
        calculatedAt,
      ];

  @override
  String toString() => 'BudgetHealthResult(userId: $userId, percentage: $percentageUsed%, '
      'remaining: \$${remainingAmount.toStringAsFixed(2)})';
}
