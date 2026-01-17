library;

import 'package:equatable/equatable.dart';

/// Data layer exception classes for external dependency errors.
///
/// Exceptions represent errors from external data sources like Firebase, SQLite,
/// and SharedPreferences. Datasources throw these exceptions when operations fail.
/// Repositories catch them and convert to domain Failures for clean separation.
///
/// Exception hierarchy:
/// - ServerException: Firebase authentication and network request failures
/// - CacheException: SharedPreferences read/write failures
/// - DatabaseException: SQLite query and transaction failures

class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});

  @override
  String toString() =>
      'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});

  @override
  String toString() =>
      'DatabaseException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Domain layer failure classes for functional error handling.
///
/// Failures represent errors at the domain and use case level, used with dartz Either
/// type for explicit error handling. Repositories convert data layer exceptions into
/// these domain failures, maintaining separation of concerns between layers.
///
/// Each failure type corresponds to a specific error domain:
/// - AuthFailure: Authentication and authorization errors
/// - DatabaseFailure: Local SQLite database errors
/// - CacheFailure: SharedPreferences caching errors
/// - ServerFailure: Network and remote server errors

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
