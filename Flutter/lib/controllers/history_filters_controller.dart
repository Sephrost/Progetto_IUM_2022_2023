import 'package:flutter/material.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/models/prenotation.dart';
import 'package:flutter_app/models/subject.dart';
import 'package:flutter_app/models/teacher.dart';
import 'package:flutter_app/models/history_filters.dart';

/// The controller used to manage the history of the user.
class HistoryFiltersController extends ChangeNotifier {
  final HistoryFilters _filters = HistoryFilters();
  List<Prenotation> history = [];
  List<Subject> subjectsList = [];
  List<Teacher> teachersList = [];

  Future<void> fetchHistory() async {
    history = await DbController.db.getFilteredUserPrenotations(
        _filters.subjects,
        _filters.teachers,
        _filters.startDate,
        _filters.endDate,
        _filters.booked,
        _filters.completed,
        _filters.cancelled);
  }

  set subjects(List<String> subjects) {
    _filters.subjects = subjects;
    refresh();
  }

  set teachers(List<String> teachers) {
    _filters.teachers = teachers;
    refresh();
  }

  set startDate(String startDate) {
    _filters.startDate = startDate;
    refresh();
  }

  set endDate(String endDate) {
    _filters.endDate = endDate;
    refresh();
  }

  set booked(bool booked) {
    _filters.booked = booked;
    refresh();
  }

  set completed(bool completed) {
    _filters.completed = completed;
    refresh();
  }

  set cancelled(bool cancelled) {
    _filters.cancelled = cancelled;
    refresh();
  }

  Future<void> refresh() async {
    notifyListeners();
  }

  Future<bool> deleteFromHistory(Prenotation entry) async {
    bool success = await DbController.db.deletePrenotation(entry);
    if (success) {
      return true;
    }
    return false;
  }

  Future<bool> confirmPrenotation(Prenotation entry) async {
    bool success = await DbController.db.confirmPrenotation(entry);
    if (success) {
      refresh();
      return true;
    }
    return false;
  }

  Future<void> fetchTeachers() async {
    subjectsList = await DbController.db.getSubjects();
  }

  Future<void> fetchSubjects() async {
    teachersList = await DbController.db.getTeachers();
  }
}
