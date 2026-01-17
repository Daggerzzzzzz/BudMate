import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/expense_service.dart';
import '../../../services/budget_service.dart';
import '../../../services/category_service.dart';
import '../../../services/preferences_service.dart';
import '../../../domain/expense_entity.dart';
import '../../../domain/budget_entity.dart';
import '../../../domain/category_entity.dart';
import '../../../core/managers/ui_manager.dart';
import '../../../core/extensions/list_extensions.dart';
import '../../shared/base_modal.dart';
import '../../shared/modal_text_button.dart';
import '../../shared/budget_display_card.dart';

/// Modal for paying existing upcoming expenses.
///
/// Opens from the center FAB "Pay Expenses" button in bottom navigation.
///
/// Displays a dropdown of unpaid expenses for the user to select and pay.
/// When an expense is paid:
/// 1. The expense is marked as paid (isPaid: true)
/// 2. The budget amount is decreased by the expense amount
/// 3. The expense is removed from the "Upcoming Expenses" list
/// 4. The expense appears in the expense history as paid
///
/// This modal UPDATES existing expenses rather than creating new ones.
/// To schedule new future expenses, use the Add Expense modal instead.
///
/// Required selection:
/// - Expense: Select from dropdown of unpaid expenses
///
/// Displays:
/// - Selected expense details (amount, category, date) - read-only
/// - Current available budget amount
///
/// Returns `true` if expense was paid successfully, `null` if cancelled.
class PayExpensesModal extends StatefulWidget {
  const PayExpensesModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return BaseModal.show<bool>(
      context: context,
      child: const PayExpensesModal(),
    );
  }

  @override
  State<PayExpensesModal> createState() => _PayExpensesModalState();
}

class _PayExpensesModalState extends State<PayExpensesModal> {
  // State
  String? _selectedExpenseId;
  bool _isLoading = false;

