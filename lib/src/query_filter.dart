import "package:flutter/foundation.dart";
import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A type definition for the arguments passed to the `_applyConstraints` isolate function.
///
/// This record bundles the list of items to be filtered and the list of
/// [QueryConstraint]s to apply, providing a clean and type-safe way to
/// transfer data to the background isolate.
typedef _QueryArguments<T> = ({
  List<T> items,
  List<QueryConstraint<T>> constraints,
});

/// The core class of the 'Local Query Filter' package, responsible for
/// applying a sequence of filtering, searching, sorting, and pagination
/// operations to a list of data models.
///
/// [QueryFilter] orchestrates the entire process, leveraging Dart isolates
/// for performance-critical filtering operations.
///
/// Generic type `T` represents the type of the data model being filtered.
///
/// Example usage:
/// ```dart
/// // Assuming `allProducts` is a List<Product>
/// final filter = QueryFilter<Product>(
///   constraints: [
///     // Example: Products with price > 50
///     ComparisonConstraint.greaterThan(value: 50.0, fieldExtractor: (p) => p.price),
///     // Example: Products with 'electronics' tag
///     ArrayUnionConstraint.arrayContainsAny(values: ['electronics'], fieldExtractor: (p) => p.tags),
///   ],
///   searchTerm: 'laptop',
///   searchFieldsExtractor: (p) => [p.name, p.description],
///   sortingFieldExtractor: (p) => p.price,
///   ascending: true,
///   limit: 10,
///   offset: 0,
/// );
///
/// final filteredProducts = await filter.applyFilterAndSort(allProducts);
/// print('Filtered and sorted products: $filteredProducts');
/// ```
class QueryFilter<T> {
  /// The maximum number of items to return after all operations.
  /// If `null`, no limit is applied.
  final int? limit;

  /// The number of items to skip from the beginning of the filtered and sorted list.
  /// If `null` or 0, no items are skipped.
  final int? offset;

  /// Determines the sorting order.
  /// If `true`, items are sorted in ascending order; otherwise, in descending order.
  final bool ascending;

  /// An optional string used for text-based searching across the fields
  /// specified by [searchFieldsExtractor]. The search is case-insensitive.
  final String? searchTerm;

  /// A list of [QueryConstraint]s to apply. Only items that satisfy
  /// ALL of these constraints will be included in the initial filtered set.
  final List<QueryConstraint<T>> constraints;

  /// An optional function that extracts the field from a model of type [T]
  /// to be used for sorting. The extracted field must be [Comparable]
  /// (e.g., `int`, `double`, `String`, `DateTime`).
  /// If `null`, no sorting is applied based on this mechanism.
  final Function(T model)? sortingFieldExtractor;

  /// A required function that extracts a list of [String] fields from a model
  /// of type [T] that should be considered when applying the [searchTerm].
  ///
  /// Example: `(Product p) => [p.name, p.description]`
  final List<String> Function(T model) searchFieldsExtractor;

  // If you decide to re-introduce a logger, uncomment this.
  // Logger get _logger => getLogger("QueryFilter");

  /// Creates a new instance of [QueryFilter].
  ///
  /// - [limit]: Optional. Max number of items to return.
  /// - [offset]: Optional. Number of items to skip.
  /// - [ascending]: Required. `true` for ascending sort, `false` for descending.
  /// - [searchTerm]: Optional. String to search for within fields extracted by [searchFieldsExtractor].
  /// - [constraints]: Required. List of [QueryConstraint]s to apply.
  /// - [sortingFieldExtractor]: Optional. Function to extract the comparable field for sorting.
  /// - [searchFieldsExtractor]: Required. Function to extract string fields for searching.
  const QueryFilter({
    this.limit,
    this.offset,
    this.searchTerm,
    required this.ascending,
    required this.constraints,
    this.sortingFieldExtractor,
    required this.searchFieldsExtractor,
  });

  /// Applies the defined filters, search term, sorting, and pagination
  /// to the given list of [items].
  ///
  /// The filtering based on [constraints] is performed in a background isolate
  /// using `compute` to ensure UI responsiveness, especially for large datasets.
  ///
  /// The operations are applied in the following order:
  /// 1. **Filtering**: Items are filtered by all provided [constraints].
  /// 2. **Searching**: If `searchTerm` is provided, items are filtered by text matching.
  /// 3. **Sorting**: If `sortingFieldExtractor` is provided, items are sorted.
  /// 4. **Pagination**: `offset` and `limit` are applied.
  ///
  /// Returns a [Future] that completes with the processed list of items.
  /// Throws any exceptions encountered during the process.
  Future<List<T>> applyFilterAndSort(List<T> items) async {
    try {
      if (items.isEmpty) {
        return [];
      }

      // 1. Perform filtering in a background isolate for performance.
      // `_QueryArguments` record is used for type-safe and efficient data transfer.
      var filteredItems = await compute<_QueryArguments<T>, List<T>>(
        _applyConstraints,
        (items: items, constraints: constraints),
      );

      // 2. Apply case-insensitive searching if a search term is provided.
      if (searchTerm != null && searchTerm!.isNotEmpty) {
        final lowerCaseSearchTerm = searchTerm!.trim().toLowerCase();

        filteredItems = filteredItems.where((item) {
          final searchFields = searchFieldsExtractor(item);
          // Check if any of the extracted search fields contain the search term
          return searchFields.any(
            (field) => field.trim().toLowerCase().contains(lowerCaseSearchTerm),
          );
        }).toList();
      }

      // 3. Apply sorting if a sorting field extractor is provided.
      if (sortingFieldExtractor != null) {
        filteredItems.sort((a, b) {
          final dynamic fieldValueA = sortingFieldExtractor!(a);
          final dynamic fieldValueB = sortingFieldExtractor!(b);

          int result;
          if (fieldValueA is String && fieldValueB is String) {
            // Case-insensitive comparison for strings
            result = fieldValueA.toLowerCase().compareTo(
              fieldValueB.toLowerCase(),
            );
          } else if (fieldValueA is Comparable && fieldValueB is Comparable) {
            // Regular comparison for Comparable types (numbers, DateTime, etc.)
            result = fieldValueA.compareTo(fieldValueB);
          } else {
            // Fallback to string comparison for non-Comparable or mixed types
            // This case might indicate a type mismatch in the data or extractor.
            result = fieldValueA.toString().compareTo(fieldValueB.toString());
          }

          // Apply ascending or descending sorting based on the 'ascending' flag.
          return ascending ? result : -result;
        });
      }

      // 4. Apply limit and offset for pagination.
      if (limit != null) {
        // Skip 'offset' items (defaulting to 0 if offset is null)
        // and then take 'limit' number of items.
        filteredItems = filteredItems.skip(offset ?? 0).take(limit!).toList();
      }

      return filteredItems;
    } catch (e) {
      // If you decide to re-introduce a logger for error reporting:
      // _logger.e("Error applying filter and sort", e, s);
      // Re-throw the error to ensure the caller can handle it.
      rethrow;
    }
  }

  /// A static helper function designed to run in a separate isolate via `compute`.
  ///
  /// It receives [_QueryArguments] containing the items and constraints,
  /// and returns a list of items that satisfy all constraints.
  ///
  /// This separation ensures heavy filtering operations do not block the UI thread.
  static List<T> _applyConstraints<T>(_QueryArguments<T> args) => args.items
      // Filter items: only include items where ALL provided constraints match.
      .where(
        (item) =>
            args.constraints.every((constraint) => constraint.matches(item)),
      )
      .toList();
}
