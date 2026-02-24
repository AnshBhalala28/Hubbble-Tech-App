import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apiConfig.dart';
import '../../../utils/apiEndpoint.dart';
import '../../../utils/responses.dart';
import '../../../utils/storeUserData.dart';

class ServiceProvider extends ChangeNotifier {
  Future<Response> serviceDetailApi(
    String UserId,
    String productid,
    String type,
  ) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.productDetail,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {'user_id': UserId, "id": productid, 'type': type},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
