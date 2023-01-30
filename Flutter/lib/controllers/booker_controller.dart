import 'package:flutter/material.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/models/hour_slot.dart';
import 'package:flutter_app/models/slot.dart';
import 'package:flutter_app/models/subject.dart';
import 'package:flutter_app/models/teacher.dart';
import 'package:provider/provider.dart';

import 'cart_controller.dart';

/// This controller is used to manage the booking process.
/// It's used to select the teacher, the time slot and the subject.
class BookerController extends ChangeNotifier {
  Teacher? _selectedTeacher;
  AvailableHourSlot? _selectedTimeSlot;
  List<Teacher> _teachers = [];
  List<AvailableHourSlot> _timeSlots = [];

  Teacher? get selectedTeacher => _selectedTeacher;
  AvailableHourSlot? get selectedTimeSlot => _selectedTimeSlot;
  List<Teacher> get teachers => _teachers;
  List<AvailableHourSlot> get timeSlots => _timeSlots;

  getValueFromType(Type type) {
    switch (type) {
      case Teacher:
        return _selectedTeacher;
      case AvailableHourSlot:
        return _selectedTimeSlot;
      default:
        return null;
    }
  }

  /// This method is used to get the selected value from the type.
  /// This is because the UI is generic and it's used to select both the teacher and the time slot.
  getListValueFromType(Type type) {
    switch (type) {
      case Teacher:
        return _teachers;
      case AvailableHourSlot:
        return _timeSlots;
      default:
        return null;
    }
  }

  AvailableSlot getSlot(Subject subject, DateTime date) {
    // cast Date to int in format YYYYMMDD
    int dateInt = int.parse(
        "${date.year}${date.month.toString().padLeft(2, "0")}${date.day.toString().padLeft(2, "0")}");
    return AvailableSlot(
        subject: subject,
        teacher: _selectedTeacher!,
        date: dateInt,
        beginHour: _selectedTimeSlot!.beginHour,
        endHour: _selectedTimeSlot!.endHour);
  }

  set selectedTeacher(Teacher? teacher) {
    _selectedTeacher = teacher;
    notifyListeners();
  }

  set selectedTimeSlot(AvailableHourSlot? slot) {
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  Future<void> getAvailableHourSlots(
      List<AvailableSlot> cartContent, Subject subject, DateTime date) async {
    List<AvailableSlot> list = await DbController.db
        .getAvailableSlots(subject, date, _selectedTeacher);

    for (var slot in cartContent) {
      list.remove(slot);
    }

    if (list.length == 1) {
      _selectedTimeSlot = AvailableHourSlot.fromAvailableSlot(list[0]);
    }

    List<AvailableHourSlot> hourSlots = [];
    for (var slot in list) {
      hourSlots.add(AvailableHourSlot.fromAvailableSlot(slot));
    }

    _timeSlots = hourSlots.toSet().toList();
  }

  Future<void> getAvailableTeachers(
      List<AvailableSlot> cartContent, Subject subject, DateTime date) async {
    List<AvailableSlot> list = await DbController.db
        .getAvailableTeachersSlot(subject, date, _selectedTimeSlot);

    for (var slot in cartContent) {
      list.remove(slot);
    }

    List<Teacher> teachers = [];
    for (var slot in list) {
      teachers.add(slot.teacher);
    }

    if (list.length == 1) _selectedTeacher = teachers[0];
    _teachers = teachers.toSet().toList();
  }

  void addToCart(BuildContext context, Subject subject, DateTime date) {
    assert(_selectedTeacher != null && _selectedTimeSlot != null);
    Provider.of<CartController>(context, listen: false)
        .addToCart(getSlot(subject, date));
  }
}
