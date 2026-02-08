import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] that matches a date field within a specified range.
///
/// The range is inclusive of both [start] and [end]. The constraint can
/// optionally ignore the time component of the date values.
class DateRangeConstraint<T> extends QueryConstraint<T> {
  /// The start of the date range (inclusive).
  final DateTime start;

  /// The end of the date range (inclusive).
  final DateTime end;

  /// Whether the time component of the dates should be ignored.
  final bool ignoreTime;

  final DateTime Function(T model) _fieldExtractor;

  late final DateTime _startDate;
  late final DateTime _endDate;

  DateRangeConstraint._({
    required this.start,
    required this.end,
    required this.ignoreTime,
    required DateTime Function(T model) fieldExtractor,
  }) : _fieldExtractor = fieldExtractor {
    assert(!end.isBefore(start));
    if (ignoreTime) {
      _startDate = DateTime(start.year, start.month, start.day);
      _endDate = DateTime(end.year, end.month, end.day);
    }
  }

  /// Creates a constraint that matches when the extracted date value
  /// falls within the range defined by [start] and [end].
  ///
  /// If [ignoreTime] is `true`, only the date components are compared.
  factory DateRangeConstraint.forRange({
    required DateTime start,
    required DateTime end,
    bool ignoreTime = false,
    required DateTime Function(T model) fieldExtractor,
  }) => DateRangeConstraint._(
    start: start,
    end: end,
    ignoreTime: ignoreTime,
    fieldExtractor: fieldExtractor,
  );

  /// Evaluates the constraint against the given [model].
  ///
  /// Returns `true` if the extracted date value is within the configured range.
  @override
  bool matches(T model) {
    final value = _fieldExtractor(model);

    if (ignoreTime) {
      final v = DateTime(value.year, value.month, value.day);
      return !v.isBefore(_startDate) && !v.isAfter(_endDate);
    }

    return !value.isBefore(start) && !value.isAfter(end);
  }
}
