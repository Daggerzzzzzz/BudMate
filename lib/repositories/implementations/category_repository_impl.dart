/// Concrete implementation of CategoryRepository using Firestore cloud storage.
///
/// Implements the CategoryRepository interface defined in the domain layer.
/// Delegates actual database operations to CategoryFirestoreDataSource.
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
import 'package:budmate/domain/category_entity.dart';
import 'package:budmate/repositories/interfaces/category_repository.dart';
import 'package:budmate/data/sources/category_firestore_datasource.dart';
import 'package:budmate/data/sources/expense_firestore_datasource.dart';
import 'package:budmate/data/models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryFirestoreDataSource firestoreDataSource;
  final ExpenseFirestoreDataSource expenseDataSource;

  CategoryRepositoryImpl({
    required this.firestoreDataSource,
    required this.expenseDataSource,
  });

  @override
  Future<Either<DatabaseFailure, CategoryEntity>> create(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await firestoreDataSource.create(model);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to create category: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in create category',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, List<CategoryEntity>>> getAll() async {
    try {
      final result = await firestoreDataSource.getAll();
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get categories: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in get categories',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, CategoryEntity?>> getById(String id) async {
    try {
      final result = await firestoreDataSource.getById(id);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to get category: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in get category by id',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, CategoryEntity>> update(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await firestoreDataSource.update(model);
      return Right(result);
    } on ServerException catch (e) {
      Logger.error('Failed to update category: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in update category',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<DatabaseFailure, void>> delete(String id) async {
    try {
      Logger.debug('CategoryRepository: Deleting category $id with cascade');

      // 1. Delete all expenses associated with this category (cascade delete)
      await expenseDataSource.deleteByCategoryId(id);
      Logger.debug('CategoryRepository: Deleted expenses for category $id');

      // 2. Delete the category itself
      await firestoreDataSource.delete(id);
      Logger.info('CategoryRepository: Category $id deleted successfully with cascade');

      return const Right(null);
    } on ServerException catch (e) {
      Logger.error('Failed to delete category: ${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in delete category',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
