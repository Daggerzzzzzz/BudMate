import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/core/errors.dart';
import 'package:budmate/core/logger.dart';
import 'package:budmate/core/utils/auth_error_mapper.dart';
import 'package:budmate/data/models/user_model.dart';

/// Remote authentication datasource using Firebase Auth and Google Sign-In.
///
/// This datasource handles all Firebase authentication operations including email/password,
/// Google OAuth, and session management. It throws exceptions (not failures) which the
/// repository layer catches and converts to domain failures maintaining clean architecture.
///
/// Authentication methods:
/// - signInWithEmail: Authenticate with email and password credentials
/// - signUpWithEmail: Create new Firebase account with email/password
/// - signInWithGoogle: Google OAuth flow creating Firebase credential
/// - signOut: Sign out from both Firebase and Google to ensure complete logout
/// - getCurrentUser: Get current Firebase authentication state
/// - sendVerificationEmail: Send email verification link to current user
/// - checkEmailVerified: Check if current user's email is verified
/// - deleteCurrentFirebaseUser: Delete current Firebase Auth user (debug only)
///
/// All operations throw ServerException on failure with user-friendly error messages.
/// The repository layer is responsible for catching these exceptions and converting
/// them to Either type for functional error handling in the domain layer.
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> sendVerificationEmail();

  Future<bool> checkEmailVerified();

  Future<void> deleteCurrentFirebaseUser();

  Future<void> saveUser(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const ServerException('Sign in failed: No user returned');
      }

      return UserModel.fromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase sign in failed', error: e, stackTrace: stackTrace);

      // Map Firebase error code to user-friendly message
      final userFriendlyMessage = AuthErrorMapper.mapFirebaseError(e.code, e.message);

      throw ServerException(
        userFriendlyMessage,
        code: e.code,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error during sign in',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const ServerException('Sign up failed: No user returned');
      }

      if (displayName != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      final currentUser = firebaseAuth.currentUser ?? credential.user!;
      return UserModel.fromFirebase(currentUser);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase sign up failed', error: e, stackTrace: stackTrace);
      throw ServerException(
        e.message ?? 'Sign up failed',
        code: e.code,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error during sign up',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Step 1: Initiate Google Sign-In and get Google user
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const ServerException('Google sign in cancelled by user');
      }

      // Step 2: Get Google authentication tokens
      final googleAuth = await googleUser.authentication;

      // Step 3: Create Firebase credential from Google tokens
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with Google credential
      final userCredential = await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const ServerException('Google sign in failed: No user returned');
      }

      // Step 5: Extract user data from Firebase (not Google Sign-In)
      // This avoids potential Pigeon type casting issues in google_sign_in plugin
      final firebaseUser = userCredential.user!;

      Logger.debug(
        'Google sign-in successful - UID: ${firebaseUser.uid}, '
        'Email: ${firebaseUser.email}, '
        'DisplayName: ${firebaseUser.displayName}',
      );

      return UserModel.fromFirebase(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      Logger.error(
        'Firebase authentication failed during Google sign-in',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(
        e.message ?? 'Google sign in failed',
        code: e.code,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error during Google sign in',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e, stackTrace) {
      Logger.error('Sign out failed', error: e, stackTrace: stackTrace);
      throw ServerException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return UserModel.fromFirebase(firebaseUser);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get current user',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException('No user signed in');
      }

      if (user.emailVerified) {
        Logger.info('User email already verified');
        return;
      }

      await user.sendEmailVerification();
      Logger.info('Verification email sent to: ${user.email}');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase send verification failed', error: e, stackTrace: stackTrace);
      throw ServerException(
        e.message ?? 'Failed to send verification email',
        code: e.code,
      );
    } catch (e, stackTrace) {
      Logger.error('Unexpected error sending verification email', error: e, stackTrace: stackTrace);
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException('No user signed in');
      }

      // Reload user to get fresh verification status
      await user.reload();
      final refreshedUser = firebaseAuth.currentUser;

      final isVerified = refreshedUser?.emailVerified ?? false;
      Logger.debug('Email verification status: $isVerified');
      return isVerified;
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase check verified failed', error: e, stackTrace: stackTrace);
      throw ServerException(
        e.message ?? 'Failed to check verification status',
        code: e.code,
      );
    } catch (e, stackTrace) {
      Logger.error('Unexpected error checking verification', error: e, stackTrace: stackTrace);
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCurrentFirebaseUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        Logger.info('No Firebase user to delete');
        return;
      }

      Logger.info('Deleting Firebase Auth user: ${user.email}');
      await user.delete();
      Logger.info('Firebase Auth user deleted successfully');

      // Sign out to clear any remaining session data
      await signOut();
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase delete user failed', error: e, stackTrace: stackTrace);
      throw ServerException(
        e.message ?? 'Failed to delete Firebase user',
        code: e.code,
      );
    } catch (e, stackTrace) {
      Logger.error('Unexpected error deleting user', error: e, stackTrace: stackTrace);
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).set(user.toJson());
      Logger.info('AuthRemoteDatasource: User saved successfully');
    } catch (e, stackTrace) {
      Logger.error('AuthRemoteDatasource: Failed to save user', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to save user: ${e.toString()}');
    }
  }
}
