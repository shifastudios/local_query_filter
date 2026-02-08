import "package:local_query_filter/src/constraints/query_constraint.dart";

/// Logical operators supported by [CompoundConstraint].
enum CompoundOperator {
  /// Matches when all nested constraints match.
  and,

  /// Matches when at least one nested constraint matches.
  or,

  /// Matches when the nested constraint does not match.
  ///
  /// This operator requires exactly one nested constraint.
  not,
}

/// A [QueryConstraint] that combines one or more constraints using
/// logical operators.
///
/// The evaluation behavior depends on the selected [CompoundOperator].
/// The constraint list must contain at least one constraint.
class CompoundConstraint<T> extends QueryConstraint<T> {
  final CompoundOperator _operator;
  final List<QueryConstraint<T>> _constraints;

  CompoundConstraint._({
    required CompoundOperator operator,
    required List<QueryConstraint<T>> constraints,
  }) : _operator = operator,
       _constraints = List.unmodifiable(constraints) {
    _validate();
  }

  void _validate() {
    if (_constraints.isEmpty) {
      throw ArgumentError(
        "CompoundConstraint requires at least one constraint.",
      );
    }

    if (_operator == CompoundOperator.not && _constraints.length != 1) {
      throw ArgumentError(
        "CompoundConstraint.not requires exactly one constraint.",
      );
    }
  }

  /// Creates a constraint that matches when all provided [constraints] match.
  factory CompoundConstraint.and({
    required List<QueryConstraint<T>> constraints,
  }) => CompoundConstraint._(
    operator: CompoundOperator.and,
    constraints: constraints,
  );

  /// Creates a constraint that matches when at least one of the provided
  /// [constraints] matches.
  factory CompoundConstraint.or({
    required List<QueryConstraint<T>> constraints,
  }) => CompoundConstraint._(
    operator: CompoundOperator.or,
    constraints: constraints,
  );

  /// Creates a constraint that matches when the provided [constraint]
  /// does not match.
  factory CompoundConstraint.not({required QueryConstraint<T> constraint}) =>
      CompoundConstraint._(
        operator: CompoundOperator.not,
        constraints: [constraint],
      );

  /// Evaluates the constraint against the given [model].
  ///
  /// Returns `true` if the model satisfies the configured logical operator
  /// and nested constraints.
  @override
  bool matches(T model) {
    switch (_operator) {
      case CompoundOperator.and:
        return _constraints.every((c) => c.matches(model));

      case CompoundOperator.or:
        return _constraints.any((c) => c.matches(model));

      case CompoundOperator.not:
        return !_constraints.first.matches(model);
    }
  }
}
