import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  ThemeProvider(this.prefs);
  bool get dark => prefs.getBool('darkMode') ?? false;
  bool get compact => prefs.getBool('compactFeed') ?? false;
  Future<void> setDark(bool value) async {
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setCompact(bool value) async {
    await prefs.setBool('compactFeed', value);
    notifyListeners();
  }
}
