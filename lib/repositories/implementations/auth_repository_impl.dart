/// Auth repository coordinating Firebase and SharedPreferences datasources.
///
/// Firestore Architecture: Simplified two-layer auth - Firebase for remote authentication,
/// SharedPreferences for session caching. Firebase UID directly maps to Firestore business
/// data (budgets, expenses, categories).
///
/// Provides signInWithEmail/Google for authentication with cache, signUpWithEmail for
/// registration, signOut for clearing all auth state, and getCurrentUser with graceful
/// degradation (Firebase → cache fallback). Converts exceptions to Either type preventing
/// domain layer pollution.
library;

import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/domain/user_entity.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';
import 'package:budmate/data/sources/auth_local_datasource.dart';
import 'package:budmate/data/sources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firestore,
  });

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );

      await localDataSource.cacheUser(user);

      return Right(user);
    } on ServerException catch (e) {
      Logger.error('Sign in failed: ${e.message}');
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      Logger.error('Cache operation failed in signInWithEmail: ${e.message}');
      return Left(AuthFailure('Failed to cache user data: ${e.message}'));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in signInWithEmail',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      await localDataSource.cacheUser(user);

      return Right(user);
    } on ServerException catch (e) {
      Logger.error('Sign up failed: ${e.message}');
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      Logger.error('Cache operation failed in signUpWithEmail: ${e.message}');
      return Left(AuthFailure('Failed to cache user data: ${e.message}'));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in signUpWithEmail',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();

      // Cache user data (with error handling)
      try {
        await localDataSource.cacheUser(user);
        Logger.debug('Google sign-in: User cached successfully');
      } catch (cacheError) {
        // Log cache error but don't fail the entire operation
        Logger.error(
          'Non-critical: Failed to cache user after Google sign-in',
          error: cacheError,
        );
      }

      return Right(user);
    } on ServerException catch (e) {
      Logger.error('Google sign in failed: ${e.message}');
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in signInWithGoogle',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();

      return const Right(null);
    } on ServerException catch (e) {
      Logger.error('Sign out failed: ${e.message}');
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      Logger.error('Cache operation failed in signOut: ${e.message}');
      return Left(AuthFailure('Failed to clear cache: ${e.message}'));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in signOut',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();

      if (user != null) {
        await localDataSource.cacheUser(user);
        return Right(user);
      }

      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser);
    } on ServerException catch (e) {
      Logger.error('Failed to get current user from remote: ${e.message}');

      try {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser);
      } on CacheException catch (cacheError) {
        Logger.error('Cache fallback also failed: ${cacheError.message}');
        return Left(AuthFailure('Failed to get user: ${e.message}'));
      }
    } on CacheException catch (e) {
      Logger.error('Cache operation failed in getCurrentUser: ${e.message}');
      return Left(AuthFailure('Failed to cache user data: ${e.message}'));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in getCurrentUser',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> sendVerificationEmail() async {
    try {
      await remoteDataSource.sendVerificationEmail();
      return const Right(null);
    } on ServerException catch (e) {
      Logger.error('Send verification email failed: ${e.message}');
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in sendVerificationEmail',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> checkEmailVerified() async {
    try {
      final isVerified = await remoteDataSource.checkEmailVerified();
      return Right(isVerified);
    } on ServerException catch (e) {
      Logger.error('Check email verified failed: ${e.message}');
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in checkEmailVerified',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> clearAllData() async {
    try {
      Logger.info('AuthRepositoryImpl: Clearing all data (Firebase + Cache + Firestore)...');

      // 1. Clear SharedPreferences cache
      await localDataSource.clearCache();
      Logger.debug('AuthRepositoryImpl: Cache cleared');

      // 2. Clear Firestore data for current user (all collections: budgets, expenses, categories)
      try {
        final user = await remoteDataSource.getCurrentUser();
        if (user != null) {
          await _deleteUserFirestoreData(user.id);
          Logger.debug('AuthRepositoryImpl: Firestore data cleared');
        }
      } on ServerException catch (e) {
        Logger.error('Failed to clear Firestore data (non-critical): ${e.message}');
      }

      // 3. Delete current Firebase Auth user (if signed in)
      try {
        await remoteDataSource.deleteCurrentFirebaseUser();
        Logger.debug('AuthRepositoryImpl: Firebase user deleted');
      } on ServerException catch (e) {
        // Log but don't fail if Firebase deletion fails
        Logger.error('Failed to delete Firebase user (non-critical): ${e.message}');
      }

      Logger.info('AuthRepositoryImpl: All data cleared successfully');
      return const Right(null);
    } on CacheException catch (e) {
      Logger.error('Clear cache failed: ${e.message}');
      return Left(AuthFailure('Failed to clear cache: ${e.message}'));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in clearAllData',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Deletes all Firestore data for a specific user.
  ///
  /// Removes all documents from categories, budgets, and expenses collections
  /// that belong to the specified user. Uses batch operations for efficiency.
  Future<void> _deleteUserFirestoreData(String userId) async {
    try {
      Logger.debug('Deleting Firestore data for user: $userId');

      final batch = firestore.batch();

      // Delete categories
      final categories = await firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in categories.docs) {
        batch.delete(doc.reference);
      }

      // Delete budgets
      final budgets = await firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in budgets.docs) {
        batch.delete(doc.reference);
      }

      // Delete expenses
      final expenses = await firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in expenses.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Logger.info('Deleted ${categories.docs.length} categories, '
          '${budgets.docs.length} budgets, '
          '${expenses.docs.length} expenses');
    } catch (e) {
      Logger.error('Failed to delete Firestore data: $e');
      throw ServerException('Failed to delete Firestore data: $e');
    }
  }
}
