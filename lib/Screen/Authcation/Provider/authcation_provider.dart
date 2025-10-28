import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiEndpoint.dart';

import '../../../comman/apiConfig.dart';
import '../../../comman/responses.dart';
import '../../../comman/store_local.dart';

class AuthProvider extends ChangeNotifier {
  // Future<Response> loginApi(Map<String, String> bodyData) async {
  //   try {
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(ApiEndpoint.login, data: bodyData);
  //     log("Login Error in fuild ${ApiEndpoint.login}");
  //     return response;
  //   } on DioException catch (e) {
  //     log("Login Error in fuild ${ApiEndpoint.login}");
  //     log("Login Error in fuild ${e.message}");
  //     log("Login Error in fuild ${e.response?.data}");
  //     throw Exception('error $e');
  //   }
  // }
  Future<dynamic> loginApi(Map<String, String> data) async {
    try {
      var response = await Dio().post(
        '${ApiEndpoint.login}',
        data: data,
        options: Options(

          validateStatus: (status) {
            return status == 200 || status == 422;
          },
        ),
      );
      return response;
    } catch (e) {
      log("Login Error in fuild ${ApiEndpoint.login}");
      log("Login Error in fuild $e");
      rethrow;
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
    try {
      String? token = await SaveDataLocal.getToken();

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
    try {
      String? token = await SaveDataLocal.getToken();

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

  Future<Response> updateFCM(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(ApiEndpoint.updateFcm, data: bodyData);
      return response;
    } on DioException catch (e) {
      throw Exception('error $e');
    }
  }
}
