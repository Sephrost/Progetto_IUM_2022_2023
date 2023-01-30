import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/date_filter.dart';
import 'package:flutter_app/widgets/bottom_sheet_filter.dart';
import 'package:flutter_app/widgets/filter_toggle_chip.dart';
import 'package:provider/provider.dart';

import '../controllers/history_filters_controller.dart';

/// The widget that contains the filters for the history page
class HistoryFilters extends StatelessWidget {
  const HistoryFilters({Key? key}) : super(key: key);

  List<Widget> _addPaddingBetweenFilters(List<Widget> filters) {
    for (var i = 1; i < filters.length; i += 2) {
      filters.insert(i, const SizedBox(width: 8));
    }
    return filters;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _addPaddingBetweenFilters(<Widget>[
              FutureBuilder(
                  future: Provider.of<HistoryFiltersController>(context,
                          listen: false)
                      .fetchSubjects(),
                  builder: (context, snapshot) {
                    // get the list of subjects name from snapshot.data
                    List<String> subjects =
                        Provider.of<HistoryFiltersController>(context,
                                listen: false)
                            .subjectsList
                            .map((e) => e.name)
                            .toList();
                    return BottomSheetFilter(
                        label: "Materie",
                        options: subjects,
                        icon: const Icon(Icons.book),
                        updateProvider: (List<String> selectedOptions) {
                          context.read<HistoryFiltersController>().subjects =
                              selectedOptions;
                        });
                  }),
              FutureBuilder(
                  future: Provider.of<HistoryFiltersController>(context,
                          listen: false)
                      .fetchTeachers(),
                  builder: (context, snapshot) {
                    List<String> teacher =
                        Provider.of<HistoryFiltersController>(context,
                                listen: false)
                            .teachersList
                            .map((e) => e.name)
                            .toList();
                    return BottomSheetFilter(
                        label: "Docenti",
                        options: teacher,
                        icon: const Icon(Icons.person),
                        updateProvider: (List<String> selectedOptions) {
                          context.read<HistoryFiltersController>().teachers =
                              selectedOptions;
                        });
                  }),
              DateFilter("Da:", updateProvider: (String date) {
                context.read<HistoryFiltersController>().startDate = date;
              }),
              DateFilter("A:", updateProvider: (String date) {
                context.read<HistoryFiltersController>().endDate = date;
              }),
              FilterToggleChip(
                  label: "Attive",
                  onSelected: (bool value) {
                    context.read<HistoryFiltersController>().booked = value;
                  }),
              FilterToggleChip(
                  label: "Disdette",
                  onSelected: (bool selected) {
                    context.read<HistoryFiltersController>().cancelled =
                        selected;
                  }),
              FilterToggleChip(
                  label: "Effettuate",
                  onSelected: (bool selected) {
                    context.read<HistoryFiltersController>().completed =
                        selected;
                  }),
            ])));
  }
}
