import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/data/models/user_model.dart';

/// Local authentication data caching using SharedPreferences for fast session checks.
///
/// This datasource manages user session cache using SharedPreferences instead of SQLite
/// because user data is small and accessed frequently during app startup. It provides
/// fast synchronous access to cached user data for quick authentication state checks.
///
/// Operations:
/// - cacheUser: Store user data as JSON string in SharedPreferences
/// - getCachedUser: Retrieve cached user from SharedPreferences
/// - clearCache: Remove cached user data on sign out
///
/// All operations are wrapped in try/catch blocks and throw CacheException on failure
/// which the repository layer converts to domain failures.
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _cachedUserKey = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, jsonString);
      Logger.debug('User cached successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to cache user', error: e, stackTrace: stackTrace);
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedUserKey);

      if (jsonString == null) {
        Logger.debug('No cached user found');
        return null;
      }

      // Decode JSON first without casting
      final decoded = json.decode(jsonString);

      // Validate type before using
      if (decoded is! Map<String, dynamic>) {
        Logger.error(
          'Invalid cached user format - expected Map, got ${decoded.runtimeType}',
        );
        // Clear corrupted cache
        await clearCache();
        throw CacheException(
          'Invalid cached user format: expected Map<String, dynamic>, got ${decoded.runtimeType}',
        );
      }

      // Type promotion handles this - no cast needed
      return UserModel.fromJson(decoded);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow; // Don't wrap CacheException
      Logger.error(
        'Failed to get cached user',
        error: e,
        stackTrace: stackTrace,
      );
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedUserKey);
      Logger.debug('User cache cleared');
    } catch (e, stackTrace) {
      Logger.error('Failed to clear cache', error: e, stackTrace: stackTrace);
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}
