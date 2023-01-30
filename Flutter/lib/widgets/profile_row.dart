import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:provider/provider.dart';

// This Widget displays information about the user total, monthly and weekly hours of repetition.
class NumbersWidget extends StatefulWidget {
  const NumbersWidget({super.key});

  @override
  State<NumbersWidget> createState() => _NumbersWidgetState();
}

/// This class create a row for showing the total, monthly and weekly hours of repetition
///
/// It's used in the profile page
class _NumbersWidgetState extends State<NumbersWidget> {
  @override
  Widget build(BuildContext context) => Consumer<BookerRefreshController>(
        builder: (context, controller, child) => FutureBuilder(
            future:
                DbController.db.getTotalHoursAll(LoginController.user.email),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Show total hours of repetition
                    buildButton(context, snapshot.data![0], 'Ore Totali'),
                    buildDivider(),
                    buildButton(context, snapshot.data![1], 'Ore Mensili'),
                    buildDivider(),
                    buildButton(context, snapshot.data![2], 'Ore settimanali'),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Show total hours of repetition
                    const CircularProgressIndicator(),
                    buildDivider(),
                    const CircularProgressIndicator(),
                    buildDivider(),
                    const CircularProgressIndicator(),
                  ],
                );
              }
            }),
      );
  Widget buildDivider() => const SizedBox(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
