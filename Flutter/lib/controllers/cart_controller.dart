import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:flutter_app/widgets/cart_entry.dart';
import '../models/slot.dart';
import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/database/db_controller.dart';

/// The controller used to manage the cart page and get
/// the slots added to the cart.
///
/// It's a singleton, so it can be accessed from anywhere in the app
/// and the controllers.
class CartController extends ChangeNotifier {
  List<AvailableSlot> _cart = [];

  factory CartController() => _instance;
  CartController._internal();
  static final CartController _instance = CartController._internal();

  List<AvailableSlot> get cart => _cart;

  Future<void> loadCart() async {
    _cart = await DbController.db.getCart(LoginController.user.email);
    notifyListeners();
  }

  void addToCart(AvailableSlot slot) {
    _cart.add(slot);
    DbController.db.addToCart(
        LoginController.user.email,
        slot.dateForDbCart,
        slot.subject.name,
        slot.teacher.email,
        slot.beginHourAsString,
        slot.endHourAsString);
    notifyListeners();
  }

  void removeFromCart(AvailableSlot slot) {
    _cart.remove(slot);
    DbController.db.removeFromCart(
        LoginController.user.email,
        slot.dateForDbCart,
        slot.subject.name,
        slot.teacher.email,
        slot.beginHourAsString,
        slot.endHourAsString);
    notifyListeners();
  }

  void removeFromCartByIndex(int index) {
    AvailableSlot slot = _cart[index];
    _cart.removeAt(index);
    DbController.db.removeFromCart(
        LoginController.user.email,
        slot.dateForDbCart,
        slot.subject.name,
        slot.teacher.email,
        slot.beginHourAsString,
        slot.endHourAsString);
    notifyListeners();
  }

  void clearCart() {
    for (var slot in _cart) {
      DbController.db.removeFromCart(
          LoginController.user.email,
          slot.dateForDbCart,
          slot.subject.name,
          slot.teacher.email,
          slot.beginHourAsString,
          slot.endHourAsString);
    }

    _cart.clear();
    notifyListeners();
  }

  Future<bool> buyCart() async {
    // add cart list to prenotation list
    bool succes = await DbController.db.addPrenotations(_cart);
    if (!succes) return false;
    // remove slot from cart
    for (var slot in _cart) {
      DbController.db.removeFromCart(
          LoginController.user.email,
          slot.dateForDbCart,
          slot.subject.name,
          slot.teacher.email,
          slot.beginHourAsString,
          slot.endHourAsString);
    }
    // remove slot from list
    _cart.clear();
    BookerRefreshController().refresh();
    notifyListeners();
    return true;
  }

  CartEntry getCartEntry(int index) {
    return CartEntry(slot: _cart[index]);
  }
}
