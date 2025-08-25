import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class NotificationProvider extends ChangeNotifier {
  // Future<Response> notificationApi(String userId) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     if (token != null && token.isNotEmpty) {
  //       Map<String, String> headers = {'X-Auth-Token': '$token'};
  //     }
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.get(
  //       ApiEndpoint.appNotification,
  //       queryParameters: {'user_id': userId},
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  Future<Response> notificationReadApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.notificatonRead,
        queryParameters: {'user_id': userId},
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
