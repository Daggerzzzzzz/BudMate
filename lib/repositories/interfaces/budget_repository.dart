/// Abstract repository contract defining budget operations interface.
///
/// Defines the contract for budget data operations following the Repository pattern.
/// This interface belongs to the domain layer and is implemented by the data layer.
/// Follows the Dependency Inversion Principle by depending on abstractions not concretions.
/// All methods return Either type from dartz package for functional error handling.
/// Left side contains DatabaseFailure for error cases, Right side contains success values.
/// The repository abstracts away data source details from business logic.
/// Implementations may use local database, remote API, or any other data source.
/// This design allows easy testing by mocking the repository interface.
/// Use cases depend on this abstraction rather than concrete implementations.
/// The contract enforces consistent error handling across all budget operations.
/// All operations are asynchronous to support both local and remote data sources.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/budget_entity.dart';

abstract class BudgetRepository {
  Future<Either<DatabaseFailure, BudgetEntity>> create(BudgetEntity budget);

  Future<Either<DatabaseFailure, List<BudgetEntity>>> getAll(String userId);

  Future<Either<DatabaseFailure, BudgetEntity?>> getById(String id);

  Future<Either<DatabaseFailure, BudgetEntity>> update(BudgetEntity budget);

  Future<Either<DatabaseFailure, void>> delete(String id);
}
