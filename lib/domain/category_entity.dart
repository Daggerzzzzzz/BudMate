import 'package:equatable/equatable.dart';

/// Global category entity for organizing and classifying expenses.
///
/// Pure business model representing expense categories shared across all users.
/// Categories like Food, Transport, or Entertainment are global constants that
/// all users reference. Each category includes visual identifiers (icon and color)
/// for UI display making expense tracking more intuitive and visually organized.
///
/// Global Shared Data: Categories are created once at app initialization and
/// shared by all users. This eliminates per-user duplication and ensures consistency.
///
/// Fields (4 total):
/// - id: Unique identifier (e.g., "food", "transportation")
/// - name: Display name (e.g., "Food", "Transportation")
/// - icon: Material icon identifier (e.g., "restaurant", "directions_car")
/// - color: Hex color code (e.g., "FF9800" for orange)
///
/// Uses Equatable for value-based equality comparison.
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object> get props => [id, name, icon, color];

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name, icon: $icon, color: $color)';
}
