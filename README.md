[![pub package](https://img.shields.io/pub/v/local_query_filter.svg)](https://pub.dartlang.org/packages/local_query_filter)
[![Code size](https://img.shields.io/github/languages/code-size/shifastudios/local_query_filter)](https://github.com/shifastudios/local_query_filter)
[![License](https://img.shields.io/github/license/shifastudios/local_query_filter)](https://github.com/shifastudios/local_query_filter/blob/master/LICENSE)

# local_query_filter

A small, explicit query engine for **dynamic, client-side filtering** of in-memory data in Dart and Flutter.

`local_query_filter` is designed for cases where query logic is **runtime-composed**, **user-driven**, and **reusable**, and where pushing filtering to a backend is either impossible or undesirable.

There is no reflection, no code generation, and no hidden schema.
All behavior is explicit and type-safe.

---

## Why This Exists

Simple `.where()` chains break down when:

- filters are built dynamically (UI-driven search and filters)
- query logic must be reused across screens or features
- constraints need to be composed (`AND`, `OR`, `NOT`)
- filtering, searching, sorting, and pagination must stay consistent

This package separates **what a filter means** from **how it is applied**.

---

## Key Features

- Strongly-typed, composable constraints
- Logical composition (`and`, `or`, `not`)
- Case-insensitive text search
- Sorting by any `Comparable` field
- Offset + limit pagination
- Async-friendly execution for large lists
- Fully extensible via custom constraints

---

## When to Use This

Use `local_query_filter` when:

- filters are constructed dynamically at runtime
- query logic must be reusable and testable
- data already lives in memory (cache, offline store, API results)
- backend filtering is unavailable, expensive, or too rigid

### When Not to Use This

Do not use this library if:

- filtering can be done entirely in a database
- queries are static and trivial
- performance depends on indexed, ranked, or streaming queries

This is **not** a database or ORM replacement.
There is no indexing, query planning, ranking, or persistence.

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  local_query_filter: ^latest
```

Then run:

```bash
flutter pub get
```

---

## Core Concepts

### QueryConstraint

All filtering logic is expressed as a `QueryConstraint<T>`.

```dart
abstract class QueryConstraint<T> {
  bool matches(T model);
}
```

Each constraint answers a single question:

> Does this model match?

Constraints are composable and reusable.

---

### QueryFilter

`QueryFilter` applies constraints, optional search, optional sorting, and pagination.

Execution order:

1. Constraints
2. Search
3. Sorting (if enabled)
4. Pagination

---

## Basic Example

### Model

```dart
class Product {
  final String id;
  final String name;
  final double price;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.tags,
    required this.createdAt,
    required this.isActive,
  });
}
```

---

### Filter

```dart
final now = DateTime.now();

final filter = QueryFilter<Product>(
  constraints: [
    BooleanConstraint.isTrue(
      fieldExtractor: (p) => p.isActive,
    ),
    ComparisonConstraint.lessThan(
      value: 100.0,
      fieldExtractor: (p) => p.price,
    ),
    ArrayUnionConstraint.arrayContains(
      value: 'sale',
      fieldExtractor: (p) => p.tags,
    ),
    DateRangeConstraint.forRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
      fieldExtractor: (p) => p.createdAt,
    ),
  ],
  searchTerm: 'speaker',
  searchFieldsExtractor: (p) => [p.name],
  sortingFieldExtractor: (p) => p.price,
  ascending: true,
  limit: 10,
  offset: 0,
);

final results = await filter.applyFilterAndSort(allProducts);
```

---

## Dynamic Filters (The Real Use Case)

This is where `local_query_filter` becomes valuable.

```dart
final constraints = <QueryConstraint<Product>>[];

if (onlyActive) {
  constraints.add(
    BooleanConstraint.isTrue(fieldExtractor: (p) => p.isActive),
  );
}

if (maxPrice != null) {
  constraints.add(
    ComparisonConstraint.lessThan(
      value: maxPrice!,
      fieldExtractor: (p) => p.price,
    ),
  );
}

if (selectedTags.isNotEmpty) {
  constraints.add(
    ArrayUnionConstraint.arrayContainsAny(
      values: selectedTags,
      fieldExtractor: (p) => p.tags,
    ),
  );
}

final filter = QueryFilter<Product>(
  constraints: constraints,
  searchTerm: searchQuery,
  searchFieldsExtractor: (p) => [p.name],
  ascending: true,
);
```

Constraints can be added, removed, or reused without rewriting query logic.

---

## Built-in Constraints

### BooleanConstraint

Match boolean fields.

- `isTrue`
- `isFalse`

---

### ComparisonConstraint

Compare scalar values.

- `equal`
- `notEqual`
- `greaterThan`
- `greaterThanOrEqual`
- `lessThan`
- `lessThanOrEqual`

---

### RangeConstraint

Inclusive min/max range checks.

---

### DateRangeConstraint

Match `DateTime` values within a range.
Optionally ignore the time component.

---

### ArrayUnionConstraint

For iterable and scalar field membership checks.

- `arrayContains`
- `arrayContainsAny`
- `whereIn`
- `whereNotIn`

---

### CompoundConstraint

Logical composition.

- `and`
- `or`
- `not` (exactly one constraint)

---

### CustomConstraint

Escape hatch for advanced logic.

```dart
CustomConstraint<Product>(
customComparator: (p) => expensiveCheck(p),
);
```

Use sparingly. Prefer explicit constraints for reuse.

---

## Performance Notes

- Designed for in-memory collections
- Yields to the event loop during large iterations
- Early termination when sorting is disabled and `limit` is set
- Sorting requires collecting all matches first

---

## Design Principles

- Explicit over implicit
- Composition over configuration
- No reflection
- No code generation
- No hidden runtime behavior

---

## License MIT

See [LICENSE](https://github.com/shifastudios/local_query_filter/blob/master/LICENSE)

---

## Contributing

Issues and pull requests are welcome.

High-value contributions include:

- new reusable constraints
- benchmarks and profiling
- API ergonomics and documentation

Open an [issue](https://github.com/shifastudios/local_query_filter/issues) or submit a [pull request](https://github.com/shifastudios/local_query_filter/pulls) on GitHub.
