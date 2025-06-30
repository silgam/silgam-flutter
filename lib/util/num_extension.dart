extension NumExtension on num {
  /// Returns a compact string representation of this number.
  ///
  /// For whole numbers (integers), returns the string without decimal places.
  /// For fractional numbers, returns the string with decimal places preserved.
  ///
  /// Examples:
  /// ```dart
  /// 5.toCompactString()     // returns "5"
  /// 5.0.toCompactString()   // returns "5"
  /// 5.50.toCompactString()  // returns "5.5"
  /// 3.14.toCompactString()  // returns "3.14"
  /// ```
  String toCompactString() {
    if (this % 1 == 0) {
      return toInt().toString();
    }
    return toString();
  }
}
