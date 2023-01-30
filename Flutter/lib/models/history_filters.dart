class HistoryFilters {
  late List<String> subjects;
  late List<String> teachers;
  late String startDate;
  late String endDate;
  late bool booked;
  late bool completed;
  late bool cancelled;

  /// Constructor for the [HistoryFilters] class \
  /// [subjects] is the list of the subjects to filter\
  /// [teachers] is the list of the teachers to filter\
  /// [startDate] is the start date to filter\
  /// [endDate] is the end date to filter\
  /// [booked] is the booked filter\
  /// [completed] is the completed filter\
  /// [cancelled] is the cancelled filter\
  HistoryFilters({
    this.subjects = const [],
    this.teachers = const [],
  })  : startDate = '',
        endDate = "",
        booked = false,
        completed = false,
        cancelled = false;
}
