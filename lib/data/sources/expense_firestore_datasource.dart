/// Expense Firestore data source - handles all Firestore operations for expenses.
///
/// Implements CRUD operations for expenses stored in Firestore's 'expenses' collection.
/// All operations are user-scoped via Firebase UID. Supports specialized queries:
/// - getByCategory: Filter expenses by category
/// - getByDateRange: Filter expenses by date range
/// - deleteByCategoryId: Cascade delete for category removal
///
/// Collection structure: expenses/{expenseId}
/// - userId: Firebase UID (indexed for queries)
/// - amount: Expense amount
/// - description: Optional description
/// - categoryId: Reference to category
/// - date: Expense date (Timestamp, indexed)
/// - createdAt/updatedAt: Firestore Timestamps
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/data/models/expense_model.dart';

/// Abstract interface for expense Firestore operations
abstract class ExpenseFirestoreDataSource {
  Future<ExpenseModel> create(ExpenseModel expense);
  Future<List<ExpenseModel>> getAll(String userId);
  Future<ExpenseModel?> getById(String id);
  Future<List<ExpenseModel>> getByCategory(String userId, String categoryId);
  Future<List<ExpenseModel>> getByDateRange(String userId, DateTime startDate, DateTime endDate);
  Future<ExpenseModel> update(ExpenseModel expense);
  Future<void> delete(String id);
  Future<void> deleteByCategoryId(String categoryId);
}

/// Firestore implementation of ExpenseFirestoreDataSource
class ExpenseFirestoreDataSourceImpl implements ExpenseFirestoreDataSource {
  final FirebaseFirestore _firestore;

  ExpenseFirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('expenses');

  @override
  Future<ExpenseModel> create(ExpenseModel expense) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Creating expense for user ${expense.userId}');

      final docRef = await _collection.add(expense.toFirestore());

      Logger.info('ExpenseFirestoreDS: Expense created with ID: ${docRef.id}');

      return expense.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to create expense',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to create expense: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getAll(String userId) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Fetching expenses for user: $userId');

      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();

      Logger.info('ExpenseFirestoreDS: Fetched ${expenses.length} expenses');

      return expenses;
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to fetch expenses',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get expenses: $e');
    }
  }

  @override
  Future<ExpenseModel?> getById(String id) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Fetching expense by ID: $id');

      final doc = await _collection.doc(id).get();

      if (!doc.exists) {
        Logger.debug('ExpenseFirestoreDS: Expense not found: $id');
        return null;
      }

      final expense = ExpenseModel.fromFirestore(doc);

      Logger.debug('ExpenseFirestoreDS: Expense fetched: ${expense.amount}');

      return expense;
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to fetch expense by ID',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get expense: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getByCategory(String userId, String categoryId) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Fetching expenses for user $userId, category $categoryId');

      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('date', descending: true)
          .get();

      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();

      Logger.info('ExpenseFirestoreDS: Fetched ${expenses.length} expenses for category');

      return expenses;
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to fetch expenses by category',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get expenses by category: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getByDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Fetching expenses for date range');

      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();

      Logger.info('ExpenseFirestoreDS: Fetched ${expenses.length} expenses in date range');

      return expenses;
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to fetch expenses by date range',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get expenses by date range: $e');
    }
  }

  @override
  Future<ExpenseModel> update(ExpenseModel expense) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Updating expense: ${expense.id}');

      await _collection.doc(expense.id).update(expense.toFirestore());

      Logger.info('ExpenseFirestoreDS: Expense updated: ${expense.id}');

      return expense;
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to update expense',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to update expense: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Deleting expense: $id');

      await _collection.doc(id).delete();

      Logger.info('ExpenseFirestoreDS: Expense deleted: $id');
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to delete expense',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to delete expense: $e');
    }
  }

  @override
  Future<void> deleteByCategoryId(String categoryId) async {
    try {
      Logger.debug('ExpenseFirestoreDS: Deleting all expenses for category: $categoryId');

      final snapshot = await _collection
          .where('categoryId', isEqualTo: categoryId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Logger.info('ExpenseFirestoreDS: Deleted ${snapshot.docs.length} expenses for category $categoryId');
    } catch (e, stackTrace) {
      Logger.error(
        'ExpenseFirestoreDS: Failed to delete expenses by category',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to delete expenses by category: $e');
    }
  }
}
