/// Concrete implementation of ExpenseRepository using Firestore cloud storage.
///
/// Implements the ExpenseRepository interface defined in the domain layer.
/// Delegates actual database operations to ExpenseFirestoreDataSource.
/// Converts between domain entities and data models at the boundary.
/// Transforms ServerException from data layer into DatabaseFailure for domain layer.
/// Uses functional error handling with Either type to avoid throwing exceptions.
/// Logs all errors with context for debugging and monitoring purposes.
/// Handles both expected database errors and unexpected runtime exceptions.
/// All entity-to-model conversions happen within repository methods.
/// Returns Right for successful operations and Left for failures.
/// The repository acts as an anti-corruption layer between domain and data layers.
/// Dependency injection is used to provide the Firestore data source implementation.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';
import 'package:budmate/data/sources/expense_firestore_datasource.dart';
import 'package:budmate/data/models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseFirestoreDataSource firestoreDataSource;

  ExpenseRepositoryImpl({required this.firestoreDataSource});

  @override
  Future<Either<DatabaseFailure, ExpenseEntity>> create(
    ExpenseEntity expense,
  ) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      final result = await firestoreDataSource.create(model);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to create expense: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in create expense', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<ExpenseEntity>>> getAll(
    String userId,
  ) async {
    try {
      final result = await firestoreDataSource.getAll(userId);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get expenses: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in get expenses', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, ExpenseEntity?>> getById(String id) async {
    try {
      final result = await firestoreDataSource.getById(id);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get expense: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in get expense by id', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<ExpenseEntity>>> getByCategory(
    String userId,
    String categoryId,
  ) async {
    try {
      final result = await firestoreDataSource.getByCategory(userId, categoryId);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get expenses by category: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in get expenses by category',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<ExpenseEntity>>> getByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await firestoreDataSource.getByDateRange(
        userId,
        startDate,
        endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get expenses by date range: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in get expenses by date range',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, ExpenseEntity>> update(
    ExpenseEntity expense,
  ) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      final result = await firestoreDataSource.update(model);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to update expense: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in update expense', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, void>> delete(String id) async {
    try {
      await firestoreDataSource.delete(id);
      return const Right(null);
    } on ServerException catch (e) {
      Logger.error('Failed to delete expense: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in delete expense', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
