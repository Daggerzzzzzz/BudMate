import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user in the BudMate application.
///
/// Pure domain model with no external dependencies, representing user identity.
/// Supports various authentication methods (Google OAuth, email/password) where some fields
/// may be optional. Uses Equatable for value-based equality comparison enabling efficient
/// state management and comparison in Provider/BLoC patterns.
///
/// Key responsibilities:
/// - Store user identification (id, email, displayName, photoUrl)
/// - Provide value equality for efficient state comparison
/// - Maintain immutability for predictable state management
class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];

  @override
  String toString() => 'UserEntity(id: $id, email: $email, displayName: $displayName)';
}
