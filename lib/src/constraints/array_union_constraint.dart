import "package:local_query_filter/src/constraints/query_constraint.dart";

/// Defines the available operators for array and list-based constraints.
enum ArrayUnionOperator {
  /// Matches if an iterable field contains all specified values.
  arrayContains,

  /// Matches if an iterable field contains any of the specified values.
  arrayContainsAny,

  /// Matches if a scalar field's value is present within a specified list of values.
  whereIn,

  /// Matches if a scalar field's value is not present within a specified list of values.
  whereNotIn,
}

/// A [QueryConstraint] for filtering items based on array or list containment,
/// or checking if a scalar field's value is present in a given list.
///
/// This constraint is useful for:
/// - Checking if an item's list field contains specific elements.
/// - Checking if an item's list field contains at least one of a set of elements.
/// - Filtering items where a specific field's value is (or is not) in a provided set.
///
/// Example usage:
/// ```dart
/// // Find products that have ALL 'electronics' AND 'sale' tags
/// final electronicsAndSale = ArrayUnionConstraint.arrayContains(
///   values: ['electronics', 'sale'],
///   fieldExtractor: (product) => product.tags,
/// );
///
/// // Find products that have ANY of 'electronics' OR 'sale' tags
/// final electronicsOrSale = ArrayUnionConstraint.arrayContainsAny(
///   values: ['electronics', 'sale'],
///   fieldExtractor: (product) => product.tags,
/// );
///
/// // Find products whose category is 'Electronics' or 'Apparel'
/// final specificCategories = ArrayUnionConstraint.whereIn(
///   values: ['Electronics', 'Apparel'],
///   fieldExtractor: (product) => product.category,
/// );
/// ```
class ArrayUnionConstraint<T, F> extends QueryConstraint<T> {
  final List<F> _values;
  final ArrayUnionOperator _operator;
  final F Function(T model) _fieldExtractor;

  /// Private constructor to enforce creation via factory constructors.
  ArrayUnionConstraint._({
    required List<F> values,
    required ArrayUnionOperator operator,
    required F Function(T model) fieldExtractor,
  }) : _values = values,
       _operator = operator,
       _fieldExtractor = fieldExtractor;

  /// Creates an [ArrayUnionConstraint] that matches if an iterable field
  /// contains all of the specified [values].
  ///
  /// The [fieldExtractor] function must return an [Iterable<F>].
  factory ArrayUnionConstraint.arrayContains({
    required List<F> values,
    required F Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: values,
    fieldExtractor: fieldExtractor,
    operator: ArrayUnionOperator.arrayContains,
  );

  /// Creates an [ArrayUnionConstraint] that matches if an iterable field
  /// contains any of the specified [values].
  ///
  /// The [fieldExtractor] function must return an [Iterable<F>].
  factory ArrayUnionConstraint.arrayContainsAny({
    required List<F> values,
    required F Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: values,
    fieldExtractor: fieldExtractor,
    operator: ArrayUnionOperator.arrayContainsAny,
  );

  /// Creates an [ArrayUnionConstraint] that matches if a scalar field's value
  /// is present within the specified list of [values].
  ///
  /// The [fieldExtractor] function should return a single value of type [F].
  factory ArrayUnionConstraint.whereIn({
    required List<F> values,
    required F Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: values,
    fieldExtractor: fieldExtractor,
    operator: ArrayUnionOperator.whereIn,
  );

  /// Creates an [ArrayUnionConstraint] that matches if a scalar field's value
  /// is not present within the specified list of [values].
  ///
  /// The [fieldExtractor] function should return a single value of type [F].
  factory ArrayUnionConstraint.whereNotIn({
    required List<F> values,
    required F Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: values,
    fieldExtractor: fieldExtractor,
    operator: ArrayUnionOperator.whereNotIn,
  );

  @override
  bool matches(T model) {
    final dynamic fieldValue = _fieldExtractor(
      model,
    ); // Use dynamic here for flexibility

    switch (_operator) {
      case ArrayUnionOperator.arrayContains:
        // Ensure the field is an Iterable before calling methods like .toSet()
        if (fieldValue is Iterable) {
          // It's safer to cast to Iterable<F> if we expect specific element types,
          // but just Iterable is fine for .toSet() and .contains().
          // However, if `_values` contains elements not of type F, this will fail at runtime.
          // For maximum safety, you might consider an explicit cast if confident in types:
          // final fieldValueSet = (fieldValue as Iterable<F>).toSet();
          final fieldValueSet = fieldValue.toSet();
          return _values.every(fieldValueSet.contains);
        }
        return false;

      case ArrayUnionOperator.arrayContainsAny:
        if (fieldValue is Iterable) {
          final fieldValueSet = fieldValue.toSet();
          return _values.any(fieldValueSet.contains);
        }
        return false;

      case ArrayUnionOperator.whereIn:
        // For 'whereIn' and 'whereNotIn', fieldValue is expected to be a scalar,
        // so no Iterable check is needed. Direct comparison is fine.
        return _values.contains(fieldValue);

      case ArrayUnionOperator.whereNotIn:
        return !_values.contains(fieldValue);
    }
  }
}
