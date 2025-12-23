import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class ProfileProvider extends ChangeNotifier {
  Future<Response> profileApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
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

      final dio = await DioHelper.getDio();

      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      log("Unexpected error: $e");
      throw Exception("Something went wrong.");
    }
  }
}
