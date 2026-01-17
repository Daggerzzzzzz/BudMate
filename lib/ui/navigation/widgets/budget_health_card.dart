import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/services/budget_service.dart';
import 'package:budmate/services/preferences_service.dart';
import 'package:budmate/ui/shared/app_theme.dart';
import 'package:budmate/core/constants.dart';

/// Budget health summary card with visual progress bar and alerts.
///
/// This widget displays the current budget health status from BudgetService
/// showing total expenses vs budget amount with color-coded progress indicator.
/// It provides visual alerts when spending approaches or exceeds budget limits.
///
/// Alert thresholds:
/// - Green (< 90%): Healthy spending level
/// - Orange (>= 90%): Warning state with alert icon (shouldAlert = true)
/// - Red (>= 100%): Critical over-budget state (isOverBudget = true)
///
/// The card shows:
/// - Percentage used with color-coded text
/// - Linear progress bar with dynamic color
/// - Total expenses and budget amount
/// - Alert icon when threshold exceeded
///
/// State binding:
/// - Consumer of BudgetService for reactive health updates
/// - Displays loading spinner when health data unavailable
///
/// All data sourced from SQLite via BudgetService (zero network calls).
class BudgetHealthCard extends StatelessWidget {
  const BudgetHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetService>(
      builder: (context, budgetService, _) {
        final health = budgetService.budgetHealth;

        // Show loading state if health data not yet loaded
        if (health == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading budget health...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final progressColor = _getProgressColor(health.percentageUsed);
        final percentageText = '${(health.percentageUsed * 100).toStringAsFixed(0)}%';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and alert icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Health',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (health.shouldAlert)
                      Icon(
                        health.isOverBudget
                            ? Icons.error
                            : Icons.warning_amber_rounded,
                        color: progressColor,
                        size: 28,
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Percentage used with color-coded text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Used',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    Text(
                      percentageText,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: health.percentageUsed.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 20),

                // Expense and budget amounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountColumn(
                      context,
                      'Total Expenses',
                      health.totalExpenses,
                      progressColor,
                    ),
                    _buildAmountColumn(
                      context,
                      'Budget Amount',
                      health.budgetAmount,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),

                // Alert message for over-budget state
                if (health.isOverBudget) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You\'ve exceeded your budget. Consider reviewing your expenses.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (health.shouldAlert) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.warningOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You\'re approaching your budget limit. Watch your spending!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.warningOrange,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a column displaying an amount label and value.
  Widget _buildAmountColumn(
    BuildContext context,
    String label,
    double amount,
    Color amountColor,
  ) {
    final currencySymbol = context.watch<PreferencesService>().currencySymbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$currencySymbol${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
        ),
      ],
    );
  }

  /// Determines progress bar color based on percentage used.
  ///
  /// Returns red for over-budget, orange for alert threshold, green otherwise.
  Color _getProgressColor(double percentageUsed) {
    if (percentageUsed >= 1.0) {
      return Colors.red.shade700;
    } else if (percentageUsed >= AppConstants.budgetAlertThreshold) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.successGreen;
    }
  }
}
