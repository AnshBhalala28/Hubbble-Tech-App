import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/file_validation.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class MessageBoardProvider extends ChangeNotifier {
  Future<Response> addPostApiWithImages({
    required Map<String, String> bodyData,
    required List<dynamic> images, // List<XFile>
  }) async {
    try {
      for (var image in images) {
        await FileValidation.validate(image.path);
      }

      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      FormData formData = FormData.fromMap({
        ...bodyData,
        ...{
          for (int i = 0; i < images.length; i++)
            'user_feed_image[$i]': await MultipartFile.fromFile(
              images[i].path,
              filename: images[i].name,
              contentType: FileValidation.getMediaType(images[i].path),
            ),
        },
      });

      final response = await dio.post(
        ApiEndpoint.createPost,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> localPostApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();

      // Increase timeouts
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.post(
        ApiEndpoint.localPost,
        data: FormData.fromMap(bodyData), // send as form-data
        options: Options(
          headers: {
            'X-Auth-Token': token ?? '',
            'Content-Type': 'application/x-www-form-urlencoded',
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

  Future<Response> createGroupApi({
    required Map<String, String> bodyData,
    required List<dynamic> images, // List<XFile>
    required List<String> memberIds,
  }) async {
    try {
      if (images.isNotEmpty) {
        await FileValidation.validate(images.first.path);
      }

      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final Map<String, dynamic> formMap = {
        ...bodyData,
        if (images.isNotEmpty)
          'images': await MultipartFile.fromFile(
            images.first.path,
            filename: images.first.name,
            contentType: FileValidation.getMediaType(images.first.path),
          ),
        ...{
          for (int i = 0; i < memberIds.length; i++)
            'members[$i]': memberIds[i],
        },
      };

      final formData = FormData.fromMap(formMap);
      final response = await dio.post(
        ApiEndpoint.addGroup,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendMessageApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();

      String? filePath = bodyData['files'];
      bodyData.remove('files');

      final Map<String, dynamic> formMap = {...bodyData};

      if (filePath != null && filePath.isNotEmpty) {
        await FileValidation.validate(filePath);
        final mediaType = FileValidation.getMediaType(filePath);
        if (mediaType == null) {
          throw Exception("Unsupported file type");
        }

        formMap['files'] = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: mediaType,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await dio.post(
        ApiEndpoint.sendMessage,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint('Error in sendMessageApi: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<Response> addLikeCommentApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();

      // Increase timeouts
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.post(
        ApiEndpoint.addLikeComment,
        data: FormData.fromMap(bodyData), // safer for Laravel form data
        options: Options(
          headers: {
            'X-Auth-Token': token ?? '',
            'Content-Type': 'application/x-www-form-urlencoded',
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

  Future<Response> getPostCommentApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.getPostComment,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> localPostDeleteApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.localPostDelete,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> appFriendUserPersonalInfoApi(
    Map<String, String> bodyData,
  ) async {
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
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> editPostApi({
    required Map<String, String> bodyData,
    required List<dynamic> images, // List<XFile>
  }) async {
    try {
      for (var image in images) {
        await FileValidation.validate(image.path);
      }

      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      FormData formData = FormData.fromMap({
        ...bodyData,
        ...{
          for (int i = 0; i < images.length; i++)
            'feed_image[$i]': await MultipartFile.fromFile(
              images[i].path,
              filename: images[i].name,
              contentType: FileValidation.getMediaType(images[i].path),
            ),
        },
      });
      final response = await dio.post(
        ApiEndpoint.editPostLocal,
        data: formData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
