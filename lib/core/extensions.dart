library;

/// DateTime extension methods for SQLite storage and date range calculations.
///
/// SQLite does not have a native DateTime type, so dates are stored as INTEGER
/// milliseconds since epoch. These extensions provide convenient conversion between
/// Dart DateTime objects and SQLite-compatible integer timestamps.
///
/// DateTimeExtensions provides:
/// - toMilliseconds: Convert DateTime to SQLite INTEGER
/// - Date boundary getters: startOfDay, endOfDay, startOfWeek, endOfWeek, etc.
/// - isToday: Quick check if date is current day
///
/// DateTimeMilliseconds extension converts integers back to DateTime objects.

extension DateTimeExtensions on DateTime {
  int toMilliseconds() => millisecondsSinceEpoch;

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  DateTime get endOfWeek {
    final daysUntilSunday = 7 - weekday;
    return add(Duration(days: daysUntilSunday)).endOfDay;
  }

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth {
    final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).endOfDay;
  }
}

extension DateTimeMilliseconds on int {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this);
}
