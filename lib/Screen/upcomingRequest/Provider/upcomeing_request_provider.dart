import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class MyRequestProvider extends ChangeNotifier {
  Future<Response> myRequestApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.myRequest,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': userId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myFriendRequestApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.myFriendRequest,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': userId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myGroupRequestApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.myGroupRequest,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': userId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myRequestActionApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.myrequestAction,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myRequestGroupActionApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.myrequestGroupAction,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
