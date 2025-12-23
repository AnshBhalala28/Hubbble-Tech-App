import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Ui/Authentication/modal/login_model.dart';

class SaveDataLocal {
  static const String userData = 'UserData';
  static const String userToken = 'UserToken';
  static const String userEmail = 'UserEmail';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Save login data (user details + token + email + password)
  static Future<void> saveLogInData(
    LoginModel loginModel, {
    required String email,
  }) async {
    // Save whole user model securely
    String json = jsonEncode(loginModel.toJson());
    await _secureStorage.write(key: userData, value: json);

    // Save token securely
    String? token = loginModel.data?.token;
    if (token != null && token.isNotEmpty) {
      await _secureStorage.write(key: userToken, value: token);
    }

    // Save email & password securely
    await _secureStorage.write(key: userEmail, value: email);
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

  /// Get token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: userToken);
  }

  /// Get saved email
  static Future<String?> getEmail() async {
    return await _secureStorage.read(key: userEmail);
  }

  /// Clear all stored data
  static Future<void> clearUserData() async {
    await _secureStorage.delete(key: userData);
    await _secureStorage.delete(key: userToken);
    await _secureStorage.delete(key: userEmail);
    log('✅ ALL DATA HAS BEEN CLEARED');
  }

  static Future<Map<String, String?>> getEmailAndPassword() async {
    String? email = await _secureStorage.read(key: userEmail);
    return {'email': email};
  }
}
