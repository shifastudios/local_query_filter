import "package:dart_date/dart_date.dart";
import "package:flutter/material.dart"; // Required for DateTimeRange
import "package:local_query_filter/src/constraints/query_constraint.dart";

/// A [QueryConstraint] for filtering items based on whether a [DateTime] field
/// falls within a specified date and/or time range.
///
/// This constraint leverages the [DateTimeRange] class from Flutter's `material.dart`
/// and date utility methods from the `dart_date` package for flexible date comparisons.
///
/// Example usage:
/// ```dart
/// // Find events scheduled for today (ignoring time)
/// final today = DateTime.now();
/// final todayRange = DateTimeRange(start: today.startOfDay, end: today.endOfDay);
/// final eventsToday = DateRangeConstraint.forRange(
///   dateRange: todayRange,
///   fieldExtractor: (event) => event.scheduledDate,
///   ignoreTime: true,
/// );
///
/// // Find transactions that occurred between specific date and times
/// final specificPeriod = DateTimeRange(
///   start: DateTime(2023, 10, 26, 10, 0, 0),
///   end: DateTime(2023, 10, 26, 18, 0, 0),
/// );
/// final transactionsInPeriod = DateRangeConstraint.forRange(
///   dateRange: specificPeriod,
///   fieldExtractor: (transaction) => transaction.timestamp,
///   ignoreTime: false, // Include time in comparison
/// );
/// ```
class DateRangeConstraint<T> extends QueryConstraint<T> {
  final bool _ignoreTime;
  final DateTimeRange _dateRange;
  final DateTime Function(T model) _fieldExtractor;

  /// Private constructor to enforce creation via the factory constructor.
  DateRangeConstraint._({
    bool ignoreTime = false,
    required DateTimeRange dateRange,
    required DateTime Function(T model) fieldExtractor,
  }) : _dateRange = dateRange,
       _ignoreTime = ignoreTime,
       _fieldExtractor = fieldExtractor;

  /// Creates a [DateRangeConstraint] to check if a [DateTime] field falls
  /// within the specified [dateRange].
  ///
  /// - [dateRange]: The [DateTimeRange] defining the start and end boundaries.
  /// - [fieldExtractor]: A function to extract the [DateTime] field from the model.
  /// - [ignoreTime]: If `true`, only the date (year, month, day) components
  ///   are considered for comparison. If `false` (default), the full [DateTime]
  ///   including time is used.
  factory DateRangeConstraint.forRange({
    bool ignoreTime = false,
    required DateTimeRange dateRange,
    required DateTime Function(T model) fieldExtractor,
  }) => DateRangeConstraint._(
    dateRange: dateRange,
    fieldExtractor: fieldExtractor,
    ignoreTime: ignoreTime,
  );

  /// Checks if the [model]'s extracted [DateTime] field falls within the
  /// specified date range according to the [_ignoreTime] setting.
  @override
  bool matches(T model) {
    final fieldValue = _fieldExtractor(model);

    if (_ignoreTime) {
      // Compares only the date part (ignoring time)
      // `startOfDay` and `endOfDay` from dart_date ensure accurate date-only comparison
      return fieldValue.startOfDay.isSameOrAfter(_dateRange.start.startOfDay) &&
          fieldValue.endOfDay.isSameOrBefore(_dateRange.end.endOfDay);
    } else {
      // Compares full DateTime including time
      return fieldValue.isSameOrAfter(_dateRange.start) &&
          fieldValue.isSameOrBefore(_dateRange.end);
    }
  }
}
