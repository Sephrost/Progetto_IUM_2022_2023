import 'package:flutter/material.dart';
import 'package:flutter_app/color_schemes/color_schemes.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
);

// create provider for theme
class ThemeChangerProvider extends ChangeNotifier {
  // Inizializzazione:
  //- key per la sezione di dati persistenti
  // - Sezione di dati persistenti
  // - Variabile per il tema
  final String key = "theme";
  SharedPreferences? _prefs;
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;

  factory ThemeChangerProvider() => _instance;
  ThemeChangerProvider._internal();
  static final ThemeChangerProvider _instance =
      ThemeChangerProvider._internal();

  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  // Metodi per la gestione del dato persistenti, nomi autoesplicativi
  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> loadTheme() async {
    await _initPrefs();
    _darkTheme = _prefs?.getBool(key) ?? true;
  }

  // _loadFromPrefs() async {
  //   await _initPrefs();
  //   _darkTheme = _prefs?.getBool(key) ?? true;
  //   notifyListeners();
  // }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs?.setBool(key, _darkTheme);
  }
}
