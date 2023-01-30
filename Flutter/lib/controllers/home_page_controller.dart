import 'package:flutter/material.dart';
import 'package:flutter_app/database/db_controller.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/models/prenotation.dart';

/// The controller used to manage the home page.
class HomePageController extends ChangeNotifier {
  ValueNotifier<double> completedWeek = ValueNotifier(0);
  int totalWeek = 0;
  ValueNotifier<double> completedMonth = ValueNotifier(0);
  int totalMonth = 0;
  List<Prenotation> prenotationsList = [];

  Future<void> fetchStats() async {
    String email = LoginController.user.email;
    List<Prenotation> list;
    list = await DbController.db.getUserPrenotationsThisWeek(email);
    totalWeek = list.length;
    list = await DbController.db.getUserPrenotationsThisMonth(email);
    totalMonth = list.length;
    list = await DbController.db.getUserPrenotationsCompletedThisWeek(email);
    completedWeek.value = list.length.toDouble();
    list = await DbController.db.getUserPrenotationsCompletedThisMonth(email);
    completedMonth.value = list.length.toDouble();
  }

  //get the prenotations from the database
  Future<void> fetchPrenotations() async {
    prenotationsList =
        await DbController.db.getBookedPrenotations(LoginController.user.email);
  }
}
