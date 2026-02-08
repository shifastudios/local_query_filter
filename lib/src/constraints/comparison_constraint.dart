import "package:local_query_filter/src/constraints/query_constraint.dart";

/// Comparison operators supported by [ComparisonConstraint].
enum ComparisonOperator {
  /// Matches when the field value is equal to the provided value.
  equal,

  /// Matches when the field value is not equal to the provided value.
  notEqual,

  /// Matches when the field value is greater than the provided value.
  greaterThan,

  /// Matches when the field value is greater than or equal to the provided value.
  greaterThanOrEqual,

  /// Matches when the field value is less than the provided value.
  lessThan,

  /// Matches when the field value is less than or equal to the provided value.
  lessThanOrEqual,
}

/// A [QueryConstraint] that compares a model field against a value.
///
/// The field type [F] must implement [Comparable]. The comparison behavior
/// is determined by the selected [ComparisonOperator].
class ComparisonConstraint<T, F extends Comparable> extends QueryConstraint<T> {
  final F _value;
  final ComparisonOperator _operator;
  final F Function(T model) _fieldExtractor;

  ComparisonConstraint._({
    required F value,
    required ComparisonOperator operator,
    required F Function(T model) fieldExtractor,
  }) : _value = value,
       _operator = operator,
       _fieldExtractor = fieldExtractor;

  /// Creates a constraint that matches when the field value
  /// is equal to [value].
  factory ComparisonConstraint.equal({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.equal,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a constraint that matches when the field value
  /// is not equal to [value].
  factory ComparisonConstraint.notEqual({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.notEqual,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a constraint that matches when the field value
  /// is greater than [value].
  factory ComparisonConstraint.greaterThan({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.greaterThan,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a constraint that matches when the field value
  /// is greater than or equal to [value].
  factory ComparisonConstraint.greaterThanOrEqual({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.greaterThanOrEqual,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a constraint that matches when the field value
  /// is less than [value].
  factory ComparisonConstraint.lessThan({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.lessThan,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a constraint that matches when the field value
  /// is less than or equal to [value].
  factory ComparisonConstraint.lessThanOrEqual({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.lessThanOrEqual,
    fieldExtractor: fieldExtractor,
  );

  /// Evaluates the constraint against the given [model].
  ///
  /// Returns `true` if the extracted field value satisfies
  /// the configured comparison operator.
  @override
  bool matches(T model) {
    final fieldValue = _fieldExtractor(model);
    switch (_operator) {
      case ComparisonOperator.equal:
        return fieldValue == _value;
      case ComparisonOperator.notEqual:
        return fieldValue != _value;
      case ComparisonOperator.greaterThan:
        return fieldValue.compareTo(_value) > 0;
      case ComparisonOperator.greaterThanOrEqual:
        return fieldValue.compareTo(_value) >= 0;
      case ComparisonOperator.lessThan:
        return fieldValue.compareTo(_value) < 0;
      case ComparisonOperator.lessThanOrEqual:
        return fieldValue.compareTo(_value) <= 0;
    }
  }
}
