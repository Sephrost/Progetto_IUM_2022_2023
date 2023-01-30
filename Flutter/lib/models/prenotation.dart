import 'package:flutter_app/models/subject.dart';
import 'package:flutter_app/models/teacher.dart';
import 'package:intl/intl.dart';

class Prenotation {
  final DateTime begin;
  final DateTime end;
  final DateTime date;
  final int status;
  final Teacher teacher;
  final Subject subject;

  Prenotation(
      {required String begin,
      required String end,
      required int date,
      required this.status,
      required this.teacher,
      required this.subject})
      : begin = DateFormat("HH:mm").parse(begin.toString()),
        end = DateFormat("HH:mm").parse(end.toString()),
        date = DateTime(
            date ~/ 10000, // Year
            date ~/ 100 % 100, // Month
            date % 100), // Day
        assert(DateFormat("HH:mm")
            .parse(begin.toString())
            .isBefore(DateFormat("HH:mm").parse(end.toString())));

  String get dateAsString =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String toString(Prenotation prenotation) {
  return "Prenotation: ${prenotation.date} ${prenotation.begin} - ${prenotation.end} ${prenotation.status} ${prenotation.teacher} ${prenotation.subject}";
}
