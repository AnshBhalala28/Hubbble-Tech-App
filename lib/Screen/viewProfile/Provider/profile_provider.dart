import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:wavee/comman/store_local.dart';

import '../../../comman/apiConfig.dart';
import '../../../comman/apiEndpoint.dart';
import '../../../comman/responses.dart';

class ProfileProvider extends ChangeNotifier {
  Future<Response> profileApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.profile,
        data: bodyData,

        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      log("error in profileApi${e.response?.data}");
      log("error in profileApi${e.message}");
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> updateProfile(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.updateProfile,
        data: bodyData,

        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> profileEdit(
    Map<String, String> bodyData,
    File? imageFile,
  ) async {
    String url = ApiEndpoint.updateProfile;
    String? token = await SaveDataLocal.getToken();

    try {
      FormData formData = FormData.fromMap(bodyData);

      if (imageFile != null) {
        String fileName = path.basename(imageFile.path);
        final mimeTypeData =
            lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];

        formData.files.add(
          MapEntry(
            'member_image[0]',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
            ),
          ),
        );
      }

      Dio dio = Dio();

      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Connection Timeout");
      } else if (e.response != null) {
        throw Exception("Server responded with error: ${e.response?.data}");
      } else {
        throw Exception("Dio error: ${e.message}");
      }
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
