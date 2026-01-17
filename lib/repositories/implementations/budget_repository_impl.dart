/// Concrete implementation of BudgetRepository using Firestore cloud storage.
///
/// Implements the BudgetRepository interface defined in the domain layer.
/// Delegates actual database operations to BudgetFirestoreDataSource.
/// Converts between domain entities and data models at the boundary.
/// Transforms ServerException from data layer into DatabaseFailure for domain layer.
/// Uses functional error handling with Either type to avoid throwing exceptions.
/// Logs all errors with context for debugging and monitoring purposes.
/// Handles both expected database errors and unexpected runtime exceptions.
/// All entity-to-model conversions happen within repository methods.
/// Returns Right for successful operations and Left for failures.
/// The repository acts as an anti-corruption layer between domain and data layers.
/// Dependency injection is used to provide the Firestore data source implementation.
/// This separation allows easy swapping of data sources without affecting business logic.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/domain/budget_entity.dart';
import 'package:budmate/repositories/interfaces/budget_repository.dart';
import 'package:budmate/data/sources/budget_firestore_datasource.dart';
import 'package:budmate/data/models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetFirestoreDataSource firestoreDataSource;

  BudgetRepositoryImpl({required this.firestoreDataSource});

  @override
  Future<Either<DatabaseFailure, BudgetEntity>> create(
    BudgetEntity budget,
  ) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final result = await firestoreDataSource.create(model);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to create budget: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in create budget', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<BudgetEntity>>> getAll(
    String userId,
  ) async {
    try {
      final result = await firestoreDataSource.getAll(userId);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get budgets: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in get budgets', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, BudgetEntity?>> getById(String id) async {
    try {
      final result = await firestoreDataSource.getById(id);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get budget: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in get budget by id', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, BudgetEntity>> update(
    BudgetEntity budget,
  ) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final result = await firestoreDataSource.update(model);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to update budget: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in update budget', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, void>> delete(String id) async {
    try {
      await firestoreDataSource.delete(id);
      return const Right(null);
    } on ServerException catch (e) {
      Logger.error('Failed to delete budget: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error('Unexpected error in delete budget', error: e, stackTrace: stackTrace);
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
