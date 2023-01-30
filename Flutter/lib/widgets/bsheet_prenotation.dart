// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/controllers/teacher_controller.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/models/slot.dart';
import 'package:flutter_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';

// NB: this class DOES NOT invoke the showModalBottomSheet function
// It is only used to create the widget that will be shown in the bottom sheet

class BottomSheetPrenotationConfirm extends StatelessWidget {
  final int index;

  /// This class is used to show the bottom sheet when the user taps on a
  /// available rep in the available rep list page or in the calendar page
  BottomSheetPrenotationConfirm(this.index, {Key? key}) : super(key: key);

  void _confirmPrenotation(BuildContext context, [bool mounted = true]) async {
    if (LoginController().status == AutehticationStatus.authenticated) {
      var cartcontroller = Provider.of<CartController>(context, listen: false);
      List<AvailableSlot> cartContent = cartcontroller.cart;
      var selectedSlot = Provider.of<TeacherController>(context, listen: false)
          .slotList[index];
      // If there are already prenotations for the same subject in the cart for the same day,
      // same timeslot show a flash to inform the user
      var intersectList = cartContent
          .where((element) =>
              element.date == selectedSlot.date &&
              element.beginHourAsString == selectedSlot.beginHourAsString &&
              element.endHourAsString == selectedSlot.endHourAsString)
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
                              "C'è già una prenotazione per quell'orario nel carrello"),
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
      var intersectList2 = userPrenotation
          .where((element) =>
              element.date == selectedSlot.date &&
              '${element.begin.hour.toString().padLeft(2, '0')}:00' ==
                  selectedSlot.beginHourAsString &&
              '${element.end.hour.toString().padLeft(2, '0')}:00' ==
                  selectedSlot.endHourAsString)
          .toList();
      intersectList2 = intersectList2
          .where((element) => element.status == 0 || element.status == 2)
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
      Provider.of<CartController>(context, listen: false).addToCart(
          Provider.of<TeacherController>(context, listen: false)
              .slotList[index]);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
          type: AltSnackbarType.error,
          text: "Effettua il login per prenotare"));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuth =
        LoginController().status == AutehticationStatus.authenticated;
    final slot = Provider.of<TeacherController>(context).slotList[index];
    DateTime now = DateTime.now();
    final validDate = slot.date.isAfter(DateTime(now.year, now.month, now.day));

    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      width: MediaQuery.of(context).orientation == Orientation.landscape
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Confermare prenotazione?",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_outlined,
                size: Theme.of(context).textTheme.bodyText2!.fontSize,
              ),
              Text(
                slot.subject.name,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: Theme.of(context).textTheme.bodyText2!.fontSize,
              ),
              Text(
                slot.teacher.name,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: Theme.of(context).textTheme.bodyText2!.fontSize,
              ),
              const SizedBox(width: 2),
              Text(
                slot.dateAsString,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.access_time,
                size: Theme.of(context).textTheme.bodyText2!.fontSize,
              ),
              const SizedBox(width: 2),
              Text("${slot.beginHourAsString} - ${slot.endHourAsString}",
                  style: Theme.of(context).textTheme.bodyText2),
            ],
          ),
          const SizedBox(height: 7),
          ElevatedButton(
            onPressed:
                isAuth && validDate ? () => _confirmPrenotation(context) : null,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.9,
                  50),
              side: isAuth && validDate
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 1.2)
                  : null,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
            ),
            child: isAuth && validDate
                ? const Text("Aggiungi al Carrello")
                : isAuth && !validDate
                    ? const Text("Prenotazione non piú disponibile")
                    : const Text("Effettua il login per prenotare"),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
