import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/managers/navigation_manager.dart';
import '../../core/utils/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../../services/notification_service.dart';
import '../shared/profile_header.dart';
import '../shared/settings_list_item.dart';
import '../shared/settings_section_header.dart';
import 'modals/currency_picker_modal.dart';
import 'modals/language_picker_modal.dart';

/// Profile and Settings screen following Mari Bank UI design pattern.
///
/// Provides user preferences management including:
/// - Currency selection (PHP, USD, EUR, JPY, GBP)
/// - Language preference (English, Filipino - foundation for future l10n)
/// - Theme mode toggle (Light/Dark mode)
/// - About app information
/// - Logout functionality
///
/// Uses clean list-based layout with:
/// - ProfileHeader at top (user avatar, name, email)
/// - Sectioned settings list (Preferences, Account)
/// - Prominent logout button at bottom (Mari Bank style)
///
/// All preferences are stored locally via PreferencesService using SharedPreferences.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // User info header (teal background, no logout button)
          const ProfileHeader(),

          // Settings list (white background, scrollable)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeHelper.getSurfaceColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                const SizedBox(height: 8),

                // Preferences Section
                SettingsSectionHeader(title: l10n.preferences),
                _buildCurrencySetting(context),
                _buildLanguageSetting(context),
                _buildThemeSetting(context),

                const SizedBox(height: 24),

                // Account Section
                SettingsSectionHeader(title: l10n.account),
                _buildNotificationSetting(context),

                const SizedBox(height: 32),

                // Logout button at bottom (Mari Bank style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildLogoutButton(context),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  /// Currency setting row with current value and navigation arrow.
  Widget _buildCurrencySetting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<PreferencesService>(
      builder: (context, prefs, _) {
        return SettingsListItem(
          icon: Icons.attach_money,
          iconColor: Colors.green.shade600,
          title: l10n.currency,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prefs.currency,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          onTap: () => _showCurrencyPicker(context),
        );
      },
    );
  }

  /// Language setting row with current value and navigation arrow.
  Widget _buildLanguageSetting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<PreferencesService>(
      builder: (context, prefs, _) {
        final languageName = SupportedLanguages.names[prefs.language] ?? 'English';
        return SettingsListItem(
          icon: Icons.language,
          iconColor: Colors.blue.shade600,
          title: l10n.language,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageName,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          onTap: () => _showLanguagePicker(context),
        );
      },
    );
  }

  /// Theme setting row with switch toggle for dark mode.
  Widget _buildThemeSetting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<PreferencesService>(
      builder: (context, prefs, _) {
        final isDark = prefs.themeMode == ThemeModes.dark;
        return SettingsListItem(
          icon: isDark ? Icons.dark_mode : Icons.light_mode,
          iconColor: isDark ? Colors.indigo.shade600 : Colors.orange.shade600,
          title: l10n.darkMode,
          subtitle: isDark ? l10n.enabled : l10n.disabled,
          trailing: Switch(
            value: isDark,
            onChanged: (_) => prefs.toggleTheme(),
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  /// Notification setting row with switch toggle for expense reminders.
  ///
  /// Follows the same pattern as _buildThemeSetting for consistency.
  /// When toggled on, requests notification permission if not already granted.
  Widget _buildNotificationSetting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<PreferencesService, NotificationService>(
      builder: (context, prefs, notifications, _) {
        final enabled = prefs.notificationsEnabled;
        return SettingsListItem(
          icon: enabled ? Icons.notifications_active : Icons.notifications_off,
          iconColor: enabled ? Colors.amber.shade600 : Colors.grey.shade600,
          title: l10n.notifications,
          subtitle:
              enabled ? l10n.notificationsEnabled : l10n.notificationsDisabled,
          trailing: Switch(
            value: enabled,
            onChanged: (_) async {
              await prefs.toggleNotifications();
              // Request permission when enabling notifications
              if (prefs.notificationsEnabled) {
                await notifications.requestPermission();
              }
            },
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  /// Logout button with white background and black text (Mari Bank style).
  Widget _buildLogoutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: Icon(Icons.logout, color: ThemeHelper.getTextColor(context)),
        label: Text(l10n.logOut),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeHelper.getElevatedSurfaceColor(context),
          foregroundColor: ThemeHelper.getTextColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: ThemeHelper.getBorderColor(context)),
          ),
        ),
      ),
    );
  }

  /// Show currency picker modal.
  Future<void> _showCurrencyPicker(BuildContext context) async {
    final prefs = context.read<PreferencesService>();

    await CurrencyPickerModal.show(
      context,
      currentCurrency: prefs.currency,
    );
  }

  /// Show language picker modal.
  Future<void> _showLanguagePicker(BuildContext context) async {
    final prefs = context.read<PreferencesService>();

    await LanguagePickerModal.show(
      context,
      currentLanguage: prefs.language,
    );
  }

  /// Handle logout with confirmation dialog.
  ///
  /// After sign-out, AuthWrapper automatically switches to LoginScreen
  /// when isUserLoggedIn becomes false. No manual navigation needed.
  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await NavigationManager.showConfirmDialog(
      context,
      title: l10n.logOutConfirmTitle,
      message: l10n.logOutConfirmMessage,
      confirmText: l10n.logOut,
      cancelText: l10n.cancel,
    );

    if (confirmed == true && context.mounted) {
      final auth = context.read<AuthService>();
      await auth.signOut();
      // AuthWrapper handles navigation automatically
    }
  }
}
