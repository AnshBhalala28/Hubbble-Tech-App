import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wavee/Screen/Authcation/model/login_model.dart';

class SaveDataLocal {
  static const String userData = 'UserData';

  // Save login data
  static Future<void> saveLogInData(LoginModel loginModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(loginModel.toJson());
    await prefs.setString(userData, json);
    print("User data stored successfully");
  }

  // Get login data
  static Future<LoginModel?> getDataFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString(userData);
    if (userString != null) {
      Map<String, dynamic> userMap = jsonDecode(userString);

      return LoginModel.fromJson(userMap);
    }
    return null;
  }

  // Clear login data
  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userData);
    print("User data cleared");
  }
}
