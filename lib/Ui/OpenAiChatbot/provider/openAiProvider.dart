import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../Utils/const.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';
import '../../Authentication/modal/login_model.dart';

class ChatBotAiProvider extends ChangeNotifier {
  Future<http.Response> chatbotDataApi(Map<String, String> bodyData) async {
    String url = '$baseUrl/ai_chat';

    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    var responseJson;
    try {
      final response = await http
          .post(Uri.parse(url), headers: headers, body: bodyData)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw const SocketException('Something went wrong');
            },
          );

      responseJson = responses(response);

      return responseJson;
    } catch (e) {
      debugLog("Error in chatbotDataApi: $e");
      if (e is http.Response) {
        rethrow;
      }
      throw Exception(
        kDebugMode
            ? "Error During Communication: $e"
            : "Error During Communication.",
      );
    }
  }

  Future<http.Response> chatBotReceiveData(String userId) async {
    String url = '$baseUrl/get_chat_history?user_id=$userId';

    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

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

      return responseJson;
    } catch (e) {
      debugLog("Error in chatBotReceiveData: $e");
      if (e is http.Response) {
        rethrow;
      }
      throw Exception(
        kDebugMode
            ? "Error During Communication: $e"
            : "Error During Communication.",
      );
    }
  }

  Future<http.Response> clearChatBotData(Map<String, String> bodyData) async {
    String url = '$baseUrl/clear_chat_messages';

    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    var responseJson;
    try {
      final response = await http
          .post(Uri.parse(url), headers: headers, body: bodyData)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw const SocketException('Something went wrong');
            },
          );

      responseJson = responses(response);

      return responseJson;
    } catch (e) {
      debugLog("Error in clearChatBotData: $e");
      if (e is http.Response) {
        rethrow;
      }
      throw Exception(
        kDebugMode
            ? "Error During Communication: $e"
            : "Error During Communication.",
      );
    }
  }
}
