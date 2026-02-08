import "package:local_query_filter/src/constraints/query_constraint.dart";

/// Operators supported by [ArrayUnionConstraint].
///
/// Each operator defines how a model field is evaluated against a set of values.
enum ArrayUnionOperator {
  /// Matches when the iterable field contains a single specified value.
  arrayContains,

  /// Matches when the iterable field contains at least one of the specified values.
  arrayContainsAny,

  /// Matches when the scalar field value is contained in the specified values.
  whereIn,

  /// Matches when the scalar field value is not contained in the specified values.
  whereNotIn,
}

/// A [QueryConstraint] that evaluates a model field against a set of values.
///
/// This constraint supports both:
/// - Iterable fields (e.g. lists or sets)
/// - Scalar fields
///
/// The evaluation behavior depends on the selected [ArrayUnionOperator].
class ArrayUnionConstraint<T, F> extends QueryConstraint<T> {
  final Set<F> _values;
  final ArrayUnionOperator _operator;
  final F Function(T model)? _scalarExtractor;
  final Iterable<F> Function(T model)? _iterableExtractor;

  ArrayUnionConstraint._({
    required Iterable<F> values,
    required ArrayUnionOperator operator,
    F Function(T model)? scalarExtractor,
    Iterable<F> Function(T model)? iterableExtractor,
  }) : _values = values.toSet(),
       _operator = operator,
       _scalarExtractor = scalarExtractor,
       _iterableExtractor = iterableExtractor;

  /// Creates a constraint that matches when the iterable field contains [value].
  ///
  /// The provided [fieldExtractor] must return an iterable field from the model.
  factory ArrayUnionConstraint.arrayContains({
    required F value,
    required Iterable<F> Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: [value],
    iterableExtractor: fieldExtractor,
    operator: ArrayUnionOperator.arrayContains,
  );

  /// Creates a constraint that matches when the iterable field contains
  /// at least one of the provided [values].
  ///
  /// The provided [fieldExtractor] must return an iterable field from the model.
  factory ArrayUnionConstraint.arrayContainsAny({
    required Iterable<F> values,
    required Iterable<F> Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: values,
    iterableExtractor: fieldExtractor,
    operator: ArrayUnionOperator.arrayContainsAny,
  );

  /// Creates a constraint that matches when the scalar field value
  /// is contained in the provided [values].
  ///
  /// The provided [fieldExtractor] must return a scalar value from the model.
  factory ArrayUnionConstraint.whereIn({
    required Iterable<F> values,
    required F Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: values,
    operator: ArrayUnionOperator.whereIn,
    scalarExtractor: fieldExtractor,
  );

  /// Creates a constraint that matches when the scalar field value
  /// is not contained in the provided [values].
  ///
  /// The provided [fieldExtractor] must return a scalar value from the model.
  factory ArrayUnionConstraint.whereNotIn({
    required Iterable<F> values,
    required F Function(T model) fieldExtractor,
  }) => ArrayUnionConstraint._(
    values: values,
    operator: ArrayUnionOperator.whereNotIn,
    scalarExtractor: fieldExtractor,
  );

  /// Evaluates the constraint against the given [model].
  ///
  /// Returns `true` if the model satisfies the configured operator and values.
  @override
  bool matches(T model) {
    switch (_operator) {
      case ArrayUnionOperator.arrayContains:
        final field = _iterableExtractor!(model);
        return field.contains(_values.single);

      case ArrayUnionOperator.arrayContainsAny:
        final field = _iterableExtractor!(model);
        return field.any(_values.contains);

      case ArrayUnionOperator.whereIn:
        return _values.contains(_scalarExtractor!(model));

      case ArrayUnionOperator.whereNotIn:
        return !_values.contains(_scalarExtractor!(model));
    }
  }
}
