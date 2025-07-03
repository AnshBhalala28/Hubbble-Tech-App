import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Screen/Authcation/Model/login_model.dart';

class SaveDataLocal {
  static const String userData = 'UserData';

  static Future<void> saveLogInData(LoginModel loginModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(loginModel.toJson());
    await prefs.setString(userData, json);
    print("User data stored successfully");
  }

  static Future<LoginModel?> getDataFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString(userData);
    if (userString != null) {
      Map<String, dynamic> userMap = jsonDecode(userString);

      return LoginModel.fromJson(userMap);
    }
    return null;
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userData);
    print("User data cleared");
  }
}
