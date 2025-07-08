import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] for filtering items based on whether a [Comparable] field's
/// value falls within a specified inclusive range.
///
/// This constraint is suitable for numeric types (int, double), strings,
/// DateTimes, and any other custom class that implements the [Comparable] interface.
///
/// The range is inclusive, meaning the [minValue] and [maxValue] themselves
/// will match if the field value is equal to them.
///
/// Example usage:
/// ```dart
/// // Find products with stock between 10 and 50 (inclusive)
/// final inStockRange = RangeConstraint.forRange(
///   minValue: 10,
///   maxValue: 50,
///   fieldExtractor: (product) => product.stock,
/// );
///
/// // Find users whose names start with letters between 'A' and 'M'
/// final namesAtoM = RangeConstraint.forRange(
///   minValue: 'A',
///   maxValue: 'M',
///   fieldExtractor: (user) => user.name,
/// );
/// ```
class RangeConstraint<T, F extends Comparable> extends QueryConstraint<T> {
  final F _minValue;
  final F _maxValue;
  final F Function(T model) _fieldExtractor;

  /// Private constructor to enforce creation via the factory constructor.
  RangeConstraint._({
    required F minValue,
    required F maxValue,
    required F Function(T model) fieldExtractor,
  }) : _minValue = minValue,
       _maxValue = maxValue,
       _fieldExtractor = fieldExtractor;

  /// Creates a [RangeConstraint] to check if a [Comparable] field falls
  /// within the specified inclusive range defined by [minValue] and [maxValue].
  ///
  /// - [minValue]: The inclusive lower bound of the range.
  /// - [maxValue]: The inclusive upper bound of the range.
  /// - [fieldExtractor]: A function to extract the [Comparable] field from the model.
  factory RangeConstraint.forRange({
    required F minValue,
    required F maxValue,
    required F Function(T model) fieldExtractor,
  }) => RangeConstraint._(
    minValue: minValue,
    maxValue: maxValue,
    fieldExtractor: fieldExtractor,
  );

  /// Checks if the [model]'s extracted [Comparable] field falls within the
  /// [_minValue] and [_maxValue] range (inclusive).
  @override
  bool matches(T model) {
    final fieldValue = _fieldExtractor(model);
    return fieldValue.compareTo(_minValue) >= 0 &&
        fieldValue.compareTo(_maxValue) <= 0;
  }
}
