import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] for filtering items based on the boolean value of a field.
///
/// This constraint allows checking if a boolean field is true or false.
///
/// Example usage:
/// ```dart
/// // Find products that are active
/// final activeProducts = BooleanConstraint.isTrue(
///   fieldExtractor: (product) => product.isActive,
/// );
///
/// // Find products that are not on sale (assuming 'isOnSale' is a boolean)
/// final notOnSale = BooleanConstraint.isFalse(
///   fieldExtractor: (product) => product.isOnSale,
/// );
/// ```
class BooleanConstraint<T> extends QueryConstraint<T> {
  final bool _expectedValue;
  final bool Function(T model) _fieldExtractor;

  /// Private constructor to enforce creation via factory constructors.
  BooleanConstraint._({
    required bool expectedValue,
    required bool Function(T model) fieldExtractor,
  }) : _expectedValue = expectedValue,
       _fieldExtractor = fieldExtractor;

  /// Creates a [BooleanConstraint] that matches if the boolean field
  /// extracted by [fieldExtractor] is `true`.
  factory BooleanConstraint.isTrue({
    required bool Function(T model) fieldExtractor,
  }) =>
      BooleanConstraint._(expectedValue: true, fieldExtractor: fieldExtractor);

  /// Creates a [BooleanConstraint] that matches if the boolean field
  /// extracted by [fieldExtractor] is `false`.
  factory BooleanConstraint.isFalse({
    required bool Function(T model) fieldExtractor,
  }) =>
      BooleanConstraint._(expectedValue: false, fieldExtractor: fieldExtractor);

  /// Checks if the [model]'s extracted boolean field matches the [_expectedValue].
  @override
  bool matches(T model) => _fieldExtractor(model) == _expectedValue;
}
