import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:flutter_app/controllers/history_filters_controller.dart';
import 'package:flutter_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';

import '../themes/themes.dart';

/// The widget used to display a single history entry.
class HistoryEntry extends StatelessWidget {
  /// The index of the entry in the list.
  /// The list is stored in the [HistoryFiltersController].
  final int index;

  const HistoryEntry({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<HistoryFiltersController>(context);
    String statusString = controller.history[index].status == 0
        ? "Attiva"
        : controller.history[index].status == 1
            ? "Disdetta"
            : "Effettuata";
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
          title: Text(controller.history[index].subject.name),
          subtitle:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: Theme.of(context).textTheme.bodyText2!.fontSize,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                    '${controller.history[index].date.day.toString().padLeft(2, "0")}/${controller.history[index].date.month.toString().padLeft(2, "0")}/${controller.history[index].date.year} ${controller.history[index].begin.hour.toString().padLeft(2, "0")}:${controller.history[index].begin.minute.toString().padLeft(2, "0")} - ${controller.history[index].end.hour..toString().padLeft(2, "0")}:${controller.history[index].end.minute.toString().padLeft(2, "0")}'),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: Theme.of(context).textTheme.bodyText1!.fontSize,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(controller.history[index].teacher.name),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
          ]),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: controller.history[index].status == 0
                        ? Colors.green.withOpacity(0.2)
                        : controller.history[index].status == 1
                            ? Colors.red.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusString,
                    style: TextStyle(
                        color: controller.history[index].status == 0
                            ? Colors.green
                            : controller.history[index].status == 1
                                ? Colors.red
                                : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          enabled: controller.history[index].status == 0 ? true : false,
          onTap: () {
            DateTime now = DateTime.now();
            DateTime endLession = DateTime(
                controller.history[index].date.year,
                controller.history[index].date.month,
                controller.history[index].date.day,
                controller.history[index].begin.hour,
                controller.history[index].begin.minute);

            showDialog(
                context: context,
                builder: (_) => ChangeNotifierProvider.value(
                    value: Provider.of<HistoryFiltersController>(context,
                        listen: false),
                    child: now.isAfter(endLession)
                        ? ConfirmPrenotationDialog(index: index)
                        : RemovePrenotationDialog(index: index)));
          }),
    );
  }
}

class RemovePrenotationDialog extends AlertDialog {
  final int index;

  const RemovePrenotationDialog({Key? key, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    var controller = Provider.of<HistoryFiltersController>(context);
    return AlertDialog(
      title: Text(controller.history[index].subject.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                  '${controller.history[index].date.day.toString().padLeft(2, "0")}/${controller.history[index].date.month.toString().padLeft(2, "0")}/${controller.history[index].date.year}'),
              const SizedBox(
                width: 5,
              ),
              Text(
                  '${controller.history[index].begin.hour.toString().padLeft(2, "0")}:${controller.history[index].begin.minute.toString().padLeft(2, "0")} - ${controller.history[index].end.hour..toString().padLeft(2, "0")}:${controller.history[index].end.minute.toString().padLeft(2, "0")}'),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(controller.history[index].teacher.name),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(controller.history[index].status == 0
                  ? "Attiva"
                  : controller.history[index].status == 1
                      ? "Disdetta"
                      : "Effettuata"),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text("Annulla prenotazione"),
                      content: const Text(
                          "Sei sicuro di voler annullare la prenotazione?"),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.transparent.withOpacity(0.2)
                                    : null,
                                shape: StadiumBorder(
                                    side: Provider.of<ThemeChangerProvider>(
                                                context)
                                            .darkTheme
                                        ? BorderSide.none
                                        : BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.25),
                                            width: 0.5,
                                          ))),
                            child: const Text("Annulla")),
                        ElevatedButton(
                          onPressed: () async {
                            bool result = await controller
                                .deleteFromHistory(controller.history[index]);
                            BookerRefreshController().refresh();
                            if (!mounted) return;
                            if (result) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  AltSnackbar(
                                      type: AltSnackbarType.success,
                                      text:
                                          "Prenotazione annullata con successo"));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  AltSnackbar(
                                      type: AltSnackbarType.error,
                                      text:
                                          "Errore durante l'annullamento della prenotazione"));
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.lerp(
                                Colors.red,
                                Theme.of(context).dialogBackgroundColor,
                                Provider.of<ThemeChangerProvider>(context)
                                        .darkTheme
                                    ? 0.35
                                    : 0.25)!,
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                          child: const Text(
                            "Conferma",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ));
          },
          style: TextButton.styleFrom(
            backgroundColor: Color.lerp(
                Colors.red,
                Theme.of(context).dialogBackgroundColor,
                Provider.of<ThemeChangerProvider>(context).darkTheme
                    ? 0.35
                    : 0.25)!,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: const Text(
            "Cancella",
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent.withOpacity(0.2)
                    : null,
                shape: StadiumBorder(
                    side: Provider.of<ThemeChangerProvider>(context).darkTheme
                        ? BorderSide.none
                        : BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.25),
                            width: 0.5,
                          ))),
            child: const Text("Chiudi")),
      ],
    );
  }
}

