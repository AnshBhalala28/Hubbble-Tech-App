import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class AuthProvider extends ChangeNotifier {
  Future<Response> loginApi(Map<String, String> data) async {
    try {
      final Dio dio = await DioHelper.getDio();

      final response = await dio.post(
        ApiEndpoint.login,
        data: data,
        options: Options(
          validateStatus: (status) => status == 200 || status == 422,
        ),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> checkMail(Map<String, String> data) async {
    try {
      final Dio dio = await DioHelper.getDio();

      final response = await dio.post(
        ApiEndpoint.checkMail,
        data: data,
        options: Options(
          validateStatus: (status) => status == 200 || status == 422,
        ),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> changePasswordApi(Map<String, String> data) async {
    try {
      final dio = await DioHelper.getDio();
      var response = await dio.post(ApiEndpoint.changePassword, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> forgetPasswordApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.forgetPassword,
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

  Future<Response> changePass(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.changePassword,
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

  Future<Response> deleteAccApi(id) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.delete(
        ApiEndpoint.deleteAccount,
        queryParameters: {'id': id},
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logoutApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.logout,
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
