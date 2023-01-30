import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_controller.dart';
import 'package:flutter_app/controllers/calendar_controller.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/models/hour_slot.dart';
import 'package:flutter_app/models/prenotation.dart';
import 'package:flutter_app/models/slot.dart';
import 'package:flutter_app/models/subject.dart';
import 'package:flutter_app/models/teacher.dart';
import 'package:provider/provider.dart';

/// The class to rappresent what to show on the modal bottom bar
/// to select the teaccher and the hour slot
class BottomSheetPrenotationSelector extends StatelessWidget {
  /// The date selected
  final DateTime selectedDate;

  /// The index of the subject in the list of subjects stored in the [CalendarController]
  final int subjectIndex;

  /// The modal bottom bar widget from which the user can select the teacher and
  /// the hour slot
  ///
  /// N.B. This is only the widget to use in a builder of a showModalBottomSheet
  /// function. The widget is not a modal bottom bar itself.
  const BottomSheetPrenotationSelector(
      {Key? key, required this.subjectIndex, required this.selectedDate})
      : super(key: key);

  /// The function associated to the button to add the prenotation to the cart
  /// and to close the modal bottom bar
  ///
  /// It checks if the user is logged in and if the teacher and the hour slot
  /// are selected. If not, it shows a Flash to inform the user.
  void _addToCart(BuildContext context, [bool mounted = true]) async {
    if (LoginController().status == AutehticationStatus.authenticated) {
      if (Provider.of<BookerController>(context, listen: false)
              .selectedTimeSlot ==
          null) {
        showFlash(
            duration: const Duration(seconds: 3),
            context: context,
            builder: (context, controller) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flash(
                    behavior: FlashBehavior.floating,
                    position: FlashPosition.top,
                    backgroundColor: const Color.fromRGBO(232, 145, 72, 0.8),
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.all(8),
                    controller: controller,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 10),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded),
                          SizedBox(width: 8),
                          Text("Selezionare un orario"),
                        ],
                      ),
                    )),
              );
            });
        return;
      }
      if (Provider.of<BookerController>(context, listen: false)
              .selectedTeacher ==
          null) {
        showFlash(
            duration: const Duration(seconds: 3),
            context: context,
            builder: (context, controller) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flash(
                    behavior: FlashBehavior.floating,
                    position: FlashPosition.top,
                    backgroundColor: const Color.fromRGBO(232, 145, 72, 0.8),
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.all(8),
                    controller: controller,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 10),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded),
                          SizedBox(width: 8),
                          Text("Selezionare un docente"),
                        ],
                      ),
                    )),
              );
            });
        return;
      }
      var cartcontroller = Provider.of<CartController>(context, listen: false);
      List<AvailableSlot> cartContent = cartcontroller.cart;
      DateTime date = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, 0, 0, 0, 0, 0);
      // If there are already prenotations for the same subject in the cart for the same day,
      // same timeslot show a flash to inform the user
      var intersectList = cartContent
          .where((element) =>
              element.date == date &&
              AvailableHourSlot.fromAvailableSlot(element) ==
                  Provider.of<BookerController>(context, listen: false)
                      .selectedTimeSlot)
          .toList();
      if (intersectList.isNotEmpty) {
        showFlash(
            duration: const Duration(seconds: 3),
            context: context,
            builder: (context, controller) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flash(
                    behavior: FlashBehavior.floating,
                    position: FlashPosition.top,
                    backgroundColor: const Color.fromRGBO(232, 145, 72, 0.8),
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.all(8),
                    controller: controller,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 10),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded),
                          SizedBox(width: 8),
                          Text(
                              "Hai già una prenotazione per quell'orario nel carrello"),
                        ],
                      ),
                    )),
              );
            });
        return;
      }

      var userPrenotation =
          await DbController.db.getUserPrenotations(LoginController.user);
      userPrenotation = userPrenotation
          .where((element) => element.status == 0 || element.status == 2)
          .toList();
      if (!mounted) return;
      // If there are already prenotation for the same date and timeslot in the database,
      // show a flash to inform the user
      List<Prenotation> intersectList2 = userPrenotation
          .where((element) =>
              element.date == date &&
              AvailableHourSlot(
                    beginHour:
                        '${element.begin.hour.toString().padLeft(2, '0')}:00',
                    endHour:
                        '${element.end.hour.toString().padLeft(2, '0')}:00',
                  ) ==
                  Provider.of<BookerController>(context, listen: false)
                      .selectedTimeSlot)
          .toList();
      if (intersectList2.isNotEmpty) {
        showFlash(
            duration: const Duration(seconds: 3),
            context: context,
            builder: (context, controller) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flash(
                    behavior: FlashBehavior.floating,
                    position: FlashPosition.top,
                    backgroundColor: const Color.fromRGBO(232, 145, 72, 0.8),
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.all(8),
                    controller: controller,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 10),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded),
                          SizedBox(width: 8),
                          Text("Hai già una prenotazione per quell'orario"),
                        ],
                      ),
                    )),
              );
            });
        return;
      }

      var bookerController =
          Provider.of<BookerController>(context, listen: false);
      bookerController.addToCart(
          context,
          Provider.of<CalendarController>(context, listen: false)
              .subjects[subjectIndex],
          selectedDate);
      Navigator.pop(context);
    } else {
      showFlash(
          duration: const Duration(seconds: 3),
          context: context,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flash(
                  behavior: FlashBehavior.floating,
                  position: FlashPosition.top,
                  backgroundColor: const Color.fromRGBO(80, 147, 209, 0.8),
                  borderRadius: BorderRadius.circular(8),
                  margin: const EdgeInsets.all(8),
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 10),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text("Effettua il login per prenotare"),
                      ],
                    ),
                  )),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var fontSize = Theme.of(context).textTheme.bodyText1!.fontSize;
    TextStyle boldTextStyle =
        TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500);
    var calendarController = Provider.of<CalendarController>(context);

    /// The flag to check if the user is authenticated.
    /// N.B. A guest user is NOT authenticated
    bool isAuth = LoginController().status == AutehticationStatus.authenticated;
    DateTime now = DateTime.now();
    bool validDate =
        selectedDate.isAfter(DateTime(now.year, now.month, now.day + 1));
    return Container(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: ChangeNotifierProvider(
          create: (context) => BookerController(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Selezionare Orario e Docente",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                textScaleFactor: 1.5,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: fontSize,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text("Orario", style: boldTextStyle),
                  const SizedBox(
                    width: 10,
                  ),
                  Consumer<BookerController>(
                      builder: (context, BookerController controller, child) =>
                          _DropDownSelector<AvailableHourSlot>(
                            subjectIndex: subjectIndex,
                            selectedDate: selectedDate,
                            label: "Orario",
                            fetchData: controller.getAvailableHourSlots,
                            updateControllerValue: ((value) {
                              controller.selectedTimeSlot = value;
                            }),
                            fetchOtherData: () =>
                                controller.getAvailableTeachers(
                                    Provider.of<CartController>(context,
                                            listen: false)
                                        .cart,
                                    calendarController.subjects[subjectIndex],
                                    selectedDate),
                          ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: fontSize,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text("Docente", style: boldTextStyle),
                  const SizedBox(
                    width: 10,
                  ),
                  Consumer<BookerController>(
                      builder: (context, BookerController controller, child) =>
                          _DropDownSelector<Teacher>(
                            subjectIndex: subjectIndex,
                            selectedDate: selectedDate,
                            label: "Docente",
                            fetchData: controller.getAvailableTeachers,
                            updateControllerValue: ((value) {
                              controller.selectedTeacher = value;
                            }),
                            fetchOtherData: () =>
                                controller.getAvailableHourSlots(
                                    Provider.of<CartController>(context,
                                            listen: false)
                                        .cart,
                                    calendarController.subjects[subjectIndex],
                                    selectedDate),
                          ))
                ],
              ),
              const SizedBox(
                height: 9,
              ),
              Consumer<BookerController>(
                  builder: (context, BookerController controller, child) =>
                      ElevatedButton(
                        onPressed: isAuth && validDate
                            ? () => _addToCart(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? MediaQuery.of(context).size.width * 0.5
                                  : MediaQuery.of(context).size.width * 0.9,
                              50),
                          side: isAuth && validDate
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.2)
                              : null,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          elevation: 0,
                        ),
                        child: isAuth && !validDate
                            ? const Text("Prenotazione non piú disponibile")
                            : isAuth
                                ? const Text("Aggiungi al Carrello")
                                : const Text("Effettua il login per prenotare"),
                      ))
            ],
          ),
        ));
  }
}

