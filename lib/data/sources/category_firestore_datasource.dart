/// Category Firestore data source - handles all Firestore operations for global categories.
///
/// Implements CRUD operations for categories stored in Firestore's 'categories' collection.
/// Categories are GLOBAL and shared across all users. Uses Firestore's real-time database
/// with offline persistence. Throws ServerException on failures for repository error handling.
///
/// Global Category Architecture:
/// - Categories created ONCE at app initialization
/// - All users reference the same category documents
/// - No userId field - categories are application-wide constants
/// - Fixed document IDs based on category names (e.g., "food", "transportation")
///
/// Collection structure: categories/{categoryId}
/// - name: Category name (e.g., "Food")
/// - icon: Icon identifier (e.g., "restaurant")
/// - color: Hex color code (e.g., "FF9800")
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/data/models/category_model.dart';

/// Abstract interface for category Firestore operations
abstract class CategoryFirestoreDataSource {
  Future<CategoryModel> create(CategoryModel category);
  Future<List<CategoryModel>> getAll();  // No userId parameter - global categories
  Future<CategoryModel?> getById(String id);
  Future<CategoryModel> update(CategoryModel category);
  Future<void> delete(String id);
}

/// Firestore implementation of CategoryFirestoreDataSource
class CategoryFirestoreDataSourceImpl implements CategoryFirestoreDataSource {
  final FirebaseFirestore _firestore;

  CategoryFirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('categories');

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    try {
      Logger.debug('CategoryFirestoreDS: Creating global category: ${category.name}');

      // Use category ID as document ID for predictable global IDs
      // This ensures categories like "food", "transportation" have fixed IDs
      final docId = category.id;

      await _collection.doc(docId).set(category.toFirestore());

      Logger.info('CategoryFirestoreDS: Global category created with ID: $docId');

      return category.copyWith(id: docId);
    } catch (e, stackTrace) {
      Logger.error(
        'CategoryFirestoreDS: Failed to create category',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to create category: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getAll() async {
    try {
      Logger.debug('CategoryFirestoreDS: Fetching all global categories');

      // No userId filter - get ALL global categories
      final snapshot = await _collection.orderBy('name').get();

      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      Logger.info('CategoryFirestoreDS: Fetched ${categories.length} global categories');

      return categories;
    } catch (e, stackTrace) {
      Logger.error(
        'CategoryFirestoreDS: Failed to fetch categories',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get categories: $e');
    }
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    try {
      Logger.debug('CategoryFirestoreDS: Fetching category by ID: $id');

      final doc = await _collection.doc(id).get();

      if (!doc.exists) {
        Logger.debug('CategoryFirestoreDS: Category not found: $id');
        return null;
      }

      final category = CategoryModel.fromFirestore(doc);

      Logger.debug('CategoryFirestoreDS: Category fetched: ${category.name}');

      return category;
    } catch (e, stackTrace) {
      Logger.error(
        'CategoryFirestoreDS: Failed to fetch category by ID',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get category: $e');
    }
  }

  @override
  Future<CategoryModel> update(CategoryModel category) async {
    try {
      Logger.debug('CategoryFirestoreDS: Updating category: ${category.id}');

      await _collection.doc(category.id).update(category.toFirestore());

      Logger.info('CategoryFirestoreDS: Category updated: ${category.id}');

      return category;
    } catch (e, stackTrace) {
      Logger.error(
        'CategoryFirestoreDS: Failed to update category',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to update category: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      Logger.debug('CategoryFirestoreDS: Deleting category: $id');

      await _collection.doc(id).delete();

      Logger.info('CategoryFirestoreDS: Category deleted: $id');
    } catch (e, stackTrace) {
      Logger.error(
        'CategoryFirestoreDS: Failed to delete category',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to delete category: $e');
    }
  }
}
