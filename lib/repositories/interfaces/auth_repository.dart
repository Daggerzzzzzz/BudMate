import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/user_entity.dart';

/// Authentication repository contract defining all auth operations.
///
/// This abstract repository interface defines the contract between domain and data layers
/// following dependency inversion principle. Domain logic depends on this abstraction,
/// not on concrete Firebase or cache implementations.
///
/// All methods return Either type to force explicit error handling. Callers must handle
/// both failure (AuthFailure) and success cases, preventing silent failures.
///
/// Available operations:
/// - signInWithEmail: Email/password authentication
/// - signUpWithEmail: New user account creation
/// - signInWithGoogle: Google OAuth authentication flow
/// - signOut: Sign out and clear all cached data
/// - getCurrentUser: Retrieve current user with offline cache fallback
/// - sendVerificationEmail: Send email verification link to current user
/// - checkEmailVerified: Check if current user's email is verified
/// - clearAllData: Clear all data from cache and database (for debugging)
abstract class AuthRepository {
  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<AuthFailure, UserEntity>> signInWithGoogle();

  Future<Either<AuthFailure, void>> signOut();

  Future<Either<AuthFailure, UserEntity?>> getCurrentUser();

  Future<Either<AuthFailure, void>> sendVerificationEmail();

  Future<Either<AuthFailure, bool>> checkEmailVerified();

  Future<Either<AuthFailure, void>> clearAllData();
}
