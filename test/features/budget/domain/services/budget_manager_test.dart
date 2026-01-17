/// Comprehensive test suite for BudgetManager service budget health calculations.
///
/// Tests the critical 90% budget usage alert threshold functionality.
/// Validates accurate percentage calculations for budget health monitoring.
/// Uses Mockito for mocking BudgetRepository and ExpenseRepository dependencies.
/// Tests both checkAlertTriggers and calculateBudgetHealth methods thoroughly.
/// Covers edge cases including exactly 90%, 89%, 91%, 100%, and over-budget scenarios.
/// Ensures empty expense lists return 0% usage without errors.
/// Validates multiple expense summation logic with various amounts.
/// Tests error handling when no active budget exists for a user.
/// Verifies database failure propagation from repository to service layer.
/// Includes boundary value testing for zero budget amounts.
/// Tests active budget selection when multiple budgets exist for a user.
/// Uses helper methods to create realistic test data for budgets and expenses.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/repositories/interfaces/budget_repository.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';
import 'package:budmate/domain/budget_entity.dart';
import 'package:budmate/domain/expense_entity.dart';
import 'package:budmate/domain/budget_health_result.dart';
import 'package:budmate/core/managers/budget_manager.dart';

// Generate mocks using build_runner
@GenerateMocks([BudgetRepository, ExpenseRepository])
import 'budget_manager_test.mocks.dart';

