import 'package:flutter/foundation.dart';

/// The class used to refresh the widgets that need to be updated after booking
/// confirmation and etc...
///
/// This class is a singleton, so it can be accessed from anywhere in the app
/// and specifically from the [BookerController] and the [HistoryFiltersController]
class BookerRefreshController extends ChangeNotifier {
  static final BookerRefreshController _instance =
      BookerRefreshController._internal();
  factory BookerRefreshController() => _instance;
  BookerRefreshController._internal();

  void refresh() {
    notifyListeners();
  }
}
