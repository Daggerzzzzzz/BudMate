// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appName => 'BudMate';

  @override
  String get currency => 'Pera';

  @override
  String get language => 'Wika';

  @override
  String get darkMode => 'Madilim na Mode';

  @override
  String get enabled => 'Naka-enable';

  @override
  String get disabled => 'Naka-disable';

  @override
  String get logOut => 'Mag-log Out';

  @override
  String get aboutApp => 'Tungkol sa BudMate';

  @override
  String version(String version) {
    return 'Bersyon $version';
  }

  @override
  String get preferences => 'Mga Kagustuhan';

  @override
  String get account => 'Account';

  @override
  String get selectCurrency => 'Pumili ng Pera';

  @override
  String get selectLanguage => 'Pumili ng Wika';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get home => 'Tahanan';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get history => 'Kasaysayan';

  @override
  String get profile => 'Profile';

  @override
  String get logOutConfirmTitle => 'Mag-log Out';

  @override
  String get logOutConfirmMessage => 'Sigurado ka bang gusto mong mag-log out?';

  @override
  String get aboutAppDescription =>
      'Tumutulong ang BudMate na subaybayan ang iyong mga badyet at gastos nang madali. Pamahalaan ang iyong pananalapi, magtakda ng mga limitasyon sa paggastos, at manatiling nakatuon sa iyong mga layunin.';

  @override
  String get appCopyright => '© 2025 BudMate. Lahat ng karapatan ay nakalaan.';

  @override
  String get appTagline =>
      'Ang iyong kasosyo sa iyong mga pangangailangan sa badyet';

  @override
  String get expenseDashboard => 'Dashboard ng Gastos';

  @override
  String get budgetHealth => 'Kalusugan ng Badyet';

  @override
  String get spendingByCategory => 'Paggastos Ayon sa Kategorya';

  @override
  String get available => 'Magagamit';

  @override
  String get spent => 'Nagastos';

  @override
  String get budget => 'Badyet';

  @override
  String get thisMonth => 'Ngayong Buwan';

  @override
  String get lastThreeMonths => 'Huling 3 Buwan';

  @override
  String get allTime => 'Lahat ng Oras';

  @override
  String get noExpenseDataYet => 'Wala pang datos ng gastos';

  @override
  String get addExpensesToSeeAnalytics =>
      'Magdagdag ng gastos upang makita ang iyong analytics';

  @override
  String get expenseHistory => 'Kasaysayan ng Gastos';

  @override
  String get noExpensesYet => 'Wala pang gastos';

  @override
  String get addFirstExpense =>
      'Idagdag ang iyong unang gastos upang magsimulang subaybayan';

  @override
  String get searchExpenses => 'Maghanap ng gastos...';

  @override
  String get all => 'Lahat';

  @override
  String get paid => 'Bayad';

  @override
  String get pending => 'Nakabinbin';

  @override
  String get myBudgets => 'Aking mga Badyet';

  @override
  String get addBudget => 'Magdagdag ng Badyet';

  @override
  String get addExpense => 'Magdagdag ng Gastos';

  @override
  String get editBudget => 'I-edit ang Badyet';

  @override
  String get deleteBudget => 'Burahin ang Badyet';

  @override
  String get save => 'I-save';

  @override
  String get delete => 'Burahin';

  @override
  String get amount => 'Halaga';

  @override
  String get category => 'Kategorya';

  @override
  String get date => 'Petsa';

  @override
  String get note => 'Tala';

  @override
  String get status => 'Katayuan';

  @override
  String get welcomeBack => 'Maligayang pagbabalik';

  @override
  String get totalBalance => 'Kabuuang Balanse';

  @override
  String get recentExpenses => 'Mga Kamakailang Gastos';

  @override
  String get viewAll => 'Tingnan Lahat';

  @override
  String get seeAll => 'Tingnan Lahat';

  @override
  String get noRecentExpenses => 'Walang kamakailang gastos';

  @override
  String get notifications => 'Mga Abiso';

  @override
  String get notificationsEnabled => 'Tumanggap ng mga paalala sa gastos';

  @override
  String get notificationsDisabled => 'Walang paalala';

  @override
  String get upcomingExpenseTitle => 'Mga Gastos Bukas';

  @override
  String upcomingExpenseBody(int count, String amount) {
    return 'Mayroon kang $count gastos na dapat bayaran bukas na may kabuuang $amount';
  }
}
