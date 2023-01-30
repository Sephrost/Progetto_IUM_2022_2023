import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/controllers/teacher_controller.dart';
import 'package:flutter_app/routes/material_page_route_alt.dart';
import 'package:flutter_app/routes/teacher_overview_page.dart';
import 'package:provider/provider.dart';

import '../widgets/available_slot_card.dart';

class TheacherSlotsPage extends StatefulWidget {
  final int index;
  const TheacherSlotsPage({Key? key, required this.index}) : super(key: key);

  @override
  State<TheacherSlotsPage> createState() => _TheacherSlotsPageState();
}

class _TheacherSlotsPageState extends State<TheacherSlotsPage> {
  @override
  Widget build(BuildContext context) {
    var teacherController = Provider.of<TeacherController>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(teacherController.teacherList[widget.index].name),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRouteAlt(
                        builder: (context) =>
                            ChangeNotifierProvider<TeacherController>.value(
                              value: teacherController,
                              child: TeacherOverviewPage(index: widget.index),
                            ),
                        fromDirection: AxisDirection.left,
                        transitionDuration: const Duration(milliseconds: 350)));
              },
              icon: const Icon(Icons.info_outline),
            )
          ],
          backgroundColor: Colors.transparent,
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Consumer<CartController>(
                builder: (context, CartController controller, child) =>
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: FutureBuilder(
                        future: teacherController.fetchSlots(widget.index),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return teacherController.slotList.isNotEmpty
                                ? KeyedSubtree(
                                    key: ValueKey(snapshot.data),
                                    child: ListView.builder(
                                      itemCount:
                                          teacherController.slotList.length,
                                      itemBuilder: (context, index) {
                                        return AvailableSlotCard(index);
                                      },
                                    ),
                                  )
                                : const CustomScrollView(slivers: [
                                    SliverFillRemaining(
                                      child: Center(
                                        child: Text(
                                            'Nessuno slot disponibile per questo docente'),
                                      ),
                                    )
                                  ]);
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ))));
  }
}
