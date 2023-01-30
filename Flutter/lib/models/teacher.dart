import 'package:flutter_app/models/slot.dart';

class Teacher {
  String name;
  String email;
  String phone;
  String? imagePath;
  String description;

  Teacher(
      {required this.name,
      required this.email,
      required this.phone,
      required this.description,
      this.imagePath});

  Teacher.fromAvailableSlot(AvailableSlot slot)
      : name = slot.teacher.name,
        email = slot.teacher.email,
        phone = slot.teacher.phone,
        imagePath = slot.teacher.imagePath,
        description = slot.teacher.description;

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    return other is Teacher && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;
}
