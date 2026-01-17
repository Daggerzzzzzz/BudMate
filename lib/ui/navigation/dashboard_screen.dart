import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/expense_service.dart';
import '../../services/budget_service.dart';
import '../../services/category_service.dart';
import '../../services/auth_service.dart';
import '../../domain/expense_entity.dart';
import '../../domain/budget_entity.dart';
import '../../domain/category_entity.dart';
import '../../core/managers/ui_manager.dart';
import '../../core/utils/icon_utils.dart';
import '../../core/utils/theme_helper.dart';
import '../../core/extensions/list_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../shared/profile_header.dart';
import '../shared/charts/donut_chart.dart';

/// Dashboard screen displaying expense analytics and spending insights.
///
/// Transforms expense data into visual charts and summaries following Maribank
/// UI patterns. Uses ProfileHeader at top with teal background, followed by
/// white rounded content area containing scrollable analytics widgets.
///
/// Key responsibilities:
/// - Load expense, budget, and category data from services
/// - Calculate analytics data (budget health, category spending breakdown)
/// - Display 2 main sections: Budget Health and Category Breakdown
/// - Handle loading states and empty states gracefully
/// - Integrate with ExpenseService, BudgetService, CategoryService via Consumer pattern
///
/// Design Pattern: Consistent with Expense History Screen
/// - ProfileHeader (teal) → White rounded container (24px radius)
/// - Title "Expense Dashboard" with consistent spacing
/// - Scrollable Column with chart widgets
/// - Dynamic styling using screenWidth * 0.XX pattern
/// - Clean, minimal design (no card elevation or shadows)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Time filter state (for filtering charts by date range)
  String _selectedPeriod = 'All Time';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.id;

    if (userId != null) {
      // Load all necessary data (expenses already loaded globally)
      await Future.wait([
        context.read<ExpenseService>().loadExpenses(userId),
        context.read<BudgetService>().loadBudgets(userId),
        // Categories already loaded globally at app startup
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeHelper.getSurfaceColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Title section (non-scrolling)
                  _buildTitleHeader(),

                  // Scrollable dashboard content
                  Expanded(
                    child: Consumer3<ExpenseService, BudgetService, CategoryService>(
                      builder: (context, expenseService, budgetService, categoryService, child) {
                        // Loading state
                        if (expenseService.isLoading ||
                            budgetService.isLoading ||
                            categoryService.isLoading ||
                            categoryService.categories.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Calculate analytics data
                        final analyticsData = _calculateAnalytics(
                          expenseService.expenses,
                          budgetService.budgets,
                          categoryService.categories,
                        );

                        // Empty state
                        if (expenseService.expenses.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        // Dashboard content
                        return _buildDashboardContent(analyticsData, categoryService.categories);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title (left-aligned)
          Text(
            l10n.expenseDashboard,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // Time period filter (right-aligned)
          _buildPeriodFilter(),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownFontSize = screenWidth * 0.035;
    final l10n = AppLocalizations.of(context)!;

    // Map period keys to localized labels
    final periodLabels = {
      'This Month': l10n.thisMonth,
      'Last 3 Months': l10n.lastThreeMonths,
      'All Time': l10n.allTime,
    };

    return DropdownButton<String>(
      value: _selectedPeriod,
      icon: Icon(Icons.calendar_today, size: screenWidth * 0.045),
      elevation: 16,
      dropdownColor: ThemeHelper.getDropdownColor(context),
      style: TextStyle(
        color: ThemeHelper.getTextColor(context),
        fontSize: dropdownFontSize,
        fontWeight: FontWeight.w600,
      ),
      underline: const SizedBox(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() => _selectedPeriod = newValue);
        }
      },
      items: periodLabels.entries.map<DropdownMenuItem<String>>((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value, style: TextStyle(fontSize: dropdownFontSize)),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: ThemeHelper.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noExpenseDataYet,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addExpensesToSeeAnalytics,
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Analytics data model for dashboard visualizations.
  DashboardAnalytics _calculateAnalytics(
    List<ExpenseEntity> expenses,
    List<BudgetEntity> budgets,
    List<CategoryEntity> categories,
  ) {
    // Filter expenses based on selected period
    final filteredExpenses = _filterByPeriod(expenses, _selectedPeriod);

    // Calculate budget totals
    final totalBudget = budgets.isNotEmpty ? budgets.first.amount : 0.0;
    final totalSpent = filteredExpenses
        .where((e) => e.status == ExpenseStatus.paid)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final availableBalance = totalBudget - totalSpent;

    // Calculate category spending
    final categorySpending = <String, double>{};
    final categoryCount = <String, int>{};
    for (final expense in filteredExpenses.where((e) => e.status == ExpenseStatus.paid)) {
      categorySpending[expense.categoryId] =
          (categorySpending[expense.categoryId] ?? 0) + expense.amount;
      categoryCount[expense.categoryId] =
          (categoryCount[expense.categoryId] ?? 0) + 1;
    }

    return DashboardAnalytics(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      availableBalance: availableBalance,
      categorySpending: categorySpending,
      categoryCount: categoryCount,
    );
  }

  List<ExpenseEntity> _filterByPeriod(List<ExpenseEntity> expenses, String period) {
    final now = DateTime.now();
    final startDate = switch (period) {
      'This Month' => DateTime(now.year, now.month, 1),
      'Last 3 Months' => DateTime(now.year, now.month - 3, now.day),
      _ => DateTime(1970, 1, 1), // All Time
    };

    return expenses.where((e) => e.date.isAfter(startDate)).toList();
  }

  Widget _buildDashboardContent(DashboardAnalytics data, List<CategoryEntity> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // 1. Budget Health Summary Card
          _buildBudgetHealthCard(data),
          const SizedBox(height: 16),

          // 2. Category Spending Breakdown (Donut Chart)
          _buildCategoryBreakdownCard(data, categories),
        ],
      ),
    );
  }

  Widget _buildBudgetHealthCard(DashboardAnalytics data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final healthPercentage = data.totalBudget > 0
        ? (data.availableBalance / data.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    // Color coding: green (>50%), yellow (20-50%), red (<20%)
    final healthColor = healthPercentage > 0.5
        ? Colors.green
        : healthPercentage > 0.2
            ? Colors.orange
            : Colors.red;

    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.budgetHealth,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: healthPercentage,
              minHeight: screenWidth * 0.025,
              backgroundColor: ThemeHelper.isDarkMode(context)
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn(
                l10n.available,
                UIManager.formatAmount(data.availableBalance),
                healthColor,
                screenWidth,
              ),
              _buildStatColumn(
                l10n.spent,
                UIManager.formatAmount(data.totalSpent),
                ThemeHelper.getSecondaryTextColor(context),
                screenWidth,
              ),
              _buildStatColumn(
                l10n.budget,
                UIManager.formatAmount(data.totalBudget),
                ThemeHelper.getSecondaryTextColor(context),
                screenWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: ThemeHelper.getSecondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdownCard(DashboardAnalytics data, List<CategoryEntity> categories) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    if (data.categorySpending.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort categories by spending (highest first)
    final sortedEntries = data.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.spendingByCategory,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Donut chart (custom painted)
          Center(
            child: SizedBox(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              child: DonutChart(
                data: data.categorySpending,
                categories: categories,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Legend with percentages
          ...sortedEntries.take(5).map((entry) {
            final category = categories.firstWhereOrNull(
              (c) => c.id == entry.key,
            ) ?? const CategoryEntity(
              id: 'unknown',
              name: 'Unknown',
              icon: 'category',
              color: '9E9E9E',
            );
            final percentage = (entry.value / data.totalSpent * 100).toStringAsFixed(1);

            return _buildLegendItem(
              category,
              UIManager.formatAmount(entry.value),
              '$percentage%',
              screenWidth,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(CategoryEntity category, String amount, String percentage, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: screenWidth * 0.03,
            height: screenWidth * 0.03,
            decoration: BoxDecoration(
              color: IconUtils.getColorFromHex(category.color),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),

          // Category icon
          Icon(
            IconUtils.getIconFromString(category.icon),
            size: screenWidth * 0.05,
            color: IconUtils.getColorFromHex(category.color),
          ),
          SizedBox(width: screenWidth * 0.02),

          // Category name
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Amount
          Text(
            amount,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),

          // Percentage
          Text(
            percentage,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: ThemeHelper.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }


}

/// Analytics data model for dashboard visualizations.
///
/// Contains computed analytics metrics derived from expense data including
/// budget health and category spending breakdown.
class DashboardAnalytics {
  final double totalBudget;
  final double totalSpent;
  final double availableBalance;
  final Map<String, double> categorySpending;    // categoryId → amount
  final Map<String, int> categoryCount;          // categoryId → count

  DashboardAnalytics({
    required this.totalBudget,
    required this.totalSpent,
    required this.availableBalance,
    required this.categorySpending,
    required this.categoryCount,
  });
}
