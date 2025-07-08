# Local Query Filter

A robust, **type-safe**, **extensible** filtering engine for Flutter. Designed for **client-side**
querying of in-memory collections with **search**, **sorting**, and **pagination**, all while
maintaining **UI performance** via isolate-based execution.

---

## 🔑 Key Features

* ⚡ **High Performance**: Filtering is executed in a background isolate via `compute`, preventing UI
  jank.
* 🧱 **Composable & Type-Safe**: Build expressive queries using strongly-typed constraints.
* 🔍 **Full-Text Search**: Perform case-insensitive search across multiple fields.
* 🔃 **Advanced Sorting**: Sort by any `Comparable` field in ascending or descending order.
* 📄 **Pagination**: Supports `limit` and `offset` for effortless paginated lists.
* 🧩 **Extensible by Design**: Create your own constraints by extending the `QueryConstraint` class.

---

## 🛠 Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  local_query_filter: ^0.1.0 # Use the latest version
```

Then run:

```bash
flutter pub get
```

---

## ⚙️ Usage

### 1. Define a Data Model

```dart
class Product {
  final String id;
  final String name;
  final double price;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;
  final bool isOnSale;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.tags,
    required this.createdAt,
    required this.isActive,
    required this.isOnSale,
  });
}
```

---

### 2. Create and Apply a Filter

```dart

final productFilter = QueryFilter<Product>(
  constraints: [
    // Must be active
    BooleanConstraint.isTrue(
      fieldExtractor: (product) => product.isActive,
    ),
    // Price under ₹100
    ComparisonConstraint.lessThan(
      value: 100.0,
      fieldExtractor: (product) => product.price,
    ),
    // Tag must include 'sale'
    ArrayUnionConstraint.arrayContains(
      values: ['sale'],
      fieldExtractor: (product) => product.tags,
    ),
    // Created in the last 30 days
    DateRangeConstraint(
      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      fieldExtractor: (product) => product.createdAt,
    ),
  ],
  searchTerm: 'speaker',
  searchFieldsExtractor: (product) => [product.name],
  sortingFieldExtractor: (product) => product.price,
  ascending: true,
  limit: 10,
  offset: 0,
);

Future<void> runFilter() async {
  List<Product> filtered = await productFilter.apply(allProducts);
  for (final product in filtered) {
    print(product.name);
  }
}
```

---

## 🧪 API Overview

### `QueryFilter<T>`

| Property                | Description                                  |
|-------------------------|----------------------------------------------|
| `constraints`           | List of `QueryConstraint`s to apply.         |
| `searchTerm`            | Case-insensitive search term.                |
| `searchFieldsExtractor` | Extracts fields to apply the search term on. |
| `sortingFieldExtractor` | Returns the field used for sorting.          |
| `ascending`             | Determines sort order.                       |
| `limit`                 | Max number of items to return.               |
| `offset`                | Number of items to skip (for pagination).    |

---

### `QueryConstraint<T>`

All constraints extend this base class. You can mix and match them freely:

* ✅ **BooleanConstraint** – Match `true` or `false` values.
* 🔢 **ComparisonConstraint** – Operators like `equal`, `greaterThan`, `lessThan`, etc.
* 🔁 **RangeConstraint** – Check if a value lies within a numeric or comparable range.
* 📅 **DateRangeConstraint** – Validate `DateTime` fields fall within a given range.
* 🏷 **ArrayUnionConstraint** – For list fields. Supports:

    * `arrayContains`
    * `arrayContainsAny`
    * `whereIn`
    * `whereNotIn`
* 🔗 **CompoundConstraint** – Combine multiple constraints using `AND`, `OR`, and `NOT`.
* 🧠 **CustomConstraint** – Write any custom boolean function for filtering.

---

## 📄 License

MIT — see the [LICENSE](https://github.com/shifastudios/local_query_filter/blob/main/LICENSE).

---

## 🤝 Contributing

Found a bug? Want to improve performance or add a feature?

Open an issue or PR at:
👉 [github.com/shifastudios/local\_query\_filter](https://github.com/shifastudios/local_query_filter)