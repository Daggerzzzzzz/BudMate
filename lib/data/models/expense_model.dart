/// Expense data model extending ExpenseEntity with Firestore serialization.
///
/// Simplified data layer model for Firestore persistence with bidirectional conversion.
/// DateTime converts to Timestamp, ExpenseStatus enum converts to string for storage.
/// Inherits domain logic from ExpenseEntity while adding serialization for Firestore.
///
/// Firestore document structure:
/// {
///   "userId": String,
///   "amount": number,
///   "categoryId": String,
///   "date": Timestamp,
///   "status": String ("pending", "paid", or "expired")
/// }
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/domain/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.categoryId,
    required super.date,
    required super.status,
  });

  /// Firestore serialization - converts ExpenseModel to Firestore document.
  ///
  /// Stores only essential fields, converts DateTime to Timestamp and status enum to string.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'status': status.toFirestore(),
    };
  }

  /// Firestore deserialization - converts Firestore document to ExpenseModel.
  ///
  /// Handles legacy data by defaulting missing status field to 'paid' for backward compatibility.
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'] as String,
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['categoryId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] != null
          ? ExpenseStatus.fromFirestore(data['status'] as String)
          : ExpenseStatus.paid, // Default to paid for legacy data
    );
  }

  /// Helper to create ExpenseModel from ExpenseEntity.
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      categoryId: entity.categoryId,
      date: entity.date,
      status: entity.status,
    );
  }

  /// Helper to create a copy with updated fields.
  ExpenseModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? categoryId,
    DateTime? date,
    ExpenseStatus? status,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
