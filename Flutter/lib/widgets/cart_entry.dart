import 'package:flutter/material.dart';
import 'package:flutter_app/models/slot.dart';
import 'package:flutter_app/widgets/snackbar.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:provider/provider.dart';
import '../themes/themes.dart';

class CartEntry extends StatelessWidget {
  final AvailableSlot slot;

  const CartEntry({Key? key, required this.slot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: Text(slot.subject.name),
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
                  "${slot.dateAsString} - ${slot.beginHourAsString} - ${slot.endHourAsString}"),
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
              Text(slot.teacher.name),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
        ]),
        trailing: IconButton(
          onPressed: () {
            Provider.of<CartController>(context, listen: false)
                .removeFromCart(slot);
            ScaffoldMessenger.of(context).showSnackBar(AltSnackbar(
              type: AltSnackbarType.info,
              text: "Prenotazione rimossa dal carrello",
            ));
          },
          icon: const Icon(Icons.delete_forever_rounded),
        ),
      ),
    );
  }
}
