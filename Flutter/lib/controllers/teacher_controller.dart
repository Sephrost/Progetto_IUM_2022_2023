import 'package:flutter/foundation.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/models/slot.dart';
import 'package:flutter_app/models/subject.dart';
import 'package:flutter_app/models/teacher.dart';

/// The controller used to manage the teacher page and get
/// the teachers available.
class TeacherController extends ChangeNotifier {
  /// The list of the teachers available
  List<Teacher> teacherList = [];
  List<Subject> subjectList = [];
  List<AvailableSlot> slotList = [];

  Future<void> fetchTeachers() async {
    teacherList = await DbController.db.getTeachers();
  }

  Future<void> fetchSlots(int index) async {
    slotList = await DbController.db.getSlotsbyTeacher(teacherList[index]);
  }

  Future<void> fetchSubjects(String email) async {
    subjectList = await DbController.db.getTeacherSubjects(email);
  }
}
