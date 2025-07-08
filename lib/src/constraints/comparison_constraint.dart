import "package:local_query_filter/src/constraints/query_constraint.dart";

/// Defines the available comparison operators for [Comparable] fields.
enum ComparisonOperator {
  /// Matches if the field's value is exactly equal to the specified value.
  equal,

  /// Matches if the field's value is not equal to the specified value.
  notEqual,

  /// Matches if the field's value is strictly greater than the specified value.
  greaterThan,

  /// Matches if the field's value is greater than or equal to the specified value.
  greaterThanOrEqual,

  /// Matches if the field's value is strictly less than the specified value.
  lessThan,

  /// Matches if the field's value is less than or equal to the specified value.
  lessThanOrEqual,
}

/// A [QueryConstraint] for filtering items based on standard comparison
/// operations on [Comparable] fields.
///
/// This constraint is suitable for numeric types (int, double), strings,
/// DateTimes, and any other custom class that implements the [Comparable] interface.
///
/// Example usage:
/// ```dart
/// // Find products with a price greater than 50.0
/// final expensiveProducts = ComparisonConstraint.greaterThan(
///   value: 50.0,
///   fieldExtractor: (product) => product.price,
/// );
///
/// // Find users whose age is exactly 30
/// final usersAge30 = ComparisonConstraint.equal(
///   value: 30,
///   fieldExtractor: (user) => user.age,
/// );
///
/// // Find items with a name not equal to "Laptop"
/// final notLaptop = ComparisonConstraint.notEqual(
///   value: "Laptop",
///   fieldExtractor: (item) => item.name,
/// );
/// ```
class ComparisonConstraint<T, F extends Comparable> extends QueryConstraint<T> {
  final F _value;
  final ComparisonOperator _operator;
  final F Function(T model) _fieldExtractor;

  /// Private constructor to enforce creation via factory constructors.
  ComparisonConstraint._({
    required F value,
    required ComparisonOperator operator,
    required F Function(T model) fieldExtractor,
  }) : _value = value,
       _operator = operator,
       _fieldExtractor = fieldExtractor;

  /// Creates a [ComparisonConstraint] that matches if the field's value
  /// is exactly equal to the specified [value].
  factory ComparisonConstraint.equal({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.equal,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a [ComparisonConstraint] that matches if the field's value
  /// is not equal to the specified [value].
  factory ComparisonConstraint.notEqual({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.notEqual,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a [ComparisonConstraint] that matches if the field's value
  /// is strictly greater than the specified [value].
  factory ComparisonConstraint.greaterThan({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.greaterThan,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a [ComparisonConstraint] that matches if the field's value
  /// is greater than or equal to the specified [value].
  factory ComparisonConstraint.greaterThanOrEqual({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.greaterThanOrEqual,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a [ComparisonConstraint] that matches if the field's value
  /// is strictly less than the specified [value].
  factory ComparisonConstraint.lessThan({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.lessThan,
    fieldExtractor: fieldExtractor,
  );

  /// Creates a [ComparisonConstraint] that matches if the field's value
  /// is less than or equal to the specified [value].
  factory ComparisonConstraint.lessThanOrEqual({
    required F value,
    required F Function(T model) fieldExtractor,
  }) => ComparisonConstraint._(
    value: value,
    operator: ComparisonOperator.lessThanOrEqual,
    fieldExtractor: fieldExtractor,
  );

  /// Checks if the [model] matches the comparison condition defined by this constraint.
  ///
  /// The [fieldValue] extracted from the model is compared against the [_value]
  /// using the specified [_operator].
  @override
  bool matches(T model) {
    final fieldValue = _fieldExtractor(model);
    switch (_operator) {
      case ComparisonOperator.equal:
        // Using compareTo for equality is generally robust for Comparable types.
        // It's equivalent to `fieldValue == _value` for most common Comparable types,
        // but explicitly uses the Comparable contract.
        return fieldValue.compareTo(_value) == 0;
      case ComparisonOperator.notEqual:
        return fieldValue.compareTo(_value) != 0;
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
