// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// import '../Screen/Authcation/Model/login_model.dart';

// class SaveDataLocal {
//   static const String userData = 'UserData';

//   static Future<void> saveLogInData(LoginModel loginModel) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String json = jsonEncode(loginModel.toJson());
//     await prefs.setString(userData, json);
//
//   }

//   static Future<LoginModel?> getDataFromLocal() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userString = prefs.getString(userData);
//     if (userString != null) {
//       Map<String, dynamic> userMap = jsonDecode(userString);

//       return LoginModel.fromJson(userMap);
//     }
//     return null;
//   }

//   static Future<void> clearUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(userData);
//
//   }
// }
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screen/Authcation/Model/login_model.dart';

class SaveDataLocal {
  static const String userData = 'UserData';
  static const String userToken = 'UserToken';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveLogInData(LoginModel loginModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(loginModel.toJson());
    await prefs.setString(userData, json);

    // Save token securely
    String? token = loginModel.data?.token;
    if (token != null && token.isNotEmpty) {
      await _secureStorage.write(key: userToken, value: token);
    }
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

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: userToken);
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userData);
    await _secureStorage.delete(key: userToken);
  }
}
