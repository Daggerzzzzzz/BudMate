import 'dart:developer' as developer;

/// Centralized logging utility providing consistent error handling and debugging.
///
/// This class wraps dart:developer log functionality to ensure consistent logging
/// throughout the application. It prevents silent failures by requiring all caught
/// exceptions to be logged, making debugging and production monitoring easier.
///
/// Logging levels:
/// - debug(): Development and troubleshooting information (level 500)
/// - info(): Important application events and state changes (level 800)
/// - error(): Caught exceptions and failures (level 1000) - all exceptions must be logged
///
/// Benefits of centralized logging:
/// - Consistent format across all features
/// - Single point to add log persistence or remote monitoring
/// - Easy to control logging behavior between debug and production builds
class Logger {
  Logger._();

  static const String _name = 'BudMate';

  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 500,
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void info(String message) {
    developer.log(
      message,
      name: _name,
      level: 800,
    );
  }
}
