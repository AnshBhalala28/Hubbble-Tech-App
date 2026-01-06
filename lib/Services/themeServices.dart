import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeController extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool isDark = false;

  ThemeController() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    String? value = await _storage.read(key: "isDark");
    isDark = value == "true";
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    isDark = !isDark;
    await _storage.write(key: "isDark", value: isDark.toString());
    notifyListeners();
  }

  Future<void> resetTheme() async {
    isDark = false; // Reset local state to default
    await _storage.delete(key: "isDark"); // Remove the saved preference
    notifyListeners(); // Update the UI
  }
}
