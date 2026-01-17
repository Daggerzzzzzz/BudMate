import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/domain/category_entity.dart';
import 'package:budmate/core/managers/usecase_manager.dart';

/// Category state management service for expense classification and organization.
///
/// This presentation service wraps category domain use cases to provide reactive
/// category state for UI consumption. It maintains global category lists via ChangeNotifier
/// allowing expense screens to display consistent category selections across the app.
///
/// State management:
/// - categories: List of all global categories shared across all users (sorted by name)
/// - isLoading: Loading indicator for async category operations
/// - lastError: Most recent error message for UI error display
///
/// Category operations:
/// - loadCategories: Fetch all global categories for dropdown/selection UI
/// - createCategory: Create new category with icon and color customization
/// - updateCategory: Modify existing category metadata
/// - deleteCategory: Remove category (validates no expenses attached via FK)
///
/// All methods return Either type forcing explicit error handling at UI level.
/// Categories are cached in memory after first load for fast access during expense entry.
/// This service ensures category consistency across all expense-related screens.
class CategoryService extends ChangeNotifier {
  final CategoryUseCases _categoryUseCases;

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _lastError;

  CategoryService({
    required CategoryUseCases categoryUseCases,
  })  : _categoryUseCases = categoryUseCases;

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> loadCategories() async {
    Logger.info('CategoryService: Loading global categories');
    _setLoading(true);
    _clearError();

    final result = await _categoryUseCases.get.call();

    result.fold(
      (failure) {
        Logger.error('CategoryService: Failed to load categories: ${failure.message}');
        _setError(failure.message);
        _categories = [];
        _setLoading(false);
      },
      (categories) {
        Logger.info('CategoryService: Loaded ${categories.length} global categories');
        _categories = categories;
        _setLoading(false);
      },
    );
  }

  Future<Either<DatabaseFailure, CategoryEntity>> createCategory(
    CategoryEntity category,
  ) async {
    Logger.info('CategoryService: Creating category: ${category.name}');
    _setLoading(true);
    _clearError();

    final result = await _categoryUseCases.create.call(category);

    result.fold(
      (failure) {
        Logger.error('CategoryService: Failed to create category: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (createdCategory) {
        Logger.info('CategoryService: Category created successfully: ${createdCategory.id}');
        _categories = [..._categories, createdCategory];
        _setLoading(false);
      },
    );

    return result;
  }

  Future<Either<DatabaseFailure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) async {
    Logger.info('CategoryService: Updating category: ${category.id}');
    _setLoading(true);
    _clearError();

    final result = await _categoryUseCases.update.call(category);

    result.fold(
      (failure) {
        Logger.error('CategoryService: Failed to update category: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (updatedCategory) {
        Logger.info('CategoryService: Category updated successfully: ${updatedCategory.id}');
        _categories = _categories
            .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
            .toList();
        _setLoading(false);
      },
    );

    return result;
  }

  Future<Either<DatabaseFailure, void>> deleteCategory(String id) async {
    Logger.info('CategoryService: Deleting category: $id');
    _setLoading(true);
    _clearError();

    final result = await _categoryUseCases.delete.call(id);

    result.fold(
      (failure) {
        Logger.error('CategoryService: Failed to delete category: ${failure.message}');
        _setError(failure.message);
        _setLoading(false);
      },
      (_) {
        Logger.info('CategoryService: Category deleted successfully: $id');
        _categories = _categories.where((c) => c.id != id).toList();
        _setLoading(false);
      },
    );

    return result;
  }

  /// Initialize global default categories at app startup.
  ///
  /// Creates a starter set of common expense categories shared across all users
  /// if no categories exist in Firestore. This provides an immediate usable experience
  /// for all users without requiring manual category setup.
  ///
  /// Default categories include:
  /// - Food (restaurant icon, orange color)
  /// - Transportation (directions_car icon, blue color)
  /// - Shopping (shopping_bag icon, purple color)
  /// - Entertainment (movie icon, pink color)
  /// - Bills (receipt icon, red color)
  /// - Health (local_hospital icon, green color)
  ///
  /// Uses fixed document IDs for predictable references.
  /// Returns true if default categories were created, false if categories already exist.
  /// Initialize global default categories at app startup.
  ///
  /// Returns true if categories were created/exist, throws exception if initialization fails critically.
  Future<bool> initializeDefaultCategories() async {
    Logger.info('CategoryService: Checking if global default categories needed');

    // Try to check existing categories
    final existingResult = await _categoryUseCases.get.call();

    // If check succeeds and categories exist, we're done
    final categoriesExist = existingResult.fold(
      (failure) {
        Logger.info('CategoryService: Could not check existing categories (${failure.message}), will attempt creation anyway');
        return false;  // Changed: Assume empty and try to create
      },
      (categories) {
        if (categories.isNotEmpty) {
          Logger.info('CategoryService: Global categories already exist (${categories.length} found), skipping initialization');
          return true;
        }
        return false;
      },
    );

    if (categoriesExist) {
      await loadCategories();  // Ensure they're loaded into memory
      return true;
    }

    Logger.info('CategoryService: Initializing global default categories');

    final defaultCategories = [
      const CategoryEntity(
        id: 'food',
        name: 'Food',
        icon: 'restaurant',
        color: 'FF9800', // Orange
      ),
      const CategoryEntity(
        id: 'transportation',
        name: 'Transportation',
        icon: 'directions_car',
        color: '2196F3', // Blue
      ),
      const CategoryEntity(
        id: 'shopping',
        name: 'Shopping',
        icon: 'shopping_bag',
        color: '9C27B0', // Purple
      ),
      const CategoryEntity(
        id: 'entertainment',
        name: 'Entertainment',
        icon: 'movie',
        color: 'E91E63', // Pink
      ),
      const CategoryEntity(
        id: 'bills',
        name: 'Bills',
        icon: 'receipt',
        color: 'F44336', // Red
      ),
      const CategoryEntity(
        id: 'health',
        name: 'Health',
        icon: 'local_hospital',
        color: '4CAF50', // Green
      ),
    ];

    // Create all default categories
    int successCount = 0;
    final List<String> failures = [];

    for (final category in defaultCategories) {
      final result = await _categoryUseCases.create.call(category);
      result.fold(
        (failure) {
          Logger.error('CategoryService: Failed to create category ${category.name}: ${failure.message}');
          failures.add('${category.name}: ${failure.message}');
        },
        (created) {
          successCount++;
          Logger.debug('CategoryService: Created global category: ${category.name}');
        },
      );
    }

    Logger.info('CategoryService: Created $successCount/${defaultCategories.length} categories');

    // If NO categories were created, something is seriously wrong
    if (successCount == 0 && failures.isNotEmpty) {
      final errorMsg = 'Failed to create any categories: ${failures.join(", ")}';
      Logger.error('CategoryService: $errorMsg');
      throw Exception(errorMsg);  // Changed: Throw exception for critical failure
    }

    // Reload categories to update UI
    if (successCount > 0) {
      await loadCategories();
    }

    return successCount > 0;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
  }
}
