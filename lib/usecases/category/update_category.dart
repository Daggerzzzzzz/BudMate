import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/category_entity.dart';
import 'package:budmate/repositories/interfaces/category_repository.dart';

/// Update category use case modifying expense category properties in the system.
///
/// This use case handles category modification by delegating to CategoryRepository. It allows
/// users to change category names, icons, or colors while preserving all associated expense
/// records and their relationships through foreign key constraints.
///
/// Operation details:
/// - Validates category exists before update attempt using category ID
/// - Allows modification of name, icon (emoji), and color fields
/// - Updates timestamp (updatedAt) to track modification history
/// - Preserves all expense relationships (expenses remain linked via category_id)
/// - Returns DatabaseFailure if category not found or update fails
///
/// Common use cases: Renaming "Food" to "Dining", changing category colors for better
/// visual organization, or updating icons to match user preferences. All linked expenses
/// automatically reflect the updated category information.
///
/// Returns `Either<DatabaseFailure, CategoryEntity>` forcing callers to handle both success
/// and failure cases explicitly, preventing silent errors in the presentation layer.
class UpdateCategory {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  /// Execute category update
  ///
  /// [category] CategoryEntity with updated data
  /// [return] Either DatabaseFailure or updated CategoryEntity
  Future<Either<DatabaseFailure, CategoryEntity>> call(
    CategoryEntity category,
  ) async {
    return await repository.update(category);
  }
}
