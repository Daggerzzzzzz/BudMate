import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/expense_service.dart';
import '../../../services/category_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/preferences_service.dart';
import '../../../domain/expense_entity.dart';
import '../../../core/managers/ui_manager.dart';
import '../../shared/base_modal.dart';
import '../../shared/modal_text_button.dart';

/// Modal for scheduling upcoming expenses (future bills).
///
/// Opens from the "Expenses" action button on the home screen budget card.
///
/// Allows users to schedule future bills and expenses to pay later. These
/// scheduled expenses appear in the "Upcoming Expenses" list on the home screen
/// (sorted by nearest date first). Unlike PayExpensesModal which records
/// immediate/past payments, this modal creates future-dated expense entries.
///
/// Expenses are distinguished as "upcoming" vs "paid" by the isPaid field:
/// - Upcoming: isPaid == false && date >= DateTime.now()
/// - Paid: isPaid == true (regardless of date)
///
/// This modal always sets isPaid to false when creating scheduled expenses.
///
/// Required fields:
/// - Amount: Positive decimal number with PHP currency
/// - Category: Selected from CategoryService.categories
/// - Date: Any date from today to 1 year ahead (defaults to today)
///
/// Returns `true` if expense was scheduled successfully, `null` if cancelled.
class ExpensesModal extends StatefulWidget {
  const ExpensesModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return BaseModal.show<bool>(
      context: context,
      child: const ExpensesModal(),
    );
  }

  @override
  State<ExpensesModal> createState() => _ExpensesModalState();
}

class _ExpensesModalState extends State<ExpensesModal> {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Services (lazy-loaded in didChangeDependencies)
  late ExpenseService _expenseService;
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _expenseService = context.read<ExpenseService>();
    _authService = context.read<AuthService>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      title: 'Add Expense',
      titleIcon: Icons.schedule,
      content: _buildForm(),
      actions: _buildActions(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Category dropdown
          Consumer<CategoryService>(
            builder: (context, categoryService, child) {
              if (categoryService.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (categoryService.categories.isEmpty) {
                return Text(
                  'No categories available. Please create a category first.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                );
              }

              return DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: categoryService.categories
                    .map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Date picker (ALLOWS FUTURE DATES)
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today),
                helperText: 'Schedule for a future date',
              ),
              child: Text(
                UIManager.formatDate(_selectedDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      ModalTextButton(
        text: 'Schedule',
        isPrimary: true,
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _submitForm,
      ),
      ModalTextButton(
        text: 'Cancel',
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      ),
    ];
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),  // Today onwards
      lastDate: DateTime.now().add(const Duration(days: 365)),  // 1 year ahead
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse amount
      final amount = double.parse(_amountController.text);
      final userId = _authService.currentUser!.id;

      // Create entity
      final expense = ExpenseEntity(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        status: ExpenseStatus.pending,  // Always pending when creating new expenses
      );

      // Call service
      final result = await _expenseService.createExpense(expense);

      if (!mounted) return;

      result.fold(
        (failure) {
          UIManager.showError(context, failure.message);
          setState(() => _isLoading = false);
        },
        (createdExpense) {
          UIManager.showSuccess(context, 'Expense scheduled successfully');
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      UIManager.showError(context, 'Invalid input: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }
}
