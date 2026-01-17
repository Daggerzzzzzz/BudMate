import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:budmate/data/sources/auth_local_datasource.dart';
import 'package:budmate/data/sources/auth_remote_datasource.dart';
import 'package:budmate/data/sources/budget_firestore_datasource.dart';
import 'package:budmate/data/sources/category_firestore_datasource.dart';
import 'package:budmate/data/sources/expense_firestore_datasource.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';
import 'package:budmate/repositories/interfaces/budget_repository.dart';
import 'package:budmate/repositories/interfaces/category_repository.dart';
import 'package:budmate/repositories/interfaces/expense_repository.dart';
import 'package:budmate/repositories/implementations/auth_repository_impl.dart';
import 'package:budmate/repositories/implementations/budget_repository_impl.dart';
import 'package:budmate/repositories/implementations/category_repository_impl.dart';
import 'package:budmate/repositories/implementations/expense_repository_impl.dart';

export 'package:budmate/repositories/interfaces/auth_repository.dart';
export 'package:budmate/repositories/interfaces/budget_repository.dart';
export 'package:budmate/repositories/interfaces/category_repository.dart';
export 'package:budmate/repositories/interfaces/expense_repository.dart';

/// Factory for creating repository instances with proper dependency wiring.
///
/// Centralizes repository creation logic to reduce main.dart boilerplate and maintain
/// clean architecture separation. Each factory method instantiates necessary datasources
/// (Firebase Auth, Firestore, SharedPreferences) and wires them to repository implementations.
/// Acts as barrel export for repository interfaces to simplify imports across the app.
///
/// Repository factories:
/// - createAuthRepository: Firebase Auth + SharedPreferences session cache
/// - createBudgetRepository: Cloud Firestore budget collection
/// - createCategoryRepository: Cloud Firestore categories + cascade delete wiring
/// - createExpenseRepository: Cloud Firestore expenses collection
///
/// Exports: All repository interfaces for simplified infrastructure imports
class RepositoryManager {
  final FirebaseFirestore _firestore;

  RepositoryManager(this._firestore);

  AuthRepository createAuthRepository(SharedPreferences sharedPreferences) {
    final remoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: firebase_auth.FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
      firestore: _firestore,
    );

    final localDataSource = AuthLocalDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );

    return AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      firestore: _firestore,
    );
  }

  BudgetRepository createBudgetRepository() {
    final firestoreDataSource = BudgetFirestoreDataSourceImpl(
      firestore: _firestore,
    );

    return BudgetRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
    );
  }

  CategoryRepository createCategoryRepository() {
    final firestoreDataSource = CategoryFirestoreDataSourceImpl(
      firestore: _firestore,
    );

    final expenseDataSource = ExpenseFirestoreDataSourceImpl(
      firestore: _firestore,
    );

    return CategoryRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
      expenseDataSource: expenseDataSource,
    );
  }

  ExpenseRepository createExpenseRepository() {
    final firestoreDataSource = ExpenseFirestoreDataSourceImpl(
      firestore: _firestore,
    );

    return ExpenseRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
    );
  }
}
