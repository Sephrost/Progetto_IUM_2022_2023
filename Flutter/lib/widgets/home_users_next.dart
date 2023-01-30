import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:flutter_app/controllers/home_page_controller.dart';
import 'package:flutter_app/widgets/home_booked_card.dart';
import 'package:provider/provider.dart';

/// The widget used to display the next users to be booked in the home page.
class HomeUsersNext extends StatelessWidget {
  const HomeUsersNext({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer2<HomePageController, BookerRefreshController>(
        builder: (context, homePageController, bookerRefreshController,
                child) =>
            FutureBuilder(
                future: homePageController.fetchPrenotations(),
                builder: (context, snapshot) =>
                    snapshot.connectionState == ConnectionState.done
                        ? AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: homePageController.prenotationsList.isEmpty
                                ? const Center(
                                    child: Text('Nessuna prenotazione futura.'),
                                  )
                                : KeyedSubtree(
                                    key: ValueKey(
                                        DateTime.now().millisecondsSinceEpoch),
                                    child: ListView.builder(
                                      primary: false,
                                      itemCount: homePageController
                                          .prenotationsList.length,
                                      itemBuilder: (context, index) {
                                        return HomeBookedCard(index: index);
                                      },
                                    ),
                                  ),
                          )
                        : const Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
