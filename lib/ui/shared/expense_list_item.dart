import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/domain/category_entity.dart';
import 'package:budmate/core/managers/ui_manager.dart';
import 'package:budmate/core/utils/icon_utils.dart';
import 'package:budmate/services/preferences_service.dart';

/// Reusable expense list item following Maribank transaction UI pattern.
///
/// Displays a clean, Maribank-style transaction row with:
/// - Category icon in CircleAvatar (using category color as background)
/// - Category name as title (bold, 15px)
/// - Formatted date as subtitle (grey, 13px)
/// - Amount on the right (bold, 15px)
/// - Optional horizontal divider separator (1px solid line)
///
/// This component is reusable across multiple screens:
/// - Upcoming Expenses list on home screen
/// - Expense History screen
/// - Transaction lists
/// - Category-based expense views
///
/// Design Pattern: Maribank Transaction List
/// - No card elevation or shadows
/// - Simple horizontal line separator
/// - Category icon with color-coded background
/// - Clean typography hierarchy
class ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final CategoryEntity category;
  final bool showDivider;
  final bool showStatus;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.category,
    this.showDivider = true,
    this.showStatus = false,
  });

  Widget _buildStatusBadge() {
    // Determine color and label based on status
    Color backgroundColor;
    Color textColor;
    String label;

    switch (expense.status) {
      case ExpenseStatus.paid:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        label = 'Paid';
        break;
      case ExpenseStatus.expired:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        label = 'Expired';
        break;
      case ExpenseStatus.pending:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<PreferencesService>().currencySymbol;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Category icon in colored circle (Maribank-style avatar)
              CircleAvatar(
                backgroundColor: IconUtils.getColorFromHex(category.color)
                    .withValues(alpha: 0.15),  // Light background (15% opacity)
                child: Icon(
                  IconUtils.getIconFromString(category.icon),
                  color: IconUtils.getColorFromHex(category.color),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Category name + date (left-aligned, takes remaining space)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      UIManager.formatDate(expense.date, format: 'MMM dd, yyyy'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount + optional status badge (right-aligned, vertical stack)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status badge (if enabled)
                  if (showStatus) ...[
                    _buildStatusBadge(),
                    const SizedBox(height: 4),
                  ],

                  // Amount
                  Text(
                    UIManager.formatAmount(expense.amount, currencySymbol: currencySymbol),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Horizontal divider (Maribank-style separator)
        // Only shown if showDivider is true (typically hidden on last item)
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            color: Colors.grey.shade300,
          ),
      ],
    );
  }
}
