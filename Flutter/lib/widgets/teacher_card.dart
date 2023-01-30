import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/teacher_controller.dart';
import 'package:flutter_app/widgets/teacher_leading_icon.dart';
import 'package:provider/provider.dart';

import '../routes/teacher_slots_page.dart';

///The Card userd in the theacher booker page to show the teachers
class TeacherCard extends StatelessWidget {
  /// The index of the teacher assigned that will be retreived
  final int index;

  /// The card used in the teacher booker page to show the teachers
  const TeacherCard(this.index, {Key? key}) : super(key: key);

  void _onTap(context, controller) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider<TeacherController>.value(
        value: controller,
        child: TheacherSlotsPage(index: index),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TeacherLeadingIcon(index),
          ],
        ),
        title: Text(
            Provider.of<TeacherController>(context).teacherList[index].name),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _onTap(
          context,
          Provider.of<TeacherController>(context, listen: false),
        ),
      ),
    );
  }
}
