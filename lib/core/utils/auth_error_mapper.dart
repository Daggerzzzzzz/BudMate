import 'package:budmate/core/constants.dart';

/// Utility class for mapping Firebase Authentication error codes to user-friendly messages.
///
/// Firebase Auth errors come with technical error codes like "user-not-found" or "wrong-password"
/// which are not suitable for displaying directly to end users. This mapper translates these
/// error codes into actionable, user-friendly messages that guide users to resolve the issue.
///
/// Usage:
/// ```dart
/// try {
///   await firebase.signInWithEmailAndPassword(...);
/// } on FirebaseAuthException catch (e) {
///   final userMessage = AuthErrorMapper.mapFirebaseError(e.code, e.message);
///   showError(userMessage);
/// }
/// ```
///
/// The mapper uses predefined constants from FirebaseConstants to ensure consistency
/// across the application. For unknown error codes, it falls back to the provided
/// fallback message or a generic error message.
class AuthErrorMapper {
  AuthErrorMapper._();

  /// Maps Firebase Auth error code to user-friendly message.
  ///
  /// [errorCode] Firebase error code (e.g., "user-not-found", "wrong-password")
  /// [fallbackMessage] Optional fallback message if error code is unknown
  /// [return] User-friendly error message to display
  static String mapFirebaseError(String? errorCode, String? fallbackMessage) {
    if (errorCode == null) {
      return fallbackMessage ?? FirebaseConstants.messageAuthError;
    }

    switch (errorCode) {
      case FirebaseConstants.authErrorUserNotFound:
        return FirebaseConstants.messageUserNotFound;

      case FirebaseConstants.authErrorWrongPassword:
        return FirebaseConstants.messageWrongPassword;

      case FirebaseConstants.authErrorInvalidEmail:
        return FirebaseConstants.messageInvalidEmail;

      case FirebaseConstants.authErrorEmailAlreadyInUse:
        return FirebaseConstants.messageEmailInUse;

      case FirebaseConstants.authErrorWeakPassword:
        return FirebaseConstants.messageWeakPassword;

      case FirebaseConstants.authErrorUserDisabled:
        return 'This account has been disabled. Please contact support.';

      case FirebaseConstants.authErrorTooManyRequests:
        return 'Too many failed login attempts. Please try again later.';

      case FirebaseConstants.authErrorOperationNotAllowed:
        return 'This authentication method is not allowed. Please contact support.';

      default:
        // Return fallback message or generic error
        return fallbackMessage ?? FirebaseConstants.messageAuthError;
    }
  }
}
