import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/store_local.dart';

import '../../../comman/responses.dart';

class EventProvider extends ChangeNotifier {
  Future<Response> eventapi(Map<String, String> bodyData) async {
    try {
      final dio = Dio();
      String? token = await SaveDataLocal.getToken();

      final response = await dio.post(
        ApiEndpoint.event,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Response> eventDetailApi(Map<String, String> bodyData) async {
    try {
      final dio = Dio();
      String? token = await SaveDataLocal.getToken();

      final response = await dio.post(
        ApiEndpoint.eventDetail,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Response> sendeventapi(Map<String, String> bodyData) async {
    try {
      final dio = Dio();
      String? token = await SaveDataLocal.getToken();
      final response = await dio.post(
        ApiEndpoint.sendEventRequest,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
