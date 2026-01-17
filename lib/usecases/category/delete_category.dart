import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/category_repository.dart';

/// Delete category use case removing expense categories from the system.
///
/// This use case handles category deletion by delegating to CategoryRepository. Due to
/// foreign key constraints with CASCADE DELETE, removing a category will automatically
/// delete all associated expenses, ensuring referential integrity in the database.
///
/// Operation details:
/// - Validates category exists before deletion attempt using category ID
/// - Triggers CASCADE DELETE removing all expenses linked to this category
/// - Permanently removes category record from SQLite database
/// - Ensures database consistency by preventing orphaned expense records
/// - Returns DatabaseFailure if category not found or deletion fails
///
/// WARNING: This operation is HIGHLY destructive and cannot be undone. All expenses assigned
/// to the deleted category will be permanently removed from the database. For example, deleting
/// "Food" category will erase all food expense history with no recovery option.
///
/// Returns Either DatabaseFailure or void forcing callers to handle both success
/// and failure cases explicitly, preventing silent errors in the presentation layer.
class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  /// Execute category deletion
  ///
  /// [id] Category ID to delete
  /// [return] Either DatabaseFailure or void
  Future<Either<DatabaseFailure, void>> call(String id) async {
    return await repository.delete(id);
  }
}
