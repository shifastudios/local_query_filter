import "package:local_query_filter/src/constraints/query_constraint.dart";

/// Applies filtering, searching, sorting, and pagination to a list of items.
///
/// A [QueryFilter] evaluates a list of models using a set of
/// [QueryConstraint]s, an optional text search, optional sorting,
/// and optional offset/limit pagination.
///
/// The operations are applied in the following order:
/// 1. Constraints and search predicates
/// 2. Sorting (if configured)
/// 3. Pagination
class QueryFilter<T> {
  /// The maximum number of items to return.
  ///
  /// If `null`, no upper bound is applied.
  final int? limit;

  /// The number of matching items to skip before collecting results.
  ///
  /// If `null`, no offset is applied.
  final int? offset;

  /// Whether sorting should be applied in ascending order.
  ///
  /// This value is only used when [sortingFieldExtractor] is provided.
  final bool ascending;

  /// Optional search term used to filter items based on text fields.
  ///
  /// The search is case-insensitive and is applied after constraints.
  final String? searchTerm;

  /// The list of constraints used to filter items.
  ///
  /// All constraints must match for an item to be included.
  final List<QueryConstraint<T>> constraints;

  /// Optional extractor used to obtain a sortable field from a model.
  ///
  /// When provided, matching items are sorted using the extracted value.
  final Comparable Function(T model)? sortingFieldExtractor;

  /// Extracts the searchable text fields from a model.
  ///
  /// Each returned string is compared against [searchTerm] when search
  /// is enabled.
  final Iterable<String> Function(T model) searchFieldsExtractor;

  static const int _chunkSize = 500;

  /// Creates a [QueryFilter] with the provided configuration.
  const QueryFilter({
    this.limit,
    this.offset,
    this.searchTerm,
    required this.ascending,
    required this.constraints,
    this.sortingFieldExtractor,
    required this.searchFieldsExtractor,
  });

  Future<void> _yield() => Future<void>.delayed(Duration.zero);

  /// Applies the configured filter, search, sorting, and pagination
  /// to the given [items].
  ///
  /// Returns a new list containing the matching items.
  Future<List<T>> applyFilterAndSort(List<T> items) async {
    if (items.isEmpty) return [];

    final term = searchTerm?.trim().toLowerCase();
    final hasSearch = term != null && term.isNotEmpty;

    final canEarlyStop = sortingFieldExtractor == null && limit != null;

    // Fast path: filter + search + pagination in a single pass.
    if (canEarlyStop) {
      return _applyPredicateWithEarlyStop(items, term, hasSearch);
    }

    final matched = <T>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      if (!_matchesConstraints(item)) continue;
      if (hasSearch && !_matchesSearch(item, term)) continue;

      matched.add(item);

      if (i > 0 && i % _chunkSize == 0) {
        await _yield();
      }
    }

    // Sort after all matches are collected.
    if (sortingFieldExtractor != null) {
      matched.sort((a, b) {
        final aVal = sortingFieldExtractor!(a);
        final bVal = sortingFieldExtractor!(b);
        return ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
      await _yield();
    }

    return _applyPagination(matched);
  }

  /// Evaluates all configured constraints against the given [item].
  ///
  /// Returns `true` if all constraints match.
  bool _matchesConstraints(T item) {
    for (final c in constraints) {
      if (!c.matches(item)) return false;
    }
    return true;
  }

  /// Evaluates the search predicate against the given [item].
  ///
  /// Returns `true` if any extracted search field contains [needle].
  bool _matchesSearch(T item, String needle) {
    for (final field in searchFieldsExtractor(item)) {
      if (field.toLowerCase().contains(needle)) {
        return true;
      }
    }
    return false;
  }

  /// Applies filtering, search, and pagination in a single pass.
  ///
  /// This method is used when sorting is disabled and a [limit] is provided,
  /// allowing early termination once enough items have been collected.
  Future<List<T>> _applyPredicateWithEarlyStop(
    List<T> items,
    String? term,
    bool hasSearch,
  ) async {
    final result = <T>[];
    final start = offset ?? 0;
    final max = limit!;
    var seen = 0;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      if (!_matchesConstraints(item)) continue;
      if (hasSearch && !_matchesSearch(item, term!)) continue;

      seen++;
      if (seen > start) {
        result.add(item);
        if (result.length >= max) break;
      }

      if (i > 0 && i % _chunkSize == 0) {
        await _yield();
      }
    }

    return result;
  }

  /// Applies offset and limit pagination to the given [items].
  ///
  /// Returns a sublist containing the requested slice of items.
  List<T> _applyPagination(List<T> items) {
    if (offset == null && limit == null) return items;

    final start = offset ?? 0;
    final end = limit == null
        ? items.length
        : (start + limit!).clamp(0, items.length);

    if (start >= items.length || start >= end) return const [];

    return items.sublist(start, end);
  }
}
