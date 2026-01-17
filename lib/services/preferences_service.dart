import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/logger.dart';

/// Service managing user preferences with local persistence.
///
/// Follows the same pattern as AuthService using ChangeNotifier for reactive UI updates.
/// Stores preferences locally using SharedPreferences (no server sync).
///
/// Managed preferences:
/// - Currency (PHP, USD, EUR, JPY, GBP) - affects display symbol only
/// - Language (English, Filipino) - stored for future localization
/// - Theme mode (light, dark, system) - controls app theme
///
/// All preferences are cached in memory after initial load for fast access.
/// Changes are immediately persisted to SharedPreferences and broadcast to listeners.
///
/// Example usage:
/// ```dart
/// // In Provider tree:
/// ChangeNotifierProvider(
///   create: (_) => PreferencesService(sharedPreferences),
/// )
///
/// // In widgets:
/// Consumer<PreferencesService>(
///   builder: (context, prefs, _) {
///     return Text('${prefs.currencySymbol} 100.00');
///   },
/// )
///
/// // Or:
/// final prefs = context.read<PreferencesService>();
/// await prefs.setCurrency(SupportedCurrencies.usd);
/// ```
class PreferencesService extends ChangeNotifier {
  final SharedPreferences _prefs;

  // SharedPreferences keys
  static const String _currencyKey = 'user_currency';
  static const String _languageKey = 'user_language';
  static const String _themeModeKey = 'user_theme_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Current cached values
  String _currency = SupportedCurrencies.php;
  String _language = SupportedLanguages.english;
  String _themeMode = ThemeModes.light;
  bool _notificationsEnabled = false;

  PreferencesService(this._prefs) {
    _loadPreferences();
  }

  // Getters for current preferences
  String get currency => _currency;
  String get currencySymbol => SupportedCurrencies.symbols[_currency] ?? '₱';
  String get language => _language;
  String get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeModes.dark;
  bool get isLightMode => _themeMode == ThemeModes.light;
  bool get isSystemMode => _themeMode == ThemeModes.system;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Load preferences from SharedPreferences on initialization.
  ///
  /// Defaults:
  /// - Currency: PHP (Philippine Peso)
  /// - Language: English
  /// - Theme: Light mode
  Future<void> _loadPreferences() async {
    try {
      _currency = _prefs.getString(_currencyKey) ?? SupportedCurrencies.php;
      _language = _prefs.getString(_languageKey) ?? SupportedLanguages.english;
      _themeMode = _prefs.getString(_themeModeKey) ?? ThemeModes.light;
      _notificationsEnabled = _prefs.getBool(_notificationsEnabledKey) ?? false;

      Logger.info('Preferences loaded: currency=$_currency, language=$_language, theme=$_themeMode, notifications=$_notificationsEnabled');
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load preferences, using defaults',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set currency preference.
  ///
  /// Validates that currency is in supported list before saving.
  /// Immediately persists to SharedPreferences and notifies listeners.
  Future<void> setCurrency(String currency) async {
    if (!SupportedCurrencies.all.contains(currency)) {
      Logger.debug('Invalid currency: $currency');
      return;
    }

    _currency = currency;
    await _prefs.setString(_currencyKey, currency);
    Logger.info('Currency preference updated: $currency');
    notifyListeners();
  }

  /// Set language preference.
  ///
  /// Validates that language is in supported list before saving.
  /// Note: For MVP, UI remains in English. This sets foundation for future l10n.
  Future<void> setLanguage(String language) async {
    if (!SupportedLanguages.all.contains(language)) {
      Logger.debug('Invalid language: $language');
      return;
    }

    _language = language;
    await _prefs.setString(_languageKey, language);
    Logger.info('Language preference updated: $language');
    notifyListeners();
  }

  /// Set theme mode preference.
  ///
  /// Accepts: light, dark, or system.
  /// System mode follows device theme settings.
  Future<void> setThemeMode(String mode) async {
    final validModes = [ThemeModes.light, ThemeModes.dark, ThemeModes.system];
    if (!validModes.contains(mode)) {
      Logger.debug('Invalid theme mode: $mode');
      return;
    }

    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode);
    Logger.info('Theme mode updated: $mode');
    notifyListeners();
  }

  /// Toggle between light and dark mode.
  ///
  /// Convenience method for theme switch. Toggles between light and dark only,
  /// does not set system mode.
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeModes.light
        ? ThemeModes.dark
        : ThemeModes.light;
    await setThemeMode(newMode);
  }

  /// Set notification preference.
  ///
  /// When enabled, app will send daily notifications for upcoming expenses.
  /// Immediately persists to SharedPreferences and notifies listeners.
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool(_notificationsEnabledKey, enabled);
    Logger.info('Notifications preference updated: $enabled');
    notifyListeners();
  }

  /// Toggle notification preference.
  ///
  /// Convenience method for notification switch. Toggles between enabled/disabled.
  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!_notificationsEnabled);
  }

  /// Reset all preferences to defaults.
  ///
  /// Useful for testing or user-requested reset.
  Future<void> resetToDefaults() async {
    _currency = SupportedCurrencies.php;
    _language = SupportedLanguages.english;
    _themeMode = ThemeModes.light;
    _notificationsEnabled = false;

    await _prefs.remove(_currencyKey);
    await _prefs.remove(_languageKey);
    await _prefs.remove(_themeModeKey);
    await _prefs.remove(_notificationsEnabledKey);

    Logger.info('Preferences reset to defaults');
    notifyListeners();
  }
}
