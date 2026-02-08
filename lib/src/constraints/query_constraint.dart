/// Base class for all query constraints.
///
/// A [QueryConstraint] defines the logic to evaluate whether a specific
/// instance of [T] satisfies a filtering condition.
abstract class QueryConstraint<T> {
  /// Evaluates the constraint against the provided [model].
  ///
  /// Returns `true` if the [model] meets the criteria defined by this constraint.
  bool matches(T model);
}
