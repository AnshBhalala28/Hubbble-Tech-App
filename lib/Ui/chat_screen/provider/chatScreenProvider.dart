import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apiConfig.dart';
import '../../../utils/apiEndpoint.dart';
import '../../../utils/responses.dart';
import '../../../utils/storeUserData.dart';

class ChatProvider extends ChangeNotifier {
  Future<Response> chatApi(String userId, String lon, String lat) async {
    try {
      final dio = await DioHelper.getDio();

      String token = await SaveDataLocal.getValidToken();

      final response = await dio.get(
        '${ApiEndpoint.getConcierge}?user_id=$userId&longitude=$lon&latitude=$lat',
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in chatApi: $e");
      rethrow;
    }
  }

  Future<Response> chatStoryApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.allStory,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in chatStoryApi: $e");
      rethrow;
    }
  }
}
