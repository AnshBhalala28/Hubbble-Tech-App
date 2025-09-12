import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Screen/Authcation/Model/login_model.dart';

class SaveDataLocal {
  static const String userData = 'UserData';
  static const String userToken = 'UserToken';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Save login data (user details + token)
  static Future<void> saveLogInData(LoginModel loginModel) async {
    // Save whole user model securely
    String json = jsonEncode(loginModel.toJson());
    await _secureStorage.write(key: userData, value: json);

    // Save token securely
    String? token = loginModel.data?.token;
    if (token != null && token.isNotEmpty) {
      await _secureStorage.write(key: userToken, value: token);
    }
  }

  /// Get full login model from secure storage
  static Future<LoginModel?> getDataFromLocal() async {
    String? userString = await _secureStorage.read(key: userData);
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
    await _secureStorage.delete(key: userData);
    await _secureStorage.delete(key: userToken);
  }
}