  // Services (lazy-loaded in didChangeDependencies)
  late ExpenseService _expenseService;
  late BudgetService _budgetService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _expenseService = context.read<ExpenseService>();
    _budgetService = context.read<BudgetService>();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      title: 'Pay Expenses',
      titleIcon: Icons.payments,
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    return Consumer<ExpenseService>(
      builder: (context, expenseService, child) {
        final budgetService = context.read<BudgetService>();
        final categoryService = context.read<CategoryService>();

        // Get screen dimensions for responsive spacing
        final screenHeight = MediaQuery.of(context).size.height;

        // Calculate responsive spacing values with clamping to prevent extreme values
        final largePadding = (screenHeight * 0.03).clamp(16.0, 32.0);   // ~24px on standard screen
        final mediumSpacing = (screenHeight * 0.02).clamp(12.0, 24.0);  // ~16px on standard screen
        final smallPadding = (screenHeight * 0.015).clamp(10.0, 20.0);  // ~12px on standard screen
        final tinySpacing = (screenHeight * 0.01).clamp(6.0, 12.0);     // ~8px on standard screen

        // Get pending expenses (unpaid) and deduplicate by ID
        final unpaidExpensesMap = <String, ExpenseEntity>{
          for (var e in expenseService.expenses.where((e) => e.status == ExpenseStatus.pending))
            e.id: e,
        };
        final unpaidExpenses = unpaidExpensesMap.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date

        // Validate selectedExpenseId exists in unpaidExpenses
        // If the previously selected expense is no longer unpaid, reset selection
        if (_selectedExpenseId != null &&
            !unpaidExpenses.any((e) => e.id == _selectedExpenseId)) {
          // Reset selection since the expense is no longer available
          // Use postFrameCallback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedExpenseId = null);
            }
          });
        }

        // Get budget health for accurate available balance
        final budgetHealth = budgetService.budgetHealth;
        final availableBalance = budgetHealth?.remainingAmount ?? 0.0;

        if (unpaidExpenses.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(largePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green.shade400,
                ),
                SizedBox(height: mediumSpacing),
                Text(
                  'No upcoming expenses to pay!',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tinySpacing),
                Text(
                  'Add future expenses using the "Expenses" button.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget display at top (matching Add Budget Modal pattern)
              BudgetDisplayCard(
                label: 'Available Budget',
                amount: availableBalance,
              ),
              SizedBox(height: mediumSpacing),

              // Dropdown of unpaid expenses
              DropdownButtonFormField<String>(
              key: ValueKey(_selectedExpenseId),
              initialValue: unpaidExpenses.any((e) => e.id == _selectedExpenseId)
                  ? _selectedExpenseId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Select Expense to Pay',
                prefixIcon: Icon(Icons.receipt_long),
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: unpaidExpenses.map((expense) {
                final category = categoryService.categories.firstWhereOrNull(
                  (c) => c.id == expense.categoryId,
                ) ?? const CategoryEntity(
                  id: 'unknown',
                  name: 'Unknown',
                  icon: 'category',
                  color: '9E9E9E',
                );

                return DropdownMenuItem<String>(
                  value: expense.id,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final currencySymbol = context.watch<PreferencesService>().currencySymbol;

                      return Text(
                        '${category.name} • ${UIManager.formatAmount(expense.amount, currencySymbol: currencySymbol)} • ${UIManager.formatDate(expense.date, format: 'MMM dd, yyyy')}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,  // Dynamic: ~3.5% of screen width
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() => _selectedExpenseId = value);
                    },
            ),

            // Selected expense details with inline status
            if (_selectedExpenseId != null &&
                unpaidExpenses.any((e) => e.id == _selectedExpenseId)) ...[
              SizedBox(height: mediumSpacing),
              _buildExpenseDetails(
                unpaidExpenses.firstWhere((e) => e.id == _selectedExpenseId),
                categoryService,
                smallPadding,
                tinySpacing,
                availableBalance,
              ),
            ],
          ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseDetails(
      ExpenseEntity expense,
      CategoryService categoryService,
      double padding,
      double spacing,
      double availableBalance) {
    final category = categoryService.categories.firstWhereOrNull(
      (c) => c.id == expense.categoryId,
    ) ?? const CategoryEntity(
      id: 'unknown',
      name: 'Unknown',
      icon: 'category',
      color: '9E9E9E',
    );
    final currencySymbol = context.watch<PreferencesService>().currencySymbol;

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                ),
                _buildPayableStatus(expense.amount, availableBalance),
              ],
            ),
            SizedBox(height: padding),
            _buildDetailRow(Icons.attach_money, 'Amount',
                UIManager.formatAmount(expense.amount, currencySymbol: currencySymbol)),
            SizedBox(height: spacing),
            _buildDetailRow(Icons.category, 'Category', category.name),
            SizedBox(height: spacing),
            _buildDetailRow(
                Icons.calendar_today, 'Date', UIManager.formatDate(expense.date)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Widget? statusWidget}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: statusWidget ?? Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPayableStatus(double expenseAmount, double availableBalance) {
    final isPayable = expenseAmount <= availableBalance;

    return Text(
      isPayable ? 'Payable' : 'Not Payable',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isPayable ? Colors.green.shade700 : Colors.orange.shade700,
          ),
    );
  }

  List<Widget> _buildActions() {
    // Access services to check budget
    final expenseService = context.read<ExpenseService>();
    final budgetService = context.read<BudgetService>();

    // Check if selected expense exceeds available budget
    final bool canPay = _selectedExpenseId != null &&
        !_isLoading &&
        !_expenseExceedsBudget(expenseService, budgetService);

    return [
      ModalTextButton(
        text: 'Pay',
        isPrimary: true,
        isLoading: _isLoading,
        onPressed: canPay ? _submitPayment : null,
      ),
      ModalTextButton(
        text: 'Cancel',
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      ),
    ];
  }

  /// Checks if the selected expense exceeds available budget
  bool _expenseExceedsBudget(ExpenseService expenseService, BudgetService budgetService) {
    if (_selectedExpenseId == null) return false;

    final expense = expenseService.expenses.firstWhereOrNull(
      (e) => e.id == _selectedExpenseId,
    );
    if (expense == null) return false;

    final budgetHealth = budgetService.budgetHealth;
    final availableBalance = budgetHealth?.remainingAmount ?? 0.0;

    return expense.amount > availableBalance;
  }

  Future<void> _submitPayment() async {
    if (_selectedExpenseId == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Get selected expense
      final expense = _expenseService.expenses
          .firstWhere((e) => e.id == _selectedExpenseId);

      // 2. Get current budget
      final currentBudget = _budgetService.budgets.isNotEmpty
          ? _budgetService.budgets.first
          : null;

      if (currentBudget == null) {
        if (!mounted) return;
        UIManager.showError(context, 'No budget found. Please add a budget first.');
        setState(() => _isLoading = false);
        return;
      }

      // Get available balance from budget health
      final budgetHealth = _budgetService.budgetHealth;
      final availableBalance = budgetHealth?.remainingAmount ?? 0.0;

      // Check if budget is sufficient for this payment
      if (expense.amount > availableBalance) {
        if (!mounted) return;
        final currencySymbol = context.read<PreferencesService>().currencySymbol;
        UIManager.showError(
          context,
          'Insufficient budget! Available: ${UIManager.formatAmount(availableBalance, currencySymbol: currencySymbol)}, '
          'Required: ${UIManager.formatAmount(expense.amount, currencySymbol: currencySymbol)}',
        );
        setState(() => _isLoading = false);
        return;
      }

      // 3. Mark expense as paid (UPDATE)
      final updateExpenseResult = await _expenseService.updateExpense(
        ExpenseEntity(
          id: expense.id,
          userId: expense.userId,
          amount: expense.amount,
          categoryId: expense.categoryId,
          date: expense.date,
          status: ExpenseStatus.paid, // Mark as paid
        ),
      );

      // Handle expense update result
      await updateExpenseResult.fold(
        (failure) async {
          if (!mounted) return;
          UIManager.showError(context, failure.message);
          setState(() => _isLoading = false);
        },
        (updatedExpense) async {
          // 4. Deduct from budget (UPDATE)
          final newBudgetAmount = currentBudget.amount - expense.amount;

          final updateBudgetResult = await _budgetService.updateBudget(
            BudgetEntity(
              id: currentBudget.id,
              userId: currentBudget.userId,
              amount: newBudgetAmount,
              createdAt: currentBudget.createdAt,
              updatedAt: DateTime.now(),
            ),
          );

          if (!mounted) return;

          updateBudgetResult.fold(
            (failure) {
              UIManager.showError(context, failure.message);
              setState(() => _isLoading = false);
            },
            (updatedBudget) {
              UIManager.showSuccess(
                  context, 'Expense paid successfully! Budget updated.');
              _selectedExpenseId = null; // Reset selection
              Navigator.of(context).pop(true);
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      UIManager.showError(context, 'Error: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }
}
