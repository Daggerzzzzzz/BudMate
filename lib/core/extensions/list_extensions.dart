/// Extension methods for List to add safe search operations.
///
/// Provides null-safe alternatives to standard List methods that throw exceptions
/// when elements are not found. Used throughout the app to prevent "Bad state: No element"
/// runtime errors when searching collections.
extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
