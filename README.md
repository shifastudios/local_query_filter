# Local Query Filter

A **high-performance**, **type-safe**, and **extensible** filtering engine for Flutter. Designed for
**client-side** querying of in-memory collections with **search**, **sorting**, and **pagination**,
all executed in a background isolate for **jank-free UI**.

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
  local_query_filter: ^0.2.0 # Use the latest version
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

final now = DateTime.now();

final productFilter = QueryFilter<Product>(
  limit: 10,
  offset: 0,
  ascending: true,
  searchTerm: 'speaker',
  sortingFieldExtractor: (product) => product.price,
  searchFieldsExtractor: (product) => [product.name],
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
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      fieldExtractor: (product) => product.createdAt,
    ),
  ],
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

MIT — see the [LICENSE](https://github.com/shifastudios/local_query_filter/blob/master/LICENSE).

---

## 🤝 Contributing

Have ideas, feedback, or improvements?  
Open an [issue](https://github.com/shifastudios/local_query_filter/issues)
or [pull request](https://github.com/shifastudios/local_query_filter/pulls).