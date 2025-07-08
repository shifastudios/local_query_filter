import "package:local_query_filter/src/constraints/query_constraint.dart";

/// Defines the logical operators for combining multiple [QueryConstraint]s.
enum CompoundOperator {
  /// Logical OR: Matches if at least one of the provided constraints matches.
  or,

  /// Logical NOT: Matches if the single provided constraint DOES NOT match.
  not,

  /// Logical AND: Matches if ALL of the provided constraints match.
  and,

  /// Logical NONE: Matches if NONE of the provided constraints match.
  /// This is equivalent to NOT (Constraint1 OR Constraint2 OR ...).
  none,
}

/// A [QueryConstraint] that combines multiple other [QueryConstraint]s
/// using logical AND, OR, NOT, or NONE operators.
///
/// This allows for the construction of complex filtering logic by grouping
/// simpler constraints.
///
/// Example Usage:
/// ```dart
/// // Find products that are both active AND in stock.
/// final activeAndInStock = CompoundConstraint.and(
///   constraints: [
///     ComparisonConstraint.equal(value: true, fieldExtractor: (p) => p.isActive),
///     ComparisonConstraint.greaterThan(value: 0, fieldExtractor: (p) => p.stock),
///   ],
/// );
///
/// // Find products that are either on sale OR have free shipping.
/// final saleOrFreeShipping = CompoundConstraint.or(
///   constraints: [
///     ComparisonConstraint.equal(value: true, fieldExtractor: (p) => p.isOnSale),
///     ComparisonConstraint.equal(value: true, fieldExtractor: (p) => p.hasFreeShipping),
///   ],
/// );
///
/// // Find products that are NOT "Electronics".
/// final notElectronics = CompoundConstraint.not(
///   constraint: ComparisonConstraint.equal(value: 'Electronics', fieldExtractor: (p) => p.category),
/// );
///
/// // Find products that are NEITHER out of stock NOR discontinued.
/// final availableProducts = CompoundConstraint.none(
///   constraints: [
///     ComparisonConstraint.equal(value: 0, fieldExtractor: (p) => p.stock),
///     ComparisonConstraint.equal(value: true, fieldExtractor: (p) => p.isDiscontinued),
///   ],
/// );
/// ```
class CompoundConstraint<T> extends QueryConstraint<T> {
  final CompoundOperator _operator;
  final List<QueryConstraint<T>> _constraints;

  /// Private constructor to enforce creation via factory constructors.
  ///
  /// For the [CompoundOperator.not] type, the [constraints] list must contain
  /// exactly one element.
  CompoundConstraint._({
    required CompoundOperator operator,
    required List<QueryConstraint<T>> constraints,
  }) : _operator = operator,
       _constraints = constraints;

  /// Creates a [CompoundConstraint] that matches if at least one of the
  /// provided [constraints] matches the model (Logical OR).
  factory CompoundConstraint.or({
    required List<QueryConstraint<T>> constraints,
  }) {
    if (constraints.isEmpty) {
      throw ArgumentError(
        "CompoundConstraint.or must have at least one constraint.",
      );
    }
    return CompoundConstraint._(
      constraints: constraints,
      operator: CompoundOperator.or,
    );
  }

  /// Creates a [CompoundConstraint] that matches if the provided [constraint]
  /// DOES NOT match the model (Logical NOT).
  ///
  /// This factory takes a single [QueryConstraint] as input, ensuring clear
  /// negation semantics.
  factory CompoundConstraint.not({required QueryConstraint<T> constraint}) =>
      CompoundConstraint._(
        constraints: [constraint], // Wrap the single constraint in a list
        operator: CompoundOperator.not,
      );

  /// Creates a [CompoundConstraint] that matches if ALL of the provided
  /// [constraints] match the model (Logical AND).
  factory CompoundConstraint.and({
    required List<QueryConstraint<T>> constraints,
  }) {
    if (constraints.isEmpty) {
      throw ArgumentError(
        "CompoundConstraint.and must have at least one constraint.",
      );
    }
    return CompoundConstraint._(
      constraints: constraints,
      operator: CompoundOperator.and,
    );
  }

  /// Creates a [CompoundConstraint] that matches if NONE of the provided
  /// [constraints] match the model.
  ///
  /// This is logically equivalent to `NOT (Constraint1 OR Constraint2 OR ...)`.
  factory CompoundConstraint.none({
    required List<QueryConstraint<T>> constraints,
  }) {
    if (constraints.isEmpty) {
      throw ArgumentError(
        "CompoundConstraint.none must have at least one constraint.",
      );
    }
    return CompoundConstraint._(
      constraints: constraints,
      operator: CompoundOperator.none,
    );
  }

  /// Checks if the [model] matches the compound condition defined by this constraint.
  ///
  /// The specific logical operation (AND, OR, NOT, NONE) is applied based on
  /// the [_operator] and the evaluation of the [_constraints] list.
  @override
  bool matches(T model) {
    switch (_operator) {
      case CompoundOperator.and:
        return _constraints.every((constraint) => constraint.matches(model));

      case CompoundOperator.or:
        return _constraints.any((constraint) => constraint.matches(model));

      case CompoundOperator.not:
        // By design of the factory constructor, _constraints will always have one element here.
        return !_constraints.first.matches(model);

      case CompoundOperator.none:
        // 'none' means that 'any' of the constraints should NOT match.
        // If 'any' matches, then 'none' fails. So, we return the negation of 'any'.
        // return !_constraints.every((constraint) => constraint.matches(model)); // This was incorrect for 'none'
        return !_constraints.any((constraint) => constraint.matches(model));
    }
  }
}
