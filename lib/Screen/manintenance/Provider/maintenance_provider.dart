import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class MaintenanceProvider {
  // Future<Response> addMaintanceRequestApi(Map<String, String> bodyData) async {
  //   try {
  //     final dio = await DioHelper.getDio();
  //     String? token = await SaveDataLocal.getToken();
  //     final response = await dio.post(
  //       ApiEndpoint.maintanceRequest,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //
  //
  //
  //     throw Exception(handleDioError(e));
  //   }
  // }
  Future<Response> addMaintanceRequestApi({
    required String userId,
    required String subject,
    required String note,
    File? file,
  }) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();

      final formData = FormData.fromMap({
        'user_id': userId,
        'subject': subject,
        'note': note,
        if (file != null && file.path.isNotEmpty)
          'file[]': await MultipartFile.fromFile(file.path),
      });

      final response = await dio.post(
        ApiEndpoint.maintanceRequest,
        data: formData,
        options: Options(
          headers: {
            'X-Auth-Token': token ?? '',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> getMaintanceApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      final response = await dio.post(
        ApiEndpoint.getMaintance,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
