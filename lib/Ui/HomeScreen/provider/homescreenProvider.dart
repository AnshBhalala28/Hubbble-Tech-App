import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class HomeProvider extends ChangeNotifier {
  Future<Response> parcelShowCountApi(Map<String, String> bodyData) async {
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

  Future<Response> visitorShowCountApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.visitor,
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

  Future<Response> chatCountApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.chatCount,
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

  Future<Response> messageBoardApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.messageBoard,
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
