import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:budmate/services/auth_service.dart';
import 'package:budmate/services/budget_service.dart';
import 'package:budmate/services/category_service.dart';
import 'package:budmate/services/expense_service.dart';
import 'package:budmate/services/notification_service.dart';
import 'package:budmate/core/managers/budget_manager.dart';
import 'package:budmate/core/managers/usecase_manager.dart';

/// Factory for creating and wiring presentation services with Provider.
///
/// Centralizes service instantiation and cross-service callback wiring to reduce main.dart
/// complexity. Automatically handles service dependencies (AuthService needs CategoryService,
/// ExpenseService triggers BudgetService refresh) and returns pre-configured ChangeNotifierProvider
/// widgets ready for MultiProvider setup.
///
/// Service wiring:
/// - CategoryService: Standalone (created first)
/// - AuthService: Depends on CategoryService, auto-checks auth state
/// - BudgetService: Uses BudgetManager for health calculations
/// - ExpenseService: Auto-wires callback to refresh BudgetService on expense changes
///
/// Benefits: Reduces main.dart by ~48 lines, single source of truth for service dependencies
class ServiceManager {
  static List<SingleChildWidget> createProviders({
    required AuthUseCases authUseCases,
    required BudgetUseCases budgetUseCases,
    required CategoryUseCases categoryUseCases,
    required ExpenseUseCases expenseUseCases,
    required BudgetManager budgetManager,
    CategoryService? categoryService,
    NotificationService? notificationService,
  }) {
    final finalCategoryService = categoryService ?? CategoryService(
      categoryUseCases: categoryUseCases,
    );

    final authService = AuthService(
      authUseCases: authUseCases,
      categoryService: finalCategoryService,
    );
    authService.checkAuthState();

    final budgetService = BudgetService(
      budgetUseCases: budgetUseCases,
      budgetManager: budgetManager,
    );

    final expenseService = ExpenseService(
      expenseUseCases: expenseUseCases,
    );

    expenseService.onExpenseChanged = (userId) {
      budgetService.refreshBudgetHealth(userId);
    };

    final finalNotificationService =
        notificationService ?? NotificationService();

    return [
      ChangeNotifierProvider.value(
        value: finalCategoryService,
      ),
      ChangeNotifierProvider.value(
        value: authService,
      ),
      ChangeNotifierProvider.value(
        value: budgetService,
      ),
      ChangeNotifierProvider.value(
        value: expenseService,
      ),
      ChangeNotifierProvider.value(
        value: finalNotificationService,
      ),
    ];
  }
}
