import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class MessageBoardProvider extends ChangeNotifier {
  // Future<Response> listConciergeApi(id) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.get(
  //       ApiEndpoint.conciergerList,
  //       queryParameters: {'user_id': id},
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  Future<Response> addPostApiWithImages({
    required Map<String, String> bodyData,
    required List<XFile> images,
  }) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      FormData formData = FormData.fromMap({
        ...bodyData,
        ...{
          for (int i = 0; i < images.length; i++)
            'user_feed_image[$i]': await MultipartFile.fromFile(
              images[i].path,
              filename: images[i].name,
              contentType: _getMediaType(images[i].path),
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
      throw Exception("Something went wrong.");
    }
  }

  // Future<Response> localPostApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.localPost,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }
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
      // Detailed logging

      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  // Future<Response> getGroupApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.getGroup,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> getMyJoinGroupApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.myJoinGroup,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  Future<Response> createGroupApi({
    required Map<String, String> bodyData,
    required List<XFile> images,
    required List<String> memberIds,
  }) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final Map<String, dynamic> formMap = {
        ...bodyData,
        if (images.isNotEmpty)
          'images': await MultipartFile.fromFile(
            images.first.path,
            filename: images.first.name,
            contentType: _getMediaType(images.first.path),
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
      throw Exception("Something went wrong.");
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
        final mediaType = _getMediaType(filePath);
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
      throw Exception("Something went wrong.");
    }
  }

  // Future<Response> groupMessageApi(String groupId, userId) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.get(
  //       '${ApiEndpoint.getGroupMsg}$groupId/$userId',
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> friendRequestApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.friendRequestChat,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> groupFriendRequestApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.listGroupRequest,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> addLikeCommentApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.addLikeComment,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }
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

  // Future<Response> groupMemberApi(String groupId) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.get(
  //       '${ApiEndpoint.groupMember}$groupId',
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> removeGroupMemberApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.removeGroupMember,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> addGroupMemebrApi(Map<String, String> bodyData) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.post(
  //       ApiEndpoint.addGroupMember,
  //       data: bodyData,
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> deleteGroupApi(String groupId, userId) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.get(
  //       '${ApiEndpoint.deleteGroup}$groupId/?user_id=$userId',
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

  // Future<Response> getRequestAppApi(id) async {
  //   try {
  //     String? token = await SaveDataLocal.getToken();
  //     final dio = await DioHelper.getDio();
  //     final response = await dio.get(
  //       ApiEndpoint.getRequestApp,
  //       queryParameters: {'user_id': id},
  //       options: Options(headers: {'X-Auth-Token': token ?? ''}),
  //     );
  //
  //     return response;
  //   } on DioException catch (e) {
  //     throw Exception(handleDioError(e));
  //   }
  // }

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
    required List<XFile> images,
  }) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      FormData formData = FormData.fromMap({
        ...bodyData,
        ...{
          for (int i = 0; i < images.length; i++)
            'feed_image[$i]': await MultipartFile.fromFile(
              images[i].path,
              filename: images[i].name,
              contentType: _getMediaType(images[i].path),
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
      throw Exception("Something went wrong.");
    }
  }

  MediaType? _getMediaType(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType != null) {
      final parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }
    return null;
  }
}