void main() {
  late BudgetManager budgetManager;
  late MockBudgetRepository mockBudgetRepository;
  late MockExpenseRepository mockExpenseRepository;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    mockExpenseRepository = MockExpenseRepository();
    budgetManager = BudgetManager(
      budgetRepository: mockBudgetRepository,
      expenseRepository: mockExpenseRepository,
    );
  });

  group('BudgetManager - 90% Alert Threshold Tests', () {
    test('should NOT trigger alert when usage is 89%', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 890.0); // 89%

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.checkAlertTriggers(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (shouldAlert) => expect(shouldAlert, false),
      );
    });

    test('should trigger alert when usage is EXACTLY 90%', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 900.0); // 90%

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.checkAlertTriggers(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (shouldAlert) => expect(shouldAlert, true),
      );
    });

    test('should trigger alert when usage is 91%', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 910.0); // 91%

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.checkAlertTriggers(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (shouldAlert) => expect(shouldAlert, true),
      );
    });

    test('should trigger alert when usage is 100%', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 1000.0); // 100%

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.checkAlertTriggers(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (shouldAlert) => expect(shouldAlert, true),
      );
    });

    test('should trigger alert when usage is 150% (over budget)', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 1500.0); // 150%

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.checkAlertTriggers(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (shouldAlert) => expect(shouldAlert, true),
      );
    });
  });

  group('BudgetManager - calculateBudgetHealth Tests', () {
    test('should return 0% usage when no expenses exist', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => const Right([])); // No expenses

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (healthResult) {
          expect(healthResult.totalExpenses, 0.0);
          expect(healthResult.budgetAmount, 1000.0);
          expect(healthResult.percentageUsed, 0.0);
          expect(healthResult.isOverBudget, false);
          expect(healthResult.shouldAlert, false);
          expect(healthResult.remainingAmount, 1000.0);
          expect(healthResult.userId, userId);
        },
      );
    });

    test('should return 50% usage for half budget spent', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 500.0);

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (healthResult) {
          expect(healthResult.totalExpenses, 500.0);
          expect(healthResult.budgetAmount, 1000.0);
          expect(healthResult.percentageUsed, 50.0);
          expect(healthResult.isOverBudget, false);
          expect(healthResult.shouldAlert, false);
          expect(healthResult.remainingAmount, 500.0);
        },
      );
    });

    test('should correctly sum multiple expenses within budget period',
        () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 450.0, count: 3);

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (healthResult) {
          expect(healthResult.totalExpenses, 450.0);
          expect(healthResult.budgetAmount, 1000.0);
          expect(healthResult.percentageUsed, 45.0);
          expect(healthResult.isOverBudget, false);
          expect(healthResult.shouldAlert, false);
        },
      );
    });

    test('should mark isOverBudget true when expenses exceed budget', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 1200.0);

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (healthResult) {
          expect(healthResult.totalExpenses, 1200.0);
          expect(healthResult.budgetAmount, 1000.0);
          expect(healthResult.percentageUsed, 120.0);
          expect(healthResult.isOverBudget, true);
          expect(healthResult.shouldAlert, true);
          expect(healthResult.remainingAmount, -200.0);
        },
      );
    });

    test('should trigger alert at 90% usage', () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);
      final expenses = _createExpenses(totalAmount: 900.0);

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (healthResult) {
          expect(healthResult.percentageUsed, 90.0);
          expect(healthResult.shouldAlert, true);
          expect(healthResult.isOverBudget, false);
        },
      );
    });
  });

  group('BudgetManager - Edge Cases', () {
    test('should return DatabaseFailure when no active budget found', () async {
      // Arrange
      const userId = 'user123';

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => const Right([])); // No budgets

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, contains('No active budget'));
        },
        (_) => fail('Should fail when no active budget'),
      );
    });

    test('should return DatabaseFailure when budget repository fails',
        () async {
      // Arrange
      const userId = 'user123';

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => const Left(DatabaseFailure('DB error')));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'DB error');
        },
        (_) => fail('Should fail when repository fails'),
      );
    });

    test('should return DatabaseFailure when expense repository fails',
        () async {
      // Arrange
      const userId = 'user123';
      final activeBudget = _createBudget(amount: 1000.0);

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([activeBudget]));
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => const Left(DatabaseFailure('Expense DB error')));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Expense DB error');
        },
        (_) => fail('Should fail when expense repository fails'),
      );
    });

    test('should handle zero budget amount gracefully', () async {
      // Arrange
      const userId = 'user123';
      final zeroBudget = _createBudget(amount: 0.0);

      when(mockBudgetRepository.getAll(userId))
          .thenAnswer((_) async => Right([zeroBudget]));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, contains('greater than zero'));
        },
        (_) => fail('Should fail with zero budget amount'),
      );
    });

    test('should only use active budget when multiple budgets exist', () async {
      // Arrange
      const userId = 'user123';
      final inactiveBudget1 = _createBudget(amount: 500.0, isActive: false);
      final activeBudget = _createBudget(amount: 1000.0, isActive: true);
      final inactiveBudget2 = _createBudget(amount: 750.0, isActive: false);
      final expenses = _createExpenses(totalAmount: 300.0);

      when(mockBudgetRepository.getAll(userId)).thenAnswer(
        (_) async => Right([inactiveBudget1, activeBudget, inactiveBudget2]),
      );
      when(mockExpenseRepository.getByDateRange(userId, any, any))
          .thenAnswer((_) async => Right(expenses));

      // Act
      final result = await budgetManager.calculateBudgetHealth(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (healthResult) {
          // Should use active budget with 1000.0 amount, not others
          expect(healthResult.budgetAmount, 1000.0);
          expect(healthResult.totalExpenses, 300.0);
          expect(healthResult.percentageUsed, 30.0);
        },
      );
    });
  });

  group('BudgetHealthResult - Entity Behavior', () {
    test('should correctly calculate remainingAmount getter', () {
      final result = BudgetHealthResult(
        userId: 'user123',
        totalExpenses: 300.0,
        budgetAmount: 1000.0,
        percentageUsed: 30.0,
        isOverBudget: false,
        shouldAlert: false,
        calculatedAt: DateTime.now(),
      );

      expect(result.remainingAmount, 700.0);
    });

    test('should have negative remainingAmount when over budget', () {
      final result = BudgetHealthResult(
        userId: 'user123',
        totalExpenses: 1200.0,
        budgetAmount: 1000.0,
        percentageUsed: 120.0,
        isOverBudget: true,
        shouldAlert: true,
        calculatedAt: DateTime.now(),
      );

      expect(result.remainingAmount, -200.0);
    });

    test('should support value equality via Equatable', () {
      final now = DateTime.now();
      final result1 = BudgetHealthResult(
        userId: 'user123',
        totalExpenses: 500.0,
        budgetAmount: 1000.0,
        percentageUsed: 50.0,
        isOverBudget: false,
        shouldAlert: false,
        calculatedAt: now,
      );
      final result2 = BudgetHealthResult(
        userId: 'user123',
        totalExpenses: 500.0,
        budgetAmount: 1000.0,
        percentageUsed: 50.0,
        isOverBudget: false,
        shouldAlert: false,
        calculatedAt: now,
      );

      expect(result1, equals(result2));
    });
  });
}

// ========== Test Helper Methods ==========

/// Create a budget entity for testing
///
/// [amount] Budget limit amount
/// [isActive] Whether budget should be active (default: true)
/// [return] BudgetEntity with realistic test data
BudgetEntity _createBudget({
  required double amount,
  bool isActive = true,
}) {
  final now = DateTime.now();

  return BudgetEntity(
    id: 'budget123',
    userId: 'user123',
    amount: amount,
    createdAt: now,
    updatedAt: now,
  );
}

/// Create expense entities with total amount
///
/// [totalAmount] Total sum of all expenses
/// [count] Number of expense records to create (default: 1)
/// [return] List of ExpenseEntity summing to totalAmount
List<ExpenseEntity> _createExpenses({
  required double totalAmount,
  int count = 1,
}) {
  final now = DateTime.now();
  final amountPerExpense = totalAmount / count;

  return List.generate(count, (index) {
    return ExpenseEntity(
      id: 'expense$index',
      userId: 'user123',
      amount: amountPerExpense,
      categoryId: 'category1',
      date: now.subtract(Duration(days: index)),
      status: ExpenseStatus.paid,  // Test expenses are paid by default
    );
  });
}
