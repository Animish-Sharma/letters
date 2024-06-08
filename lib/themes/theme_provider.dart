import 'package:flutter/material.dart';
import 'package:letters/themes/dark_mode.dart';
import 'package:letters/themes/light_mode.dart';
import "package:shared_preferences/shared_preferences.dart";

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;
  void _getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String a = prefs.getString('theme') ?? "";
    a == "dark" ? _themeData = darkMode : _themeData = lightMode;
    notifyListeners();
  }

  ThemeData getThemeData() {
    _getPrefItems();
    return _themeData;
  }

  ThemeData get themeData => getThemeData();
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    setThemeData(themeData);
    notifyListeners();
  }

  void setThemeData(ThemeData themeData) async {
    final prefs = await SharedPreferences.getInstance();
    String t = themeData == lightMode ? "light" : "dark";
    await prefs.setString("theme", t);
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
