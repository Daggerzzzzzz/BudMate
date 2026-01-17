/// Expense entity representing a spending transaction in the domain layer.
///
/// Simplified immutable domain model for tracking expenses with clear lifecycle status.
/// Uses Equatable for value-based equality comparisons in tests and state management.
///
/// Core fields:
/// - id: Unique identifier for Firestore document
/// - userId: Owner of the expense (per-user data isolation)
/// - amount: Positive value representing money to be spent
/// - categoryId: Reference to global category (food, transportation, etc.)
/// - date: Due date when the expense should be paid
/// - status: Current lifecycle state (Pending → Paid/Expired)
///
/// Status flow:
/// - Pending: Scheduled expense not yet paid (shows in Upcoming Expenses)
/// - Paid: User marked as paid, budget deducted (shows in History)
/// - Expired: Due date passed without payment (shows in History with warning)
///
/// This entity is framework-independent and serves as the contract between
/// domain logic and outer layers (data, presentation).
library;

import 'package:equatable/equatable.dart';

/// Expense lifecycle status enum.
///
/// - Pending: Expense scheduled but not yet paid (upcoming)
/// - Paid: Expense successfully paid, budget deducted
/// - Expired: Expense past due date without payment (overdue)
enum ExpenseStatus {
  pending,
  paid,
  expired;

  /// Convert enum to string for Firestore storage.
  String toFirestore() => name;

  /// Parse string from Firestore to enum.
  static ExpenseStatus fromFirestore(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ExpenseStatus.pending;
      case 'paid':
        return ExpenseStatus.paid;
      case 'expired':
        return ExpenseStatus.expired;
      default:
        throw ArgumentError('Invalid expense status: $value');
    }
  }
}

class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String categoryId;
  final DateTime date;
  final ExpenseStatus status;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        categoryId,
        date,
        status,
      ];

  @override
  String toString() =>
      'ExpenseEntity(id: $id, amount: $amount, category: $categoryId, date: $date, status: $status)';
}
