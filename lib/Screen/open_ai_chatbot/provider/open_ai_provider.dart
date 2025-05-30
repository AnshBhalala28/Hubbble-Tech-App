import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

import '../../Authcation/model/login_model.dart';

class ChatBotAiProvider extends ChangeNotifier {
  Future<http.Response> chatbotDataApi(Map<String, String> bodyData) async {
    String url = '${baseUrl}/ai_chat';

    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    print("API URL: $url and \n Header:::==>>>$headers");

    var responseJson;
    try {
      final response = await http
          .post(
            Uri.parse(url), // Encode to JSON
            headers: headers,
            body: bodyData,
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw const SocketException('Something went wrong');
            },
          );

      responseJson = responses(response);
      print("Response: ${response.body}");

      return responseJson;
    } catch (e) {
      print("API Error: $e");
      throw Exception("Error During Communication: $e");
    }
  }

  Future<http.Response> chatBotReceiveData(String userId) async {
    String url = '${baseUrl}/get_chat_history?user_id=$userId';

    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    print("API URL: $url");
    // print("Token Jay cheh $token");

    var responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw const SocketException('Something went wrong');
            },
          );

      responseJson = responses(response);
      print("Response: ${response.body}");

      return responseJson;
    } catch (e) {
      print("API Error: $e");
      throw Exception("Error During Communication: $e");
    }
  }

  Future<http.Response> clearChatBotData(Map<String, String> bodyData) async {
    String url = '${baseUrl}/clear_chat_messages';

    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    print("API URL: $url and \n Header:::==>>>$headers");

    var responseJson;
    try {
      final response = await http
          .post(
            Uri.parse(url), // Encode to JSON
            headers: headers,
            body: bodyData,
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw const SocketException('Something went wrong');
            },
          );

      responseJson = responses(response);
      print("Response: ${response.body}");

      return responseJson;
    } catch (e) {
      print("API Error: $e");
      throw Exception("Error During Communication: $e");
    }
  }
}
