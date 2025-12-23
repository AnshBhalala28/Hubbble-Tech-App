import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/file_validation.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class MessageProvider extends ChangeNotifier {
  Future<Response> messageApi(
    String userId,
    String conciergeId,
    String type,
    String orderProductId,
  ) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getValidToken();

    final url =
        '${ApiEndpoint.getChat}/$userId/$conciergeId'
        '?type=$type&order_product_id=$orderProductId';

    try {
      return await dio.get(
        url,
        options: Options(headers: {'X-Auth-Token': token}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendMessageApi(Map<String, String> bodyData) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getValidToken();

    final formData = FormData();

    bodyData.forEach((key, value) {
      if (key != 'files') {
        formData.fields.add(MapEntry(key, value));
      }
    });

    if (bodyData['files']?.isNotEmpty ?? false) {
      final filePath = bodyData['files']!;
      await FileValidation.validate(filePath);

      formData.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(
            filePath,
            contentType: FileValidation.getMediaType(filePath),
          ),
        ),
      );
    }

    try {
      final response = await dio.post(
        ApiEndpoint.sendMessage,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendMessagApi(Map<String, String> bodyData) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getValidToken();

    try {
      return await dio.post(
        ApiEndpoint.sendMessage,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> removeFriend(String conId) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getValidToken();

    try {
      return await dio.get(
        '${ApiEndpoint.removeFriend}$conId',
        options: Options(headers: {'X-Auth-Token': token}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> userPersonalInfo(String conId) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getValidToken();

    try {
      return await dio.get(
        '${ApiEndpoint.conciergeProfile}$conId',
        options: Options(headers: {'X-Auth-Token': token}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendMessageOrderApi(
    Map<String, String> data,
    File? file,
  ) async {
    final dio = await DioHelper.getDio();
    final token = await SaveDataLocal.getValidToken();

    final formData = FormData();
    data.forEach((key, value) => formData.fields.add(MapEntry(key, value)));

    if (file != null && file.existsSync()) {
      await FileValidation.validate(file.path);
      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            contentType: FileValidation.getMediaType(file.path),
          ),
        ),
      );
    }

    try {
      return await dio.post(
        ApiEndpoint.sendOrderChat,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
