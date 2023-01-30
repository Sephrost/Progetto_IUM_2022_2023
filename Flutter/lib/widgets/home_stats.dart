import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:flutter_app/controllers/home_page_controller.dart';
import 'package:provider/provider.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class HomeStats extends StatelessWidget {
  const HomeStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomePageController, BookerRefreshController>(
      builder: (context, homePageController, bookerRefreshController, child) =>
          FutureBuilder(
              future: homePageController.fetchStats(),
              builder: (context, snapshot) => snapshot.connectionState ==
                      ConnectionState.done
                  ? Container(
                      margin: const EdgeInsets.all(15),
                      child: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Ripetizioni Settimanali",
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .fontSize,
                                      ),
                                    ),
                                    SimpleCircularProgressBar(
                                      maxValue: homePageController.totalWeek
                                          .toDouble(),
                                      size: 40,
                                      animationDuration: 3,
                                      progressStrokeWidth: 5,
                                      backStrokeWidth: 5,
                                      mergeMode: true,
                                      progressColors: [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.primary,
                                      ],
                                      fullProgressColor:
                                          Theme.of(context).colorScheme.primary,
                                      valueNotifier:
                                          homePageController.completedWeek,
                                      onGetText: (value) => Text(
                                          "${value.toInt()}/${homePageController.totalWeek}"),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Ripetizioni Mensili",
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .fontSize,
                                      ),
                                    ),
                                    SimpleCircularProgressBar(
                                      maxValue: homePageController.totalMonth
                                          .toDouble(),
                                      size: 40,
                                      animationDuration: 3,
                                      progressStrokeWidth: 5,
                                      backStrokeWidth: 5,
                                      mergeMode: true,
                                      progressColors: [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.primary,
                                      ],
                                      onGetText: (value) => Text(
                                          "${value.toInt()}/${homePageController.totalMonth}"),
                                      valueNotifier:
                                          homePageController.completedMonth,
                                    )
                                  ],
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Ripetizioni Settimanali",
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .fontSize,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    SimpleCircularProgressBar(
                                      maxValue: homePageController.totalWeek
                                          .toDouble(),
                                      size: 40,
                                      animationDuration: 3,
                                      progressStrokeWidth: 5,
                                      backStrokeWidth: 5,
                                      mergeMode: true,
                                      progressColors: [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.primary,
                                      ],
                                      fullProgressColor:
                                          Theme.of(context).colorScheme.primary,
                                      valueNotifier:
                                          homePageController.completedWeek,
                                      onGetText: (value) => Text(
                                          "${value.toInt()}/${homePageController.totalWeek}"),
                                    ),
                                  ],
                                ),
                                // 20% of screen width
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Ripetizioni Mensili",
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .fontSize,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    SimpleCircularProgressBar(
                                      maxValue: homePageController.totalMonth
                                          .toDouble(),
                                      size: 40,
                                      animationDuration: 3,
                                      progressStrokeWidth: 5,
                                      backStrokeWidth: 5,
                                      mergeMode: true,
                                      progressColors: [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.primary,
                                      ],
                                      onGetText: (value) => Text(
                                          "${value.toInt()}/${homePageController.totalMonth}"),
                                      valueNotifier:
                                          homePageController.completedMonth,
                                    ),
                                  ],
                                )
                              ],
                            ))
                  : Container(
                      margin: const EdgeInsets.all(15),
                      child: const Center(child: CircularProgressIndicator()),
                    )),
    );
  }
}
