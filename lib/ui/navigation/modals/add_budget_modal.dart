import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/budget_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/preferences_service.dart';
import '../../../domain/budget_entity.dart';
import '../../../core/managers/ui_manager.dart';
import '../../shared/base_modal.dart';
import '../../shared/modal_text_button.dart';
import '../../shared/budget_display_card.dart';

/// Modal for adding budget amount.
///
/// Opens from the "Budget" action button on the home screen budget card.
///
/// Collects a budget amount to add to the user's available budget. This modal
/// operates on a running total model:
/// - If no budget exists: Creates a new budget with the entered amount
/// - If budget exists: Adds the entered amount to the existing budget
///
/// This allows users to incrementally add budget as they receive income.
///
/// Required fields:
/// - Amount: Positive decimal number with PHP currency
///
/// Returns `true` if budget was added successfully, `null` if cancelled.
class AddBudgetModal extends StatefulWidget {
  const AddBudgetModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return BaseModal.show<bool>(
      context: context,
      child: const AddBudgetModal(),
    );
  }

  @override
  State<AddBudgetModal> createState() => _AddBudgetModalState();
}

class _AddBudgetModalState extends State<AddBudgetModal> {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  // State
  bool _isLoading = false;

  // Services
  late BudgetService _budgetService;
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _budgetService = context.read<BudgetService>();
    _authService = context.read<AuthService>();
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Checks if the entered amount would cause available budget to go negative.
  /// Returns true if the operation is invalid (would result in negative budget).
  bool _wouldResultInNegativeBudget() {
    final text = _amountController.text;
    if (text.isEmpty) return false;

    final amount = double.tryParse(text);
    if (amount == null) return false;

    // Only check negative amounts
    if (amount >= 0) return false;

    // Use availableBalance (remainingAmount) not total budget amount
    // This is what the user sees in the "Available Budget" display
    final budgetHealth = _budgetService.budgetHealth;
    final availableBalance = budgetHealth?.remainingAmount ?? 0.0;

    return (availableBalance + amount) < 0;
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      title: 'Add Budget',
      titleIcon: Icons.account_balance_wallet,
      content: _buildForm(),
      actions: _buildActions(),
    );
  }

  Widget _buildForm() {
    return Consumer<BudgetService>(
      builder: (context, budgetService, child) {
        // Get budget health for accurate available balance
        final budgetHealth = budgetService.budgetHealth;
        final availableBalance = budgetHealth?.remainingAmount ?? 0.0;

        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Budget Display
              BudgetDisplayCard(
                label: 'Available Budget',
                amount: availableBalance,
              ),
              const SizedBox(height: 16),
              // Amount field
              Builder(
                builder: (context) {
                  final currencySymbol = context.watch<PreferencesService>().currencySymbol;
                  return TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '$currencySymbol ',
                      hintText: '0.00',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    autofocus: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount == 0) {
                        return 'Please enter valid amount';
                      }
                      return null;
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildActions() {
    final bool canSubmit = !_isLoading && !_wouldResultInNegativeBudget();

    return [
      ModalTextButton(
        text: 'Add Budget',
        isPrimary: true,
        isLoading: _isLoading,
        onPressed: canSubmit ? _submitForm : null,
      ),
      ModalTextButton(
        text: 'Cancel',
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      ),
    ];
  }

  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final userId = _authService.currentUser!.id;

      // Check if budget exists
      final existingBudget = _budgetService.budgets.isNotEmpty
          ? _budgetService.budgets.first
          : null;

      if (existingBudget != null) {
        // ADD to existing budget
        final newAmount = existingBudget.amount + amount;
        final result = await _budgetService.updateBudget(
          BudgetEntity(
            id: existingBudget.id,
            userId: existingBudget.userId,
            amount: newAmount,
            createdAt: existingBudget.createdAt,
            updatedAt: DateTime.now(),
          ),
        );

        if (!mounted) return;

        result.fold(
          (failure) {
            UIManager.showError(context, failure.message);
            setState(() => _isLoading = false);
          },
          (updatedBudget) {
            UIManager.showSuccess(context, amount > 0 ? 'Budget added!' : 'Budget reduced!');
            Navigator.of(context).pop(true);
          },
        );
      } else {
        // CREATE new budget - only allow positive amounts
        if (amount < 0) {
          UIManager.showError(context, 'Please add a budget first before reducing');
          setState(() => _isLoading = false);
          return;
        }
        final budget = BudgetEntity(
          id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          amount: amount,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await _budgetService.createBudget(budget);

        if (!mounted) return;

        result.fold(
          (failure) {
            UIManager.showError(context, failure.message);
            setState(() => _isLoading = false);
          },
          (createdBudget) {
            UIManager.showSuccess(context, 'Budget added successfully!');
            Navigator.of(context).pop(true);
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      UIManager.showError(context, 'Invalid input: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }
}
