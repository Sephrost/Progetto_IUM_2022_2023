import 'package:flutter/foundation.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/models/subject.dart';

/// The controller used to manage the calendar page and get
/// the subjects available for the selected date.
class CalendarController extends ChangeNotifier {
  /// The date selected in the calendar.
  ///
  /// It's itiatialized to the current date, if it's a weekday.
  /// If is in the weekend the date is set to the previous wednesday.
  DateTime _selectedDate = DateTime.now().weekday < 6
      ? DateTime.now()
      : (DateTime.now().weekday == 6)
          ? DateTime.now().subtract(const Duration(days: 1))
          : DateTime.now().subtract(const Duration(days: 2));

  /// The list of the subjects available for a certain date
  List<Subject> subjects = [];

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) async {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> getSubjects() async {
    subjects = await DbController.db.getAvailableSubjectsByDate(_selectedDate);
  }

  void refresh() {
    notifyListeners();
  }
}
