import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apiConfig.dart';
import '../../../utils/apiEndpoint.dart';
import '../../../utils/responses.dart';
import '../../../utils/storeUserData.dart';

class VisitorProvider extends ChangeNotifier {
  Future<Response> visitorApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.parcel,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
