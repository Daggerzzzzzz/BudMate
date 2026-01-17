import 'package:dartz/dartz.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/domain/user_entity.dart';
import 'package:budmate/repositories/interfaces/auth_repository.dart';

/// Use case for email/password sign in
///
/// Architectural Decision: Each use case is a separate class for single
/// responsibility and easy testing (
///
/// Why separate use case classes:
/// - Easy to test in isolation without UI
/// - Single responsibility - one use case does one thing
/// - Can add business logic/validation here if needed
class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  /// Execute sign in with email
  ///
  /// [email] User's email address
  /// [password] User's password
  /// [return] Either AuthFailure on left, UserEntity on right
  Future<Either<AuthFailure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
