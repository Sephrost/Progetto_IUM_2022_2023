import 'package:flutter_app/models/subject.dart';
import 'package:flutter_app/models/teacher.dart';
import 'package:intl/intl.dart';

class AvailableSlot {
  final DateTime _date;
  final DateTime _beginHour;
  final DateTime _endHour;
  final Teacher _teacher;
  final Subject _subject;

  AvailableSlot(
      {required int date,
      required String beginHour,
      required String endHour,
      required Teacher teacher,
      required Subject subject})
      : _date = DateTime(
            date ~/ 10000, // Year
            date ~/ 100 % 100, // Month
            date % 100), // Day
        _beginHour = DateFormat("HH:mm").parse(beginHour),
        _endHour = DateFormat("HH:mm").parse(endHour),
        _teacher = teacher,
        _subject = subject;

  @override
  bool operator ==(Object other) {
    return other is AvailableSlot &&
        other._date.day == _date.day &&
        other._date.month == _date.month &&
        other._date.year == _date.year &&
        other._beginHour.hour == _beginHour.hour &&
        other._beginHour.minute == _beginHour.minute &&
        other._endHour.hour == _endHour.hour &&
        other._endHour.minute == _endHour.minute &&
        other._teacher.email == _teacher.email &&
        other._subject.name == _subject.name;
  }

  // make getters
  DateTime get date => _date;
  String get dateAsString => DateFormat("dd/MM/yyyy").format(_date);
  String get dateForDbCart => DateFormat("yyyyMMdd").format(_date);
  DateTime get beginHour => _beginHour;
  String get beginHourAsString => DateFormat("HH:mm").format(_beginHour);
  DateTime get endHour => _endHour;
  String get endHourAsString => DateFormat("HH:mm").format(_endHour);
  Teacher get teacher => _teacher;
  Subject get subject => _subject;

  @override
  int get hashCode =>
      _date.day ^
      _date.month ^
      _date.year ^
      _beginHour.hour ^
      _beginHour.minute ^
      _endHour.hour ^
      _endHour.minute ^
      _teacher.email.hashCode ^
      _subject.name.hashCode;
}
