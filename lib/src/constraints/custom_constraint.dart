import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] that delegates evaluation to a custom predicate.
///
/// This constraint allows arbitrary matching logic to be applied
/// to a model via a user-provided function.
class CustomConstraint<T> extends QueryConstraint<T> {
  final bool Function(T model) _customComparator;

  CustomConstraint._({required bool Function(T model) customComparator})
    : _customComparator = customComparator;

  /// Creates a constraint that matches when [customComparator]
  /// returns `true` for the given model.
  factory CustomConstraint({
    required bool Function(T model) customComparator,
  }) => CustomConstraint._(customComparator: customComparator);

  /// Evaluates the constraint against the given [model].
  ///
  /// Returns the result of the provided custom comparator.
  @override
  bool matches(T model) => _customComparator(model);
}
