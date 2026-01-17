import 'package:flutter/material.dart';

/// Utility class for converting icon and color strings to Flutter objects.
///
/// Provides static methods to map icon string names (e.g., 'restaurant') to
/// Material Icons IconData (e.g., Icons.restaurant) and hex color strings
/// (e.g., 'FF9800') to Color objects.
///
/// Used throughout the app for category icons and colors, ensuring consistent
/// icon/color handling across all UI components.
class IconUtils {
  /// Converts icon string name to IconData.
  ///
  /// Maps common Material Design icon names stored in Firestore as strings
  /// to their corresponding IconData objects from Flutter's Icons class.
  ///
  /// Example:
  /// ```dart
  /// IconData icon = IconUtils.getIconFromString('restaurant');
  /// // Returns: Icons.restaurant
  /// ```
  ///
  /// Returns `Icons.category` as fallback if icon name not found in map.
  static IconData getIconFromString(String iconName) {
    final iconMap = <String, IconData>{
      // Common category icons
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,

      // Additional common icons for expense categories
      'home': Icons.home,
      'phone': Icons.phone,
      'wifi': Icons.wifi,
      'electric_bolt': Icons.electric_bolt,
      'shopping_cart': Icons.shopping_cart,
      'fitness_center': Icons.fitness_center,
      'school': Icons.school,
      'pets': Icons.pets,
      'flight': Icons.flight,
      'hotel': Icons.hotel,
      'local_gas_station': Icons.local_gas_station,
      'local_cafe': Icons.local_cafe,
      'attach_money': Icons.attach_money,
      'credit_card': Icons.credit_card,
      'fastfood': Icons.fastfood,
      'local_pharmacy': Icons.local_pharmacy,
      'theaters': Icons.theaters,
      'sports_soccer': Icons.sports_soccer,
      'book': Icons.book,
      'music_note': Icons.music_note,
      'computer': Icons.computer,
      'checkroom': Icons.checkroom,

      // Fallback icon
      'category': Icons.category,
    };

    return iconMap[iconName] ?? Icons.category; // Default fallback
  }

  /// Converts hex color string to Color object.
  ///
  /// Takes a 6-character hex color string (with or without '#' prefix)
  /// and converts it to a Flutter Color object with full opacity.
  ///
  /// Example:
  /// ```dart
  /// Color color = IconUtils.getColorFromHex('FF9800');
  /// // Returns: Color(0xFFFF9800) - Orange
  ///
  /// Color color2 = IconUtils.getColorFromHex('#2196F3');
  /// // Returns: Color(0xFF2196F3) - Blue
  /// ```
  ///
  /// The alpha channel is always set to FF (fully opaque).
  static Color getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
