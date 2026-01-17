/// Category data model extending CategoryEntity with Firestore serialization.
///
/// Bridges domain entities and Firestore storage with bidirectional conversion methods.
/// Inherits business logic from CategoryEntity while adding persistence capabilities
/// for CategoryFirestoreDataSource.
///
/// Global Categories: Stores only 3 fields (name, icon, color) in Firestore.
/// The document ID serves as the category ID. No userId or timestamps needed
/// since categories are shared across all users.
///
/// Serialization:
/// - toFirestore(): Converts to Firestore document (3 fields)
/// - fromFirestore(): Deserializes Firestore document snapshot
/// - fromEntity(): Converts from domain CategoryEntity
/// - copyWith(): Creates modified copy
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budmate/domain/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
  });

  /// Firestore serialization - converts CategoryModel to Firestore document.
  ///
  /// Stores only 3 fields: name, icon, color.
  /// The document ID is the category ID (not stored in fields).
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  /// Firestore deserialization - converts Firestore document to CategoryModel.
  ///
  /// Reads 3 fields from Firestore and uses document ID as category ID.
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,  // Document ID becomes category ID
      name: data['name'] as String,
      icon: data['icon'] as String,
      color: data['color'] as String,
    );
  }

  /// Helper to create CategoryModel from CategoryEntity.
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
    );
  }

  /// Helper to create a copy with updated fields.
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
