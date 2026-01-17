/// Use case for retrieving all global expense categories shared across all users.
///
/// Encapsulates the business logic for fetching global category data.
/// Follows the Single Responsibility Principle by handling only category retrieval.
/// Delegates database queries to the CategoryRepository implementation.
/// Categories are globally shared - all users see the same categories.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns List of CategoryEntity containing all global categories.
/// On failure, returns DatabaseFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Empty list is returned if no categories exist rather than an error.
/// Categories are retrieved from Firestore cloud database.
/// All database errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/category_entity.dart';
import 'package:budmate/repositories/interfaces/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  /// Execute get all global categories
  ///
  /// [return] Either DatabaseFailure or List of CategoryEntity
  Future<Either<DatabaseFailure, List<CategoryEntity>>> call() async {
    return await repository.getAll();
  }
}
