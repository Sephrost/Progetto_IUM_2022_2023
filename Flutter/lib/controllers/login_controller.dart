import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/cart_controller.dart';
import 'package:flutter_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/db_controller.dart';

enum AutehticationStatus { unknown, authenticated, unauthenticated, guest }

class LoginController extends ChangeNotifier {
  /// The instance of the database into the DbController class
  final DbController _db = DbController.db;
  AutehticationStatus _status = AutehticationStatus.unknown;
  static User? _user;

  factory LoginController() => _instance;
  LoginController._internal();
  static final LoginController _instance = LoginController._internal();

  /// The user logged in the app, if there is no user logged in, it returns an
  /// [EmptyUser]
  static get user => _user ?? EmptyUser();

  /// The status of the login, it can be [\
  /// AutehticationStatus.unknown,\
  /// AutehticationStatus.authenticated,\
  /// AutehticationStatus.unauthenticated,\
  /// AutehticationStatus.guest\
  /// ]
  get status => _status;

  Future<void> checkLogin() async {
    if (_user != null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user = prefs.getString('user');
    if (user == null) {
      _status = AutehticationStatus.unauthenticated;
    } else {
      _user = await _db.getUser(user);
      _status = AutehticationStatus.authenticated;
    }
  }

  Future<void> login(String username, String password) async {
    final User user = await _db.login(username, password);
    if (user.email == '') {
      _status = AutehticationStatus.unauthenticated;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user', user.email);
      _status = AutehticationStatus.authenticated;
      _user = user;
      CartController().loadCart();
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    _status = AutehticationStatus.unauthenticated;
  }

  Future<void> loginAsGuest() async {
    final User user = await _db.login("guest@guest.com", "guest");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    _status = AutehticationStatus.guest;
    _user = user;
  }
}
