library;

/// Application-wide configuration constants for BudMate.
///
/// This class centralizes all app-level configuration values including app metadata,
/// formatting preferences, and business logic thresholds. Using constants prevents
/// magic numbers/strings scattered throughout the codebase and enables easy updates.
///
/// Constant categories:
/// - App metadata: name, version
/// - Date/time formats: dateFormat, dateTimeFormat
/// - Currency settings: currencySymbol, currencyDecimalPlaces
/// - Business thresholds: budgetAlertThreshold (90% spending triggers alerts)
class AppConstants {
  AppConstants._();

  static const String appName = 'BudMate';
  static const String appVersion = '0.1.0';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String currencySymbol = 'PHP';
  static const int currencyDecimalPlaces = 2;
  static const double budgetAlertThreshold = 0.90;
}

/// Firebase Authentication error codes and user-friendly messages.
///
/// Centralizes all Firebase-specific constants to ensure consistent error handling
/// throughout the authentication flow. This prevents scattered error code strings and
/// inconsistent messaging across different parts of the application.
///
/// Contains two groups of constants:
/// - Auth error codes: Firebase error code strings for programmatic error checking
/// - User-friendly messages: Human-readable error messages displayed to users
///
/// Error codes match Firebase Authentication error responses and are used to provide
/// appropriate user feedback based on the specific authentication failure reason.
class FirebaseConstants {
  FirebaseConstants._();

  static const String authErrorEmailAlreadyInUse = 'email-already-in-use';
  static const String authErrorInvalidEmail = 'invalid-email';
  static const String authErrorUserNotFound = 'user-not-found';
  static const String authErrorWrongPassword = 'wrong-password';
  static const String authErrorWeakPassword = 'weak-password';
  static const String authErrorUserDisabled = 'user-disabled';
  static const String authErrorTooManyRequests = 'too-many-requests';
  static const String authErrorOperationNotAllowed = 'operation-not-allowed';

  static const String messageAuthError = 'Authentication failed. Please try again.';
  static const String messageEmailInUse =
      'This email is already registered. Please sign in instead.';
  static const String messageInvalidEmail =
      'Invalid email address. Please check and try again.';
  static const String messageUserNotFound =
      'No account found with this email. Please sign up first.';
  static const String messageWrongPassword =
      'Incorrect password. Please try again.';
  static const String messageWeakPassword =
      'Password is too weak. Please use a stronger password.';
  static const String messageNetworkError =
      'Network error. Please check your connection and try again.';
}

/// Budget period constants for Firestore storage.
///
/// Defines valid values for budget period field in Firestore documents.
/// These constants ensure consistent period naming across the application.
class BudgetPeriods {
  BudgetPeriods._();

  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
}

/// Supported currencies for the application.
///
/// Defines available currency options and their symbols.
/// Currently supports PHP (Philippine Peso), USD (US Dollar), EUR (Euro),
/// JPY (Japanese Yen), and GBP (British Pound).
///
/// Note: Currency only affects display symbol. Exchange rates and conversion
/// are future enhancements.
class SupportedCurrencies {
  SupportedCurrencies._();

  static const String php = 'PHP';
  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String jpy = 'JPY';
  static const String gbp = 'GBP';

  static const List<String> all = [php, usd, eur, jpy, gbp];

  static const Map<String, String> symbols = {
    php: '₱',
    usd: '\$',
    eur: '€',
    jpy: '¥',
    gbp: '£',
  };
}

/// Supported languages for the application.
///
/// Defines available language options with their locale codes and display names.
/// Currently supports English and Filipino.
///
/// Note: For MVP, only language preference is stored. Full localization (l10n)
/// with translated UI strings is a future enhancement requiring intl package.
class SupportedLanguages {
  SupportedLanguages._();

  static const String english = 'en';
  static const String filipino = 'fil';

  static const List<String> all = [english, filipino];

  static const Map<String, String> names = {
    english: 'English',
    filipino: 'Filipino',
  };
}

/// Theme mode constants for the application.
///
/// Defines valid theme mode values: light, dark, and system (follows device setting).
/// Used by PreferencesService to manage theme preference.
class ThemeModes {
  ThemeModes._();

  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
}

/// Notification configuration constants for flutter_local_notifications.
///
/// Defines channel IDs, notification IDs, and default scheduling times
/// for the expense reminder notification system.
class NotificationConstants {
  NotificationConstants._();

  /// Android notification channel ID for expense reminders.
  static const String channelId = 'expense_reminders';

  /// Android notification channel name displayed in system settings.
  static const String channelName = 'Expense Reminders';

  /// Android notification channel description.
  static const String channelDescription =
      'Daily notifications for upcoming expenses';

  /// Notification ID for upcoming expense notifications (single ID for daily summary).
  static const int upcomingExpenseNotificationId = 1001;
}
