import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiEndpoint.dart';

import '../../../comman/apiConfig.dart';
import '../../../comman/responses.dart';
import '../../../comman/store_local.dart';

class AuthProvider extends ChangeNotifier {
  Future<Response> loginApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(ApiEndpoint.login, data: bodyData);
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> forgetPasswordApi(Map<String, String> bodyData) async {
    String? token = await SaveDataLocal.getToken();

    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.forgetPassword,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> deleteAccApi(id) async {
    String? token = await SaveDataLocal.getToken();

    try {
      final dio = await DioHelper.getDio();
      final response = await dio.delete(
        ApiEndpoint.deleteAccount,
        queryParameters: {'id': id},
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> logoutApi(Map<String, String> bodyData) async {
    String? token = await SaveDataLocal.getToken();

    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.logout,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
