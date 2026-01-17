/// Budget data model extending BudgetEntity with Firestore serialization.
///
/// Bridges domain entities and Firestore storage with bidirectional conversion methods.
/// DateTime values convert to Firestore Timestamp. The toFirestore method serializes for
/// Firestore writes, while fromFirestore deserializes document snapshots. Inherits business
/// logic from BudgetEntity while adding persistence for BudgetFirestoreDataSource.
///
/// Simplified to only store amount as a running total, without name, period, or date ranges.
/// Migration strategy: Old Firestore documents with legacy fields are handled gracefully.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/domain/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Firestore serialization - converts BudgetModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Firestore deserialization - converts Firestore document to BudgetModel
  ///
  /// Migration strategy: Gracefully handles old documents with legacy fields
  /// (name, period, startDate, endDate) by ignoring them.
  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] as String,
      amount: (data['amount'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Helper to create BudgetModel from BudgetEntity
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Helper to create a copy with updated fields
  BudgetModel copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