/// This class is used to create a formatted row with a gesture detector
/// that show a modal bottom sheet with the list of the values.
/// The list of values is fetched by the [fetchData] function.
/// The [updateControllerValue] function is used to update the controller value
/// when the user select a value from the list.
///
/// The modal bottom sheet shown is a [BottomSheetSelector] of the same type
/// of this class.
class _DropDownSelector<T> extends StatelessWidget {
  final DateTime selectedDate;

  /// The index of the subject stored in the [CalendarController]
  final int subjectIndex;

  /// The reference of the value that will be set and chacked in the controller
  final String label;
  final Future<void> Function(
          List<AvailableSlot> cartContent, Subject subject, DateTime date)
      fetchData;

  /// We need to update the other value before fetching the data, this is
  /// needed  because if we only have one value available we can show
  /// directly the value as not updatable to avoid useless interaction.
  final Future<void> Function() fetchOtherData;
  // function to update the controller value
  final void Function(T value)? updateControllerValue;
  const _DropDownSelector(
      {Key? key,
      required this.subjectIndex,
      required this.selectedDate,
      required this.fetchData,
      required this.label,
      required this.updateControllerValue,
      required this.fetchOtherData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<BookerController>(context);
    var calendarController = Provider.of<CalendarController>(context);
    return FutureBuilder(
        future: fetchOtherData(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FutureBuilder(
                future: fetchData(Provider.of<CartController>(context).cart,
                    calendarController.subjects[subjectIndex], selectedDate),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (controller.getListValueFromType(T).isEmpty) {
                      // should never occour
                      return Text("Nessun ${label.toLowerCase()} disponibile");
                    }
                    return controller.getListValueFromType(T).length > 1
                        ? GestureDetector(
                            onTap: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        ChangeNotifierProvider.value(
                                            value: controller,
                                            child: BottomSheetSelector<T>(
                                                label))).then((value) {
                                  if (value != null) {
                                    updateControllerValue!(value);
                                  }
                                }),
                            child: Row(children: [
                              Text(
                                controller.getValueFromType(T) != null
                                    ? controller.getValueFromType(T).toString()
                                    : "Selezionare ${label.toLowerCase()}",
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .fontSize,
                                  color: controller.getValueFromType(T) == null
                                      ? Colors.grey[400]
                                      : null,
                                  // fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                              )
                            ]))
                        : Text(controller.getListValueFromType(T)[0].toString(),
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .fontSize,
                            ));
                  } else {
                    return Text("caricamento...",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyText1!.fontSize,
                          // fontWeight: FontWeight.w500,
                        ));
                  }
                });
          } else {
            return Text("caricamento...",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                  // fontWeight: FontWeight.w500,
                ));
          }
        });
  }
}

