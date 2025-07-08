/// An abstract base class defining the contract for all filtering constraints
/// within the 'Local Query Filter' package.
///
/// Any class that implements [QueryConstraint] must provide a concrete
/// implementation for the [matches] method. This method determines whether
/// a given data model satisfies the specific filtering condition defined
/// by the constraint.
///
/// Generic type `T` represents the type of the data model being filtered.
///
/// Subclasses of [QueryConstraint] provide specific filtering logic, such as
/// comparisons (e.g., equality, greater than), array/list containment checks,
/// date range filtering, and custom conditions.
abstract class QueryConstraint<T> {
  /// Determines if the provided [model] satisfies the condition defined by this constraint.
  ///
  /// Subclasses must implement this method to provide their specific filtering logic.
  ///
  /// Returns `true` if the [model] matches the constraint, `false` otherwise.
  bool matches(T model);
}
