import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/teacher_controller.dart';
import 'package:flutter_app/widgets/teacher_card.dart';
import 'package:provider/provider.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({Key? key}) : super(key: key);

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TeacherController(),
      child: Consumer<TeacherController>(
        builder: (context, controller, child) => FutureBuilder(
          future: controller.fetchTeachers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return (controller.teacherList.isNotEmpty)
                  ? RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: ListView.builder(
                        itemCount: controller.teacherList.length,
                        itemBuilder: (context, index) {
                          return TeacherCard(index);
                        },
                      ))
                  : const Center(child: Text("Nessun insegnante trovato"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
