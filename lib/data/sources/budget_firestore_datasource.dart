/// Budget Firestore data source - handles all Firestore operations for budgets.
///
/// Implements CRUD operations for budgets stored in Firestore's 'budgets' collection.
/// All operations are user-scoped via Firebase UID. Uses Firestore's real-time database
/// with offline persistence. Throws ServerException on failures for repository error handling.
///
/// Collection structure: budgets/{budgetId}
/// - userId: Firebase UID (indexed for queries)
/// - name: Budget name
/// - amount: Budget limit
/// - period: 'daily', 'weekly', or 'monthly'
/// - startDate/endDate: Firestore Timestamps
/// - createdAt/updatedAt: Firestore Timestamps
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/data/models/budget_model.dart';

/// Abstract interface for budget Firestore operations
abstract class BudgetFirestoreDataSource {
  Future<BudgetModel> create(BudgetModel budget);
  Future<List<BudgetModel>> getAll(String userId);
  Future<BudgetModel?> getById(String id);
  Future<BudgetModel> update(BudgetModel budget);
  Future<void> delete(String id);
}

/// Firestore implementation of BudgetFirestoreDataSource
class BudgetFirestoreDataSourceImpl implements BudgetFirestoreDataSource {
  final FirebaseFirestore _firestore;

  BudgetFirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('budgets');

  @override
  Future<BudgetModel> create(BudgetModel budget) async {
    try {
      Logger.debug('BudgetFirestoreDS: Creating budget for user ${budget.userId}');

      // Use userId as document ID to enforce one budget per user
      final docId = budget.userId;

      await _collection.doc(docId).set(budget.toFirestore());

      Logger.info('BudgetFirestoreDS: Budget created/updated with ID: $docId');

      return budget.copyWith(id: docId);
    } catch (e, stackTrace) {
      Logger.error(
        'BudgetFirestoreDS: Failed to create budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to create budget: $e');
    }
  }

  @override
  Future<List<BudgetModel>> getAll(String userId) async {
    try {
      Logger.debug('BudgetFirestoreDS: Fetching budget for user: $userId');

      // Direct document fetch - faster than query
      final doc = await _collection.doc(userId).get();

      if (!doc.exists) {
        Logger.debug('BudgetFirestoreDS: No budget found for user: $userId');
        return [];
      }

      final budget = BudgetModel.fromFirestore(doc);

      Logger.info('BudgetFirestoreDS: Fetched budget: ${budget.id} with amount: ${budget.amount}');

      return [budget];  // Always return list with 0 or 1 budget
    } catch (e, stackTrace) {
      Logger.error(
        'BudgetFirestoreDS: Failed to fetch budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get budget: $e');
    }
  }

  @override
  Future<BudgetModel?> getById(String id) async {
    try {
      Logger.debug('BudgetFirestoreDS: Fetching budget by ID: $id');

      final doc = await _collection.doc(id).get();

      if (!doc.exists) {
        Logger.debug('BudgetFirestoreDS: Budget not found: $id');
        return null;
      }

      final budget = BudgetModel.fromFirestore(doc);

      Logger.debug('BudgetFirestoreDS: Budget fetched: ${budget.id} with amount: ${budget.amount}');

      return budget;
    } catch (e, stackTrace) {
      Logger.error(
        'BudgetFirestoreDS: Failed to fetch budget by ID',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get budget: $e');
    }
  }

  @override
  Future<BudgetModel> update(BudgetModel budget) async {
    try {
      Logger.debug('BudgetFirestoreDS: Updating budget: ${budget.id}');

      await _collection.doc(budget.id).update(budget.toFirestore());

      Logger.info('BudgetFirestoreDS: Budget updated: ${budget.id}');

      return budget;
    } catch (e, stackTrace) {
      Logger.error(
        'BudgetFirestoreDS: Failed to update budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to update budget: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      Logger.debug('BudgetFirestoreDS: Deleting budget: $id');

      await _collection.doc(id).delete();

      Logger.info('BudgetFirestoreDS: Budget deleted: $id');
    } catch (e, stackTrace) {
      Logger.error(
        'BudgetFirestoreDS: Failed to delete budget',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to delete budget: $e');
    }
  }
}
