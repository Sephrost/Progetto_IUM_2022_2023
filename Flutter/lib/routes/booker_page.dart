import 'package:flutter/material.dart';
import 'package:flutter_app/routes/calendar_subpage.dart';
import 'package:flutter_app/routes/teacher_subpage.dart';

class BookerPage extends StatelessWidget {
  const BookerPage({super.key});

  static const List<Widget> _tabs = [
    CalendarPage(),
    TeacherPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              labelColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: Theme.of(context).textTheme.bodyText1!.fontSize,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text('Calendario'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: Theme.of(context).textTheme.bodyText1!.fontSize,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text('Insegnanti'),
                    ],
                  ),
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: _tabs,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
