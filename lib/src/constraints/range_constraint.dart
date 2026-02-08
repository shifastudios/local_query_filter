import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] that matches when a field value falls within a range.
///
/// The range is inclusive of both the minimum and maximum values.
class RangeConstraint<T, F extends Comparable> extends QueryConstraint<T> {
  final F _minValue;
  final F _maxValue;
  final F Function(T model) _fieldExtractor;

  RangeConstraint._({
    required F minValue,
    required F maxValue,
    required F Function(T model) fieldExtractor,
  }) : assert(minValue.compareTo(maxValue) <= 0),
       _minValue = minValue,
       _maxValue = maxValue,
       _fieldExtractor = fieldExtractor;

  /// Creates a constraint that matches when the extracted field value
  /// is between [minValue] and [maxValue], inclusive.
  factory RangeConstraint.forRange({
    required F minValue,
    required F maxValue,
    required F Function(T model) fieldExtractor,
  }) => RangeConstraint._(
    minValue: minValue,
    maxValue: maxValue,
    fieldExtractor: fieldExtractor,
  );

  /// Evaluates the constraint against the given [model].
  ///
  /// Returns `true` if the extracted field value is within the configured range.
  @override
  bool matches(T model) {
    final fieldValue = _fieldExtractor(model);
    return fieldValue.compareTo(_minValue) >= 0 &&
        fieldValue.compareTo(_maxValue) <= 0;
  }
}
