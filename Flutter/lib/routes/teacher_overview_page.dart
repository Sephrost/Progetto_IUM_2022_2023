import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/teacher_controller.dart';
import 'package:provider/provider.dart';

import '../themes/themes.dart';
import '../widgets/teacher_leading_icon.dart';

class TeacherOverviewPage extends StatefulWidget {
  const TeacherOverviewPage({Key? key, required this.index}) : super(key: key);

  final int index;
  final double _avatarRadius = 75;

  @override
  State<TeacherOverviewPage> createState() => _TeacherOverviewPageState();
}

class _TeacherOverviewPageState extends State<TeacherOverviewPage> {
  int _sliderValue = 0;
  late Map<int, dynamic> _sliderValues;

  String processWOL(String wol) => wol.replaceAll(RegExp(r'\. '), '.\n');

  @override
  void initState() {
    super.initState();
    _sliderValues = {
      0: "caricamento descrizione...",
      1: "caricamento materie...",
    };
  }

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeacherController>(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(primary: false, children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(controller.teacherList[widget.index].name.hashCode)
                    .withAlpha(0xFF),
              ),
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.2
                  : MediaQuery.of(context).size.height * 0.3,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -widget._avatarRadius,
              child: CircleAvatar(
                  radius: widget._avatarRadius,
                  backgroundColor:
                      Provider.of<ThemeChangerProvider>(context).darkTheme
                          ? Colors.grey[900]
                          : Colors.white,
                  child: TeacherLeadingIcon(widget.index,
                      radius: widget._avatarRadius - 2)),
            ),
          ],
        ),
        SizedBox(height: widget._avatarRadius + 5),
        Center(
          child: Text(controller.teacherList[widget.index].name,
              style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground)),
        ),
        const SizedBox(height: 10),
        Padding(
          // horizontal padding 10% of the screen width
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1),
          child: CupertinoSlidingSegmentedControl(
            groupValue: _sliderValue,
            children: const {
              0: Text('Descrizione'),
              1: Text('Materie insegnate'),
            },
            onValueChanged: (val) {
              setState(() {
                _sliderValue = val!;
              });
            },
          ),
        ),
        // const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _sliderValue == 0
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _buildDescription(context, 0, widget.index),
              secondChild: _buildSubject(context, 1, widget.index)),
        ),
      ]),
    );
  }

  Container _buildDescription(BuildContext context, int id, int index) {
    var controller = Provider.of<TeacherController>(context);
    return Container(
      width: MediaQuery.of(context).size.width - 8,
      decoration: BoxDecoration(
        color: Provider.of<ThemeChangerProvider>(context).darkTheme
            ? Colors.grey[900]
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          processWOL(controller.teacherList[index].description),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }

  FutureBuilder _buildSubject(BuildContext context, int id, int index) {
    var controller = Provider.of<TeacherController>(context);
    return FutureBuilder(
        future: controller.fetchSubjects(controller.teacherList[index].email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (controller.subjectList.isNotEmpty) {
              _sliderValues[id] = controller.subjectList;
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: controller.subjectList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Center(
                            child: Text(controller.subjectList[index].name)),
                        subtitle: controller.subjectList[index].description !=
                                ""
                            ? Center(
                                child: Text(
                                    controller.subjectList[index].description))
                            : null,
                      ),
                    );
                  });
            } else {
              return const Center(
                child: Text("Nessuna materia insegnata"),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
