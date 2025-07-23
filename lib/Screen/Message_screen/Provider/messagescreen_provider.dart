import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wavee/comman/apiEndpoint.dart';

import '../../../comman/apiConfig.dart';
import '../../../comman/responses.dart';
import '../../../comman/store_local.dart';

class MessageProvider extends ChangeNotifier {
  Future<Response> messageApi(
    String userId,
    String conciergeId,
    String type,
    String orderProductId,
  ) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getToken();

    final url =
        '${ApiEndpoint.getChat}/$userId/$conciergeId'
        '?type=$type&order_product_id=$orderProductId';

    log("GET: $url");

    try {
      return await dio.get(
        url,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> sendMessageApi(Map<String, String> bodyData) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getToken();

    final formData = FormData();

    bodyData.forEach((key, value) {
      if (key != 'files') {
        formData.fields.add(MapEntry(key, value));
      }
    });

    if (bodyData['files']?.isNotEmpty ?? false) {
      final filePath = bodyData['files']!;
      final extension = filePath.split('.').last.toLowerCase();
      String mimeType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
        case 'png':
          mimeType = 'image/$extension';
          break;
        case 'mp4':
          mimeType = 'video/mp4';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        default:
          throw Exception('Unsupported file type');
      }

      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            filePath,
            contentType: MediaType.parse(mimeType),
          ),
        ),
      );
    }

    try {
      final response = await dio.post(
        '${ApiEndpoint.sendMessage}',
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e, stack) {
      log('Dio error: ${e.message}\nStack: $stack');
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> sendMessagApi(Map<String, String> bodyData) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getToken();

    try {
      return await dio.post(
        '${ApiEndpoint.sendMessage}',
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> removeFriend(String conId) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getToken();

    try {
      return await dio.get(
        '${ApiEndpoint.removeFriend}$conId',
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> userPersonalInfo(String conId) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getToken();

    try {
      return await dio.get(
        '${ApiEndpoint.conciergeProfile}$conId',
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> sendMessageOrderApi(
    Map<String, String> data,
    File? file,
  ) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getToken();

    final formData = FormData();
    data.forEach((key, value) => formData.fields.add(MapEntry(key, value)));

    if (file != null && file.existsSync()) {
      formData.files.add(
        MapEntry('file', await MultipartFile.fromFile(file.path)),
      );
    }

    try {
      return await dio.post(
        '${ApiEndpoint.sendOrderChat}',
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
    } on DioException catch (e, stack) {
      log('OrderChat error: ${e.message}\n$stack');
      throw Exception(handleDioError(e));
    }
  }
}
