// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BudMate';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get logOut => 'Log Out';

  @override
  String get aboutApp => 'About BudMate';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get preferences => 'Preferences';

  @override
  String get account => 'Account';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get logOutConfirmTitle => 'Log Out';

  @override
  String get logOutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get aboutAppDescription =>
      'BudMate helps you track your budgets and expenses with ease. Manage your finances, set spending limits, and stay on top of your goals.';

  @override
  String get appCopyright => '© 2025 BudMate. All rights reserved.';

  @override
  String get appTagline => 'Your partner for your budgeting needs';

  @override
  String get expenseDashboard => 'Expense Dashboard';

  @override
  String get budgetHealth => 'Budget Health';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get available => 'Available';

  @override
  String get spent => 'Spent';

  @override
  String get budget => 'Budget';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastThreeMonths => 'Last 3 Months';

  @override
  String get allTime => 'All Time';

  @override
  String get noExpenseDataYet => 'No expense data yet';

  @override
  String get addExpensesToSeeAnalytics =>
      'Add expenses to see your spending analytics';

  @override
  String get expenseHistory => 'Expense History';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get addFirstExpense => 'Add your first expense to start tracking';

  @override
  String get searchExpenses => 'Search expenses...';

  @override
  String get all => 'All';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get myBudgets => 'My Budgets';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get status => 'Status';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String get viewAll => 'View All';

  @override
  String get seeAll => 'See All';

  @override
  String get noRecentExpenses => 'No recent expenses';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Receive expense reminders';

  @override
  String get notificationsDisabled => 'No reminders';

  @override
  String get upcomingExpenseTitle => 'Upcoming Expenses Tomorrow';

  @override
  String upcomingExpenseBody(int count, String amount) {
    return 'You have $count expense(s) due tomorrow totaling $amount';
  }
}
