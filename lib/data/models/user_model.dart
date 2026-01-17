/// User data model extending UserEntity with Firebase and cache serialization.
///
/// v3 Architecture: Simplified user model with two conversion capabilities:
/// - fromFirebase: Converts Firebase Auth objects to domain models
/// - toJson/fromJson: Enables SharedPreferences caching for offline access
///
/// NO SQLite toMap/fromMap methods - v3 has no users table in SQLite.
/// Firebase UID directly maps to business data (budgets, expenses, categories).
/// Domain layer remains pure while data layer handles serialization concerns.
library;

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:budmate/domain/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
  });

  factory UserModel.fromFirebase(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

