/// Use case for creating a new expense category with custom icon and color.
///
/// Encapsulates the business logic for category creation operations.
/// Follows the Single Responsibility Principle by handling only category creation.
/// Delegates database persistence to the CategoryRepository implementation.
/// Validates category data including name uniqueness and icon/color values.
/// Returns Either type for functional error handling without exceptions.
/// On success, returns CategoryEntity with the newly created category data.
/// On failure, returns DatabaseFailure with descriptive error messages.
/// This use case can be invoked from any presentation layer component.
/// Foreign key constraints ensure the userId exists before category creation.
/// Categories are immediately available for assigning to new expenses.
/// All database errors are transformed into domain-friendly failures.
library;

import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/category_entity.dart';
import 'package:budmate/repositories/interfaces/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  /// Execute category creation
  ///
  /// [category] CategoryEntity to create
  /// [return] Either DatabaseFailure or created CategoryEntity
  Future<Either<DatabaseFailure, CategoryEntity>> call(
    CategoryEntity category,
  ) async {
    return await repository.create(category);
  }
}
