import 'package:equatable/equatable.dart';

/// Budget domain entity representing a simple running total of available funds.
///
/// Pure business model containing budget data as a running balance that increases
/// when users add budget and decreases when expenses are paid. Uses Equatable
/// for value-based equality comparison.
///
/// This is a simplified budget model without periods, names, or date ranges.
/// The amount field represents the current available budget balance.
/// Timestamps createdAt and updatedAt track record lifecycle for audit purposes.
///
/// Budget behavior:
/// - Increases when user adds budget amount via Add Budget modal
/// - Decreases when user pays expenses via Pay Expenses modal
/// - No period-based logic or date range constraints
class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
        id,
        userId,
        amount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'BudgetEntity(id: $id, userId: $userId, amount: $amount)';
}
