# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.0.0] – 2026-02-08

### ⚠️ Breaking Changes

- **Removed isolate-based filtering**
    - Filtering no longer uses `compute` or background isolates.
    - Execution now runs on the main isolate using chunked, cooperative yielding.
    - This avoids isolate serialization constraints, closure limitations, and
      non-deterministic behavior with complex constraints.

- **`ArrayUnionConstraint` API and behavior revised**
    - `arrayContains` now matches a *single* value instead of requiring all values.
    - The previous “contains all values” behavior has been removed.
    - Scalar and iterable field extractors are now explicitly separated.

- **Removed `CompoundConstraint.none`**
    - Equivalent behavior can be expressed using `CompoundConstraint.not`
      combined with `or`.

- **Updated equality semantics in `ComparisonConstraint`**
    - `equal` and `notEqual` now rely on `==` / `!=` instead of `compareTo == 0`.
    - This may affect custom `Comparable` implementations.

- **Sorting behavior tightened**
    - Sorting now strictly relies on `Comparable.compareTo`.
    - Case-insensitive string sorting and mixed-type fallbacks were removed.

---

### Performance

- Added single-pass filtering, searching, and pagination when sorting is disabled.
- Introduced early termination when a `limit` is provided.
- Implemented chunked yielding to prevent long synchronous blocks when
  processing large in-memory collections.

---

### API & Architecture Improvements

- Simplified and hardened constraint implementations.
- Removed runtime type checks and `dynamic` fallbacks.
- `DateRangeConstraint` no longer depends on Flutter or third-party date utilities.
- Search field extractor now accepts `Iterable<String>` instead of `List<String>`.
- Constraint collections are now immutable.

---

## [0.2.0] – 2025-08-05

### Docs & Metadata

- Updated package description and added topics in `pubspec.yaml`.
- Refined `README.md`:
    - Improved installation snippet.
    - Reordered usage examples.
    - Clarified constraint behavior.
    - Updated links.

---

## [0.1.0] – Initial Release

- Initial release of `local_query_filter`.
- Supports filtering, sorting, and searching on in-memory collections.
