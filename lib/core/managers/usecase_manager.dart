import 'package:budmate/core/managers/repository_manager.dart';
import 'package:budmate/usecases/auth/sign_in_with_email.dart';
import 'package:budmate/usecases/auth/sign_in_with_google.dart';
import 'package:budmate/usecases/auth/sign_up_with_email.dart';
import 'package:budmate/usecases/auth/sign_out.dart';
import 'package:budmate/usecases/auth/get_current_user.dart';
import 'package:budmate/usecases/auth/send_verification_email.dart';
import 'package:budmate/usecases/auth/check_email_verified.dart';
import 'package:budmate/usecases/auth/clear_all_data.dart';
import 'package:budmate/usecases/budget/create_budget.dart';
import 'package:budmate/usecases/budget/get_budgets.dart';
import 'package:budmate/usecases/budget/update_budget.dart';
import 'package:budmate/usecases/budget/delete_budget.dart';
import 'package:budmate/usecases/category/create_category.dart';
import 'package:budmate/usecases/category/get_categories.dart';
import 'package:budmate/usecases/category/update_category.dart';
import 'package:budmate/usecases/category/delete_category.dart';
import 'package:budmate/usecases/expense/create_expense.dart';
import 'package:budmate/usecases/expense/get_expenses.dart';
import 'package:budmate/usecases/expense/update_expense.dart';
import 'package:budmate/usecases/expense/delete_expense.dart';

/// Factory for creating grouped use case instances.
///
/// Groups related use cases into value objects (AuthUseCases, BudgetUseCases, CategoryUseCases,
/// ExpenseUseCases) to simplify Provider setup and service constructors. Instead of 24 separate
/// use case parameters, services receive 4 grouped objects. Makes dependency graph clearer and
/// reduces boilerplate from 16 Provider entries to 4.
///
/// Use case groups:
/// - AuthUseCases: 8 auth operations (signIn, signUp, signOut, getCurrentUser, etc.)
/// - BudgetUseCases: 4 CRUD operations (create, get, update, delete)
/// - CategoryUseCases: 4 CRUD operations
/// - ExpenseUseCases: 4 CRUD operations
///
/// Benefits: Cleaner service constructors, fewer Provider entries, grouped logical operations
class UseCaseManager {
  static AuthUseCases createAuthUseCases(AuthRepository repository) {
    return AuthUseCases(
      signInWithEmail: SignInWithEmail(repository),
      signInWithGoogle: SignInWithGoogle(repository),
      signUpWithEmail: SignUpWithEmail(repository),
      signOut: SignOut(repository),
      getCurrentUser: GetCurrentUser(repository),
      sendVerificationEmail: SendVerificationEmail(repository),
      checkEmailVerified: CheckEmailVerified(repository),
      clearAllData: ClearAllData(repository),
    );
  }

  static BudgetUseCases createBudgetUseCases(BudgetRepository repository) {
    return BudgetUseCases(
      create: CreateBudget(repository),
      get: GetBudgets(repository),
      update: UpdateBudget(repository),
      delete: DeleteBudget(repository),
    );
  }

  static CategoryUseCases createCategoryUseCases(
    CategoryRepository repository,
  ) {
    return CategoryUseCases(
      create: CreateCategory(repository),
      get: GetCategories(repository),
      update: UpdateCategory(repository),
      delete: DeleteCategory(repository),
    );
  }

  static ExpenseUseCases createExpenseUseCases(ExpenseRepository repository) {
    return ExpenseUseCases(
      create: CreateExpense(repository),
      get: GetExpenses(repository),
      update: UpdateExpense(repository),
      delete: DeleteExpense(repository),
    );
  }
}

class AuthUseCases {
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignUpWithEmail signUpWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final SendVerificationEmail sendVerificationEmail;
  final CheckEmailVerified checkEmailVerified;
  final ClearAllData clearAllData;

  AuthUseCases({
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.signUpWithEmail,
    required this.signOut,
    required this.getCurrentUser,
    required this.sendVerificationEmail,
    required this.checkEmailVerified,
    required this.clearAllData,
  });
}

class BudgetUseCases {
  final CreateBudget create;
  final GetBudgets get;
  final UpdateBudget update;
  final DeleteBudget delete;

  BudgetUseCases({
    required this.create,
    required this.get,
    required this.update,
    required this.delete,
  });
}

class CategoryUseCases {
  final CreateCategory create;
  final GetCategories get;
  final UpdateCategory update;
  final DeleteCategory delete;

  CategoryUseCases({
    required this.create,
    required this.get,
    required this.update,
    required this.delete,
  });
}

class ExpenseUseCases {
  final CreateExpense create;
  final GetExpenses get;
  final UpdateExpense update;
  final DeleteExpense delete;

  ExpenseUseCases({
    required this.create,
    required this.get,
    required this.update,
    required this.delete,
  });
}
