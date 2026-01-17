import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/expense_entity.dart';
import '../../../domain/category_entity.dart';
import '../../../services/category_service.dart';
import '../../../core/extensions/list_extensions.dart';
import '../../shared/expense_list_item.dart';

/// Upcoming expenses list following Maribank transaction UI pattern.
///
/// Displays up to 3 upcoming unpaid expenses in a clean, non-scrollable list.
/// Uses Maribank-style design with category icons, simple horizontal dividers,
/// and no card elevations for a minimal, professional appearance.
///
/// Key features:
/// - Non-scrollable: Shows maximum 3 items using `.take(3)`
/// - Category icons: Uses category-specific icons and colors from CategoryService
/// - Clean separators: Simple 1px horizontal lines (no cards or shadows)
/// - Compact layout: Reduced gap (6px) between title and list
/// - Smaller title: "Upcoming Expenses" using titleMedium font
///
/// Filters expenses by:
/// - isPaid == false (not yet paid)
/// - date >= DateTime.now() (due today or in the future)
///
/// Overdue expenses (isPaid == false && date < DateTime.now()) are NOT shown here.
/// Those will be shown in the Expense History screen with overdue status.
class UpcomingExpensesList extends StatelessWidget {
  final List<ExpenseEntity> expenses;
  final double screenHeight;

  const UpcomingExpensesList({
    super.key,
    required this.expenses,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Filter for upcoming expenses (pending status only)
    final upcomingExpenses = expenses
        .where((expense) => expense.status == ExpenseStatus.pending)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Expenses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Non-scrollable list limited to 3 items
          upcomingExpenses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No upcoming expenses',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                )
              : Consumer<CategoryService>(
                  builder: (context, categoryService, _) {
                    // If categories are not loaded yet, show loading state
                    if (categoryService.categories.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Take max 3 items
                    final limitedExpenses = upcomingExpenses.take(3).toList();

                    return Column(
                      children: limitedExpenses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final expense = entry.value;
                        final isLast = index == limitedExpenses.length - 1;

                        // Find category for this expense with safe fallback
                        final category = categoryService.categories.firstWhereOrNull(
                          (c) => c.id == expense.categoryId,
                        ) ?? const CategoryEntity(
                          id: 'unknown',
                          name: 'Unknown',
                          icon: 'category',
                          color: '9E9E9E',
                        );

                        return ExpenseListItem(
                          expense: expense,
                          category: category,
                          showDivider: !isLast,  // No divider on last item
                        );
                      }).toList(),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