class BottomSheetSelector<T> extends StatefulWidget {
  final String label;

  const BottomSheetSelector(this.label, {Key? key}) : super(key: key);

  @override
  State<BottomSheetSelector> createState() => _BottomSheetSelectorState<T>();
}

class _BottomSheetSelectorState<T> extends State<BottomSheetSelector<T>> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<BookerController>(context);
    T? selectedItem = controller.getValueFromType(T);
    return SizedBox(
        // MediaQuery.of(context).viewPadding.top is set to zero by the
        // safearea, so we use the padding in physical pixels divided by the
        // pixel ratio to get the height in logical pixels that should have been
        // returned
        height: MediaQuery.of(context).size.height -
            WidgetsBinding.instance.window.padding.top /
                WidgetsBinding.instance.window.devicePixelRatio,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.label,
                        style: Theme.of(context).textTheme.headline6),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))
                  ],
                )),
            const Divider(
              thickness: 1.5,
            ),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Filtra ${widget.label.toLowerCase()}',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 16.0)),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
            Divider(
              thickness: 1.5,
              color: Theme.of(context).colorScheme.outline,
            ),
            Expanded(
              child: ListView.builder(
                  primary: false,
                  itemCount: controller.getListValueFromType(T).length,
                  itemBuilder: (context, index) {
                    final item = controller.getListValueFromType(T)[index];
                    // This class use the toString method to show the value,
                    // If anything goes wrong, check this.
                    if (item.toString().toLowerCase().contains(query)) {
                      return ListTile(
                        leading: Radio<T>(
                          value: item,
                          groupValue: selectedItem,
                          onChanged: (T? value) {
                            setState(() {
                              selectedItem = value as T;
                              Navigator.pop(context, selectedItem);
                            });
                          },
                        ),
                        title: Text(item.toString()),
                        onTap: () {
                          setState(() {
                            selectedItem = item;
                            Navigator.pop(context, selectedItem);
                          });
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
            ),
          ],
        ));
  }
}
