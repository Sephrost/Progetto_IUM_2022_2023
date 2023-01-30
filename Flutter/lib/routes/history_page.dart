import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:provider/provider.dart';

import '../controllers/history_filters_controller.dart';
import '../widgets/history_entry.dart';
import '../widgets/history_filters.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: ChangeNotifierProvider(
        create: (context) => HistoryFiltersController(),
        child: Column(
          children: const [
            HistoryFilters(),
            Expanded(child: _FilteredListView()),
          ],
        ),
      ),
    )));
  }
}

class _FilteredListView extends StatelessWidget {
  const _FilteredListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<HistoryFiltersController, BookerRefreshController>(
        builder: (context, historyFiltersController, refreshController,
                child) =>
            FutureBuilder(
              future: historyFiltersController.fetchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return RefreshIndicator(
                      onRefresh: () async {
                        historyFiltersController.refresh();
                      },
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: historyFiltersController.history.isEmpty
                              ? const CustomScrollView(slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child:
                                          Text('Nessuna prenotazione passata'),
                                    ),
                                  )
                                ])
                              : KeyedSubtree(
                                  key: ValueKey(
                                      DateTime.now().millisecondsSinceEpoch),
                                  child: ListView.builder(
                                    itemCount:
                                        historyFiltersController.history.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return HistoryEntry(
                                        index: index,
                                      );
                                    },
                                  ),
                                )));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ));
  }
}
