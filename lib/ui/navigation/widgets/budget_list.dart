import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/services/budget_service.dart';
import 'package:budmate/domain/budget_entity.dart';
import 'package:budmate/core/managers/ui_manager.dart';

/// Budget display widget showing the user's current budget balance.
///
/// This widget displays the single budget amount as a running total.
/// Since the budget model has been simplified to only store an amount
/// (no periods, dates, or names), this widget now shows just the balance.
///
/// The budget amount:
/// - Increases when user adds budget via Add Budget modal
/// - Decreases when user pays expenses via Pay Expenses modal
///
/// State binding:
/// - Consumer of BudgetService for reactive budget updates
/// - Displays empty state when no budget exists
/// - Shows loading spinner during initial load
///
/// All data sourced from Firestore via BudgetService.
class BudgetList extends StatelessWidget {
  const BudgetList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetService>(
      builder: (context, budgetService, _) {
        if (budgetService.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (budgetService.budgets.isEmpty) {
          return _buildEmptyState(context);
        }

        // Show the single budget
        final budget = budgetService.budgets.first;
        return _buildBudgetCard(context, budget);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Budget Set',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a budget to start tracking your expenses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetEntity budget) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.green.shade700,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Budget Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Budget',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    UIManager.formatAmount(budget.amount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: budget.amount > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: budget.amount > 0
                    ? Colors.green.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                budget.amount > 0 ? 'Active' : 'Empty',
                style: TextStyle(
                  color: budget.amount > 0
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
