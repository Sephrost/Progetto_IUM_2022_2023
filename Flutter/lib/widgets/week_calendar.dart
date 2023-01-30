import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/calendar_controller.dart';

class WeekCalendar extends StatefulWidget {
  final DateTime selectedDate;
  static const List<String> _weekDays = [
    'Lun',
    'Mar',
    'Mer',
    'Gio',
    'Ven',
    'Sab',
    'Dom',
  ];

  const WeekCalendar({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  DateTime getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _onTapDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      // update the selected date in the controller
      Provider.of<CalendarController>(context, listen: false)
          .setSelectedDate(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // Limit the width of the calendar to 500
    // because it looks better on bigger screens
    screenWidth = min(screenHeight, min(screenWidth, 500));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          5,
          (index) {
            final date =
                getFirstDayOfWeek(_selectedDate).add(Duration(days: index));
            return GestureDetector(
              onTap: () => _onTapDay(date),
              child: AnimatedContainer(
                width:
                    screenWidth * 0.1428, // Magic number to have a nice rateo
                decoration: BoxDecoration(
                  color: date == _selectedDate
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.95)
                      : Colors.transparent,
                  border: date == _selectedDate
                      ? Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.35),
                          width: 2,
                        )
                      : Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.25),
                          width: 1,
                        ),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withOpacity(0.15),
                      blurRadius: 3,
                      blurStyle: BlurStyle.outer,
                      offset: const Offset(0, 0.4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(
                    left: 4, top: 10, right: 4, bottom: 8),
                duration: const Duration(milliseconds: 300),
                curve: const Cubic(0.4, 0.0, 0.2, 1),
                child: SizedBox(
                  height: 70,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          WeekCalendar._weekDays[index],
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
