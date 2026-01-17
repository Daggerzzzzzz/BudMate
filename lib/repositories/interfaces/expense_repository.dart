/// Abstract repository contract defining expense operations interface.
///
/// Defines the contract for expense data operations following the Repository pattern.
/// This interface belongs to the domain layer and is implemented by the data layer.
/// Follows the Dependency Inversion Principle by depending on abstractions not concretions.
/// All methods return Either type from dartz package for functional error handling.
/// Left side contains DatabaseFailure for error cases, Right side contains success values.
/// The repository abstracts away data source details from business logic.
/// Implementations may use local database, remote API, or any other data source.
/// This design allows easy testing by mocking the repository interface.
/// Use cases depend on this abstraction rather than concrete implementations.
/// The contract enforces consistent error handling across all expense operations.
/// Includes specialized queries for filtering by category and date range.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/expense_entity.dart';

abstract class ExpenseRepository {
  Future<Either<DatabaseFailure, ExpenseEntity>> create(ExpenseEntity expense);

  Future<Either<DatabaseFailure, List<ExpenseEntity>>> getAll(String userId);

  Future<Either<DatabaseFailure, ExpenseEntity?>> getById(String id);

  Future<Either<DatabaseFailure, List<ExpenseEntity>>> getByCategory(
    String userId,
    String categoryId,
  );

  Future<Either<DatabaseFailure, List<ExpenseEntity>>> getByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  Future<Either<DatabaseFailure, ExpenseEntity>> update(ExpenseEntity expense);

  Future<Either<DatabaseFailure, void>> delete(String id);
}
