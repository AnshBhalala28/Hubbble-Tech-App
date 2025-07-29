import 'dart:developer';

//
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../comman/apiConfig.dart'; // For DioHelper
import '../../../comman/apiEndpoint.dart';
import '../../../comman/store_local.dart';

class ChatProvider extends ChangeNotifier {
  Future<Response> chatApi(String userId, String lon, String lat) async {
    try {
      final dio = await DioHelper.getDio();
      log(
        '${ApiEndpoint.getConcierge}?user_id=$userId&longitude=$lon&latitude=$lat',
      );
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final response = await dio.get(
        '${ApiEndpoint.getConcierge}?user_id=$userId&longitude=$lon&latitude=$lat',
        options: Options(headers: {'X-Auth-Token': token ?? ''}),

        // queryParameters: {'user_id': userId, 'longitude': lon, 'latitude': lat},
      );
      log("Sucess");

      return response;
    } on DioException catch (e) {
      throw Exception("Something went wrong: $e");
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<Response> chatStoryApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.allStory,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      log("urkl ${ApiEndpoint.allStory}");
      return response;
    } on DioException catch (e) {
      throw Exception("Something went wrong: $e");
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}
