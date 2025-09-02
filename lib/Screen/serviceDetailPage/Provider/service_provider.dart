import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class ServiceProvider extends ChangeNotifier {
  Future<Response> serviceDetailApi(
    String UserId,
    String productid,
    String type,
  ) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.productDetail,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': UserId, "id": productid, 'type': type},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