class ConfirmPrenotationDialog extends AlertDialog {
  final int index;

  const ConfirmPrenotationDialog({Key? key, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    var controller = Provider.of<HistoryFiltersController>(context);
    return AlertDialog(
      title: Text(controller.history[index].subject.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                  '${controller.history[index].date.day.toString().padLeft(2, '0')}/${controller.history[index].date.month.toString().padLeft(2, '0')}/${controller.history[index].date.year}'),
              const SizedBox(
                width: 5,
              ),
              Text(
                  '${controller.history[index].begin.hour.toString().padLeft(2, '0')}:${controller.history[index].begin.minute.toString().padLeft(2, '0')} - ${controller.history[index].end.hour.toString().padLeft(2, '0')}:${controller.history[index].end.minute.toString().padLeft(2, '0')}'),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(controller.history[index].teacher.name),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(controller.history[index].status == 0
                  ? "Attiva"
                  : controller.history[index].status == 1
                      ? "Disdetta"
                      : "Effettuata"),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text("Conferma prenotazione"),
                      content: const Text(
                          "Sei sicuro di voler confermare la prenotazione?"),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.transparent.withOpacity(0.2)
                                    : null,
                                shape: StadiumBorder(
                                    side: Provider.of<ThemeChangerProvider>(
                                                context)
                                            .darkTheme
                                        ? BorderSide.none
                                        : BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.25),
                                            width: 0.5,
                                          ))),
                            child: const Text("Annulla")),
                        ElevatedButton(
                          onPressed: () async {
                            bool result = await controller
                                .confirmPrenotation(controller.history[index]);
                            BookerRefreshController().refresh();
                            if (!mounted) return;
                            if (result) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  AltSnackbar(
                                      type: AltSnackbarType.success,
                                      text:
                                          "Prenotazione confermata con successo"));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  AltSnackbar(
                                      type: AltSnackbarType.error,
                                      text:
                                          "Errore durante la conferma della prenotazione"));
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.lerp(
                                Colors.green,
                                Theme.of(context).dialogBackgroundColor,
                                Provider.of<ThemeChangerProvider>(context)
                                        .darkTheme
                                    ? 0.35
                                    : 0.15)!,
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                          child: const Text(
                            "Conferma",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ));
          },
          style: TextButton.styleFrom(
            backgroundColor: Color.lerp(
                Colors.green,
                Theme.of(context).dialogBackgroundColor,
                Provider.of<ThemeChangerProvider>(context).darkTheme
                    ? 0.35
                    : 0.15)!,
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: const Text(
            "Conferma",
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent.withOpacity(0.2)
                    : null,
                shape: StadiumBorder(
                    side: Provider.of<ThemeChangerProvider>(context).darkTheme
                        ? BorderSide.none
                        : BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.25),
                            width: 0.5,
                          ))),
            child: const Text("Chiudi")),
      ],
    );
  }
}
