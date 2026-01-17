/// Complete expense history screen displaying all paid and expired expenses.
///
/// Shows comprehensive transaction log with Maribank-style UI for reviewing
/// past expenses. Displays both paid (successfully completed) and expired
/// (overdue/unpaid) expenses sorted by date descending. Uses ProfileHeader
/// at top with teal background, followed by white rounded content area
/// containing scrollable expense list.
///
/// Key responsibilities:
/// - Filter expenses by status (paid + expired only, excludes pending)
/// - Sort expenses by date descending (newest transactions first)
/// - Display expenses using reusable ExpenseListItem component
/// - Show empty state when no historical expenses exist
/// - Handle loading states for categories service
/// - Integrate with ExpenseService and CategoryService via Consumer pattern
///
/// Design Pattern: Maribank Transaction History
/// - ProfileHeader (teal) → White rounded container (24px radius)
/// - Title "Expense History" with consistent spacing
/// - Scrollable ListView with ExpenseListItem components
/// - 1px grey dividers between items (hidden on last item)
/// - Clean, minimal design (no card elevation or shadows)
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/expense_service.dart';
import '../../services/category_service.dart';
import '../../services/auth_service.dart';
import '../../core/utils/theme_helper.dart';
import '../../domain/expense_entity.dart';
import '../../domain/category_entity.dart';
import '../../core/extensions/list_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../shared/expense_list_item.dart';
import '../shared/profile_header.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  // Filter state (null = "All" selected)
  ExpenseStatus? _selectedFilter;

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
      // ExpenseService loads expenses
      await context.read<ExpenseService>().loadExpenses(userId);
      // Categories already loaded globally at app startup
    }
  }

  Widget _buildFilterDropdown() {
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownFontSize = screenWidth * 0.035; // Dynamic: ~3.5% of screen width
    final l10n = AppLocalizations.of(context)!;

    // Map filter values to display labels
    String getFilterLabel(ExpenseStatus? filter) {
      if (filter == null) return l10n.all;
      if (filter == ExpenseStatus.paid) return l10n.paid;
      if (filter == ExpenseStatus.expired) return l10n.pending;
      return l10n.all;
    }

    return DropdownButton<ExpenseStatus?>(
      value: _selectedFilter,
      icon: Icon(Icons.filter_list, size: screenWidth * 0.05),
      iconSize: screenWidth * 0.05,
      elevation: 16,
      dropdownColor: ThemeHelper.getDropdownColor(context),
      style: TextStyle(
        color: ThemeHelper.getTextColor(context),
        fontSize: dropdownFontSize,
        fontWeight: FontWeight.w600,
      ),
      underline: const SizedBox(),
      onChanged: (ExpenseStatus? newValue) {
        setState(() => _selectedFilter = newValue);
      },
      items: <ExpenseStatus?>[null, ExpenseStatus.paid, ExpenseStatus.expired]
          .map<DropdownMenuItem<ExpenseStatus?>>((ExpenseStatus? value) {
        return DropdownMenuItem<ExpenseStatus?>(
          value: value,
          child: Text(
            getFilterLabel(value),
            style: TextStyle(fontSize: dropdownFontSize),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  // Title section with filter chips (non-scrolling)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title (left-aligned)
                        Text(
                          l10n.expenseHistory,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Filter dropdown (right-aligned)
                        _buildFilterDropdown(),
                      ],
                    ),
                  ),

                  // Scrollable expense list
                  Expanded(
                    child: Consumer<ExpenseService>(
                      builder: (context, expenseService, child) {
                        return Consumer<CategoryService>(
                          builder: (context, categoryService, child) {
                            // Loading state
                            if (categoryService.isLoading || categoryService.categories.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            // Filter based on selected filter
                            final historicalExpenses = expenseService.expenses
                                .where((e) {
                                  // If no filter selected (All), show paid + expired
                                  if (_selectedFilter == null) {
                                    return e.status == ExpenseStatus.paid ||
                                           e.status == ExpenseStatus.expired;
                                  }
                                  // Otherwise, show only selected status
                                  return e.status == _selectedFilter;
                                })
                                .toList()
                              ..sort((a, b) => b.date.compareTo(a.date)); // Newest first

                            // Empty state
                            if (historicalExpenses.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: 64,
                                        color: ThemeHelper.getSecondaryTextColor(context),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.noExpensesYet,
                                        style: Theme.of(context).textTheme.titleMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.addFirstExpense,
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

                            // Expense list
                            return ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: historicalExpenses.length,
                              itemBuilder: (context, index) {
                                final expense = historicalExpenses[index];
                                final isLast = index == historicalExpenses.length - 1;

                                // Find category (with fallback)
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
                                  showDivider: !isLast, // Hide divider on last item
                                  showStatus: true, // Show status in history
                                );
                              },
                            );
                          },
                        );
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
}
