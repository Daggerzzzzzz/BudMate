import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/constants.dart';
import '../core/logger.dart';
import '../domain/expense_entity.dart';

/// Service managing local push notifications for expense reminders.
///
/// Follows the same ChangeNotifier pattern as other presentation services.
/// Wraps flutter_local_notifications to provide:
/// - Notification permission handling
/// - Channel initialization for Android
/// - Scheduling daily expense reminder notifications
/// - Showing immediate notifications for tomorrow's expenses
///
/// Notification flow:
/// 1. Initialize plugin on app startup
/// 2. Request permissions when user enables notifications
/// 3. Check for tomorrow's pending expenses
/// 4. Show grouped notification with expense count and total amount
///
/// Example usage:
/// ```dart
/// // In Provider tree (via ServiceManager):
/// ChangeNotifierProvider.value(value: notificationService)
///
/// // Trigger check (e.g., on app resume or after expense changes):
/// await notificationService.checkAndNotifyUpcomingExpenses(
///   expenses: expenseService.expenses,
///   currencySymbol: prefsService.currencySymbol,
///   notificationTitle: l10n.upcomingExpenseTitle,
///   notificationBodyBuilder: (count, amount) => l10n.upcomingExpenseBody(count, amount),
/// );
/// ```
class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  bool _isInitialized = false;
  bool _hasPermission = false;

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Whether the notification plugin has been initialized.
  bool get isInitialized => _isInitialized;

  /// Whether notification permission has been granted.
  bool get hasPermission => _hasPermission;

  /// Initialize the notification plugin and create Android channel.
  ///
  /// Must be called once on app startup before showing notifications.
  /// Creates the notification channel on Android for expense reminders.
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.debug('NotificationService: Already initialized');
      return;
    }

    Logger.info('NotificationService: Initializing...');

    try {
      // Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS/macOS initialization settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // Request explicitly when needed
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = initialized ?? false;
      Logger.info(
          'NotificationService: Initialized successfully: $_isInitialized');
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error(
        'NotificationService: Failed to initialize',
        error: e,
        stackTrace: stackTrace,
      );
      _isInitialized = false;
    }
  }

  /// Request notification permissions from the user.
  ///
  /// On Android 13+, requests POST_NOTIFICATIONS permission.
  /// On iOS, requests alert/badge/sound permissions.
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    Logger.info('NotificationService: Requesting permission...');

    try {
      // Android 13+ permission request
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        _hasPermission = granted ?? false;
        Logger.info(
            'NotificationService: Android permission granted: $_hasPermission');
      }

      // iOS permission request
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _hasPermission = granted ?? false;
        Logger.info(
            'NotificationService: iOS permission granted: $_hasPermission');
      }

      notifyListeners();
      return _hasPermission;
    } catch (e, stackTrace) {
      Logger.error(
        'NotificationService: Failed to request permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Check for tomorrow's pending expenses and show notification if any exist.
  ///
  /// Filters expenses by:
  /// - Status: pending only
  /// - Date: tomorrow's date
  ///
  /// If expenses found, shows a single summary notification with count and total.
  Future<void> checkAndNotifyUpcomingExpenses({
    required List<ExpenseEntity> expenses,
    required String currencySymbol,
    required String notificationTitle,
    required String Function(int count, String amount) notificationBodyBuilder,
  }) async {
    if (!_isInitialized) {
      Logger.debug('NotificationService: Not initialized, skipping check');
      return;
    }

    Logger.info('NotificationService: Checking for upcoming expenses...');

    // Get tomorrow's date range (start of day to end of day)
    final now = DateTime.now();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
    final tomorrowEnd =
        DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

    // Filter pending expenses for tomorrow
    final upcomingExpenses = expenses.where((expense) {
      return expense.status == ExpenseStatus.pending &&
          expense.date
              .isAfter(tomorrowStart.subtract(const Duration(seconds: 1))) &&
          expense.date.isBefore(tomorrowEnd.add(const Duration(seconds: 1)));
    }).toList();

    if (upcomingExpenses.isEmpty) {
      Logger.info('NotificationService: No upcoming expenses for tomorrow');
      return;
    }

    // Calculate total amount
    final totalAmount = upcomingExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    final formattedAmount = '$currencySymbol ${totalAmount.toStringAsFixed(2)}';
    final body =
        notificationBodyBuilder(upcomingExpenses.length, formattedAmount);

    await _showNotification(
      id: NotificationConstants.upcomingExpenseNotificationId,
      title: notificationTitle,
      body: body,
    );

    Logger.info(
      'NotificationService: Showed notification for ${upcomingExpenses.length} expenses '
      'totaling $formattedAmount',
    );
  }

  /// Show a local notification with the given content.
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      channelDescription: NotificationConstants.channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  /// Handle notification tap (navigate to relevant screen).
  void _onNotificationTapped(NotificationResponse response) {
    Logger.info('NotificationService: Notification tapped: ${response.id}');
    // Future: Navigate to expense list or specific expense
  }

  /// Cancel all pending notifications.
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    Logger.info('NotificationService: All notifications cancelled');
  }
}
