import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/themes/themes.dart';
import 'package:flutter_app/widgets/bottom_sheet_prenotation_selector.dart';
import 'package:flutter_app/widgets/week_calendar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/controllers/calendar_controller.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int todayDate = DateTime.now().weekday;
    DateTime currentDay = DateTime.now().subtract(
        Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute));
    DateTime selectedDate = todayDate < 6
        ? DateTime.now()
        : (todayDate == 6)
            ? currentDay.subtract(const Duration(days: 1))
            : currentDay.subtract(const Duration(days: 2));
    return ChangeNotifierProvider(
        create: (context) => CalendarController(),
        child: Column(
          children: [
            WeekCalendar(selectedDate: selectedDate),
            const Expanded(child: _FilteredListView()),
          ],
        ));
  }
}

class _FilteredListView extends StatelessWidget {
  const _FilteredListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3(builder: (context,
        CalendarController controller,
        CartController cartController,
        BookerRefreshController refreshController,
        child) {
      return FutureBuilder(
          future: controller.getSubjects(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return RefreshIndicator(
                  onRefresh: () async {
                    controller.refresh();
                  },
                  child: controller.subjects.isNotEmpty
                      ? ListView.builder(
                          itemCount: controller.subjects.length,
                          itemBuilder: (context, index) {
                            return _AvailableSubjectCard(
                              index: index,
                            );
                          },
                        )
                      : const CustomScrollView(slivers: [
                          SliverFillRemaining(
                            child: Center(
                              child: Text('Nessuna ripetizione disponibile'),
                            ),
                          )
                        ]));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          });
    });
  }
}

/// The card to display the available subjects in the calendar
class _AvailableSubjectCard extends StatelessWidget {
  /// The index of the element to fetch from the controller's list
  final int index;

  /// The card to display the available subjects in the calendar
  ///
  /// [subjectName] The subject name to display
  const _AvailableSubjectCard({Key? key, required this.index})
      : super(key: key);

  void _onTap(BuildContext context, DateTime selectedDate,
      CalendarController controller) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => ChangeNotifierProvider<CalendarController>.value(
            value: controller,
            child: BottomSheetPrenotationSelector(
                subjectIndex: index, selectedDate: selectedDate)));
  }

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<CalendarController>(context);
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: Provider.of<ThemeChangerProvider>(context).darkTheme
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.25),
                  width: 0.5,
                )),
      child: ListTile(
        title: Text(controller.subjects[index].name),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _onTap(
            context,
            Provider.of<CalendarController>(context, listen: false)
                .selectedDate,
            Provider.of<CalendarController>(context, listen: false)),
      ),
    );
  }
}
