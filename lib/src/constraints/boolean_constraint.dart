import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] that evaluates a boolean field on a model.
///
/// The constraint matches when the extracted field value is equal
/// to the expected boolean value.
class BooleanConstraint<T> extends QueryConstraint<T> {
  final bool _expectedValue;
  final bool Function(T model) _fieldExtractor;

  BooleanConstraint._({
    required bool expectedValue,
    required bool Function(T model) fieldExtractor,
  }) : _expectedValue = expectedValue,
       _fieldExtractor = fieldExtractor;

  /// Creates a constraint that matches when the extracted field value is `true`.
  factory BooleanConstraint.isTrue({
    required bool Function(T model) fieldExtractor,
  }) =>
      BooleanConstraint._(expectedValue: true, fieldExtractor: fieldExtractor);

  /// Creates a constraint that matches when the extracted field value is `false`.
  factory BooleanConstraint.isFalse({
    required bool Function(T model) fieldExtractor,
  }) =>
      BooleanConstraint._(expectedValue: false, fieldExtractor: fieldExtractor);

  /// Evaluates the constraint against the given [model].
  ///
  /// Returns `true` if the extracted field value matches the expected value.
  @override
  bool matches(T model) => _fieldExtractor(model) == _expectedValue;
}
