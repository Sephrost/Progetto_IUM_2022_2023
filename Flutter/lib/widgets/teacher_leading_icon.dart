import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/teacher_controller.dart';
import 'package:provider/provider.dart';
import '../themes/themes.dart';

class TeacherLeadingIcon extends StatelessWidget {
  final int index;
  final double? radius;
  const TeacherLeadingIcon(this.index, {Key? key, this.radius})
      : super(key: key);

  Color _getColor(String name) {
    return Color(name.hashCode).withAlpha(0xFF);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TeacherController>(context);
    return (controller.teacherList[index].imagePath != null)
        ? CircleAvatar(
            radius: radius,
            backgroundImage:
                NetworkImage(controller.teacherList[index].imagePath!),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: _getColor(controller.teacherList[index].name),
            child: FittedBox(
                child: Text(
              controller.teacherList[index].name
                  .split(' ')
                  .map((e) => e[0])
                  .take(3)
                  .join(),
              style: TextStyle(
                color: Provider.of<ThemeChangerProvider>(context).darkTheme
                    ? Colors.grey[900]
                    : Colors.white,
              ),
            )));
  }
}
