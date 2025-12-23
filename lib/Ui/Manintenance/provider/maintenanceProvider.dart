import 'dart:io';

import 'package:dio/dio.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/file_validation.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class MaintenanceProvider {
  Future<Response> addMaintanceRequestApi({
    required String userId,
    required String subject,
    required String note,
    File? file,
  }) async {
    try {
      if (file != null && file.path.isNotEmpty) {
        await FileValidation.validate(file.path);
      }

      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();

      final formData = FormData.fromMap({
        'user_id': userId,
        'subject': subject,
        'note': note,
        if (file != null && file.path.isNotEmpty)
          'file[]': await MultipartFile.fromFile(
            file.path,
            contentType: FileValidation.getMediaType(file.path),
          ),
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
    } catch (e) {
      rethrow;
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
