import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/teacher_controller.dart';
import 'package:provider/provider.dart';

import '../themes/themes.dart';
import 'bsheet_prenotation.dart';

class AvailableSlotCard extends StatelessWidget {
  /// The index of the slot stored in the TeacherController
  final int index;

  const AvailableSlotCard(this.index, {Key? key}) : super(key: key);

  void _showConfirmBottomSheet(BuildContext context, controller) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => ChangeNotifierProvider<TeacherController>.value(
            value: controller, child: BottomSheetPrenotationConfirm(index)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TeacherController>(context);
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
          title: Text(
            controller.slotList[index].subject.name,
            textAlign: TextAlign.center,
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              Text(
                " ${controller.slotList[index].dateAsString}",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                ' | ',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.access_time,
                size: Theme.of(context).textTheme.bodyText1!.fontSize,
              ),
              Text(
                " ${controller.slotList[index].beginHourAsString} - ${controller.slotList[index].endHourAsString}",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          onTap: () => _showConfirmBottomSheet(context, controller)),
    );
  }
}
