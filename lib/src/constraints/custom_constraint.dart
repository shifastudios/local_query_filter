import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] that allows for highly flexible and custom filtering logic.
///
/// This constraint takes a [customComparator] function, which is a predicate
/// that directly determines whether a given model matches the constraint.
/// It acts as an escape hatch for any complex or specific filtering requirements
/// that are not covered by the other predefined constraint types.
///
/// Example usage:
/// ```dart
/// // Find products that are on sale AND have less than 10 stock,
/// // using a single custom constraint for combined logic.
/// final customComplexFilter = CustomConstraint<Product>(
///   customComparator: (product) => product.isOnSale && product.stock < 10,
/// );
///
/// // Find users whose username starts with 'A' and whose ID is an even number.
/// final specificUsers = CustomConstraint<User>(
///   customComparator: (user) => user.username.startsWith('A') && user.id % 2 == 0,
/// );
/// ```
class CustomConstraint<T> extends QueryConstraint<T> {
  final bool Function(T model) _customComparator;

  /// Private constructor to enforce creation via the factory constructor.
  CustomConstraint._({required bool Function(T model) customComparator})
    : _customComparator = customComparator;

  /// Creates a [CustomConstraint] with a given [customComparator] function.
  ///
  /// The [customComparator] is a function that takes a model of type [T]
  /// and returns `true` if the model matches the custom condition, or `false` otherwise.
  factory CustomConstraint({
    required bool Function(T model) customComparator,
  }) => CustomConstraint._(customComparator: customComparator);

  /// Checks if the [model] matches the custom condition defined by the [_customComparator] function.
  @override
  bool matches(T model) => _customComparator(model);
}
