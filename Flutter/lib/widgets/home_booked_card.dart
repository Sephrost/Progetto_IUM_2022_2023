import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/home_page_controller.dart';
import 'package:flutter_app/themes/themes.dart';
import 'package:provider/provider.dart';

/// The card that shows the booked lessons in the home page.
class HomeBookedCard extends StatelessWidget {
  const HomeBookedCard({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<HomePageController>(context);
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.prenotationsList[index].subject.name),
          ],
        ),
        subtitle:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: Theme.of(context).textTheme.bodyText2!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                  '${controller.prenotationsList[index].date.day.toString().padLeft(2, "0")}/${controller.prenotationsList[index].date.month.toString().padLeft(2, "0")}/${controller.prenotationsList[index].date.year} ${controller.prenotationsList[index].begin.hour.toString().padLeft(2, "0")}:${controller.prenotationsList[index].begin.minute.toString().padLeft(2, "0")} - ${controller.prenotationsList[index].end.hour..toString().padLeft(2, "0")}:${controller.prenotationsList[index].end.minute.toString().padLeft(2, "0")}'),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(controller.prenotationsList[index].teacher.name),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
