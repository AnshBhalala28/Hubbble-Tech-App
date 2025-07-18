import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart';
import 'package:wavee/comman/store_local.dart';

import '../../../comman/apiConfig.dart';
import '../../../comman/apiEndpoint.dart';
import '../../../comman/responses.dart';

class MessageBoardProvider extends ChangeNotifier {
  Future<Response> listConciergeApi(id) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.conciergerList,
        queryParameters: {'user_id': id},
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      print("Login Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

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
      debugPrint("❌ Dio Error: ${e.message}");
      throw Exception(handleDioError(e));
    } catch (e) {
      debugPrint("❌ General Error: $e");
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> localPostApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.localPost,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      print("Login Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> getGroupApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.getGroup,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      print("Login Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> getMyJoinGroupApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.myJoinGroup,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      print("Login Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

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
      debugPrint("❌ General Error: $e");
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
      debugPrint("❌ Dio Error: ${e.message}");
      throw Exception(handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint("❌ General Error: $e\n📌 StackTrace: $stackTrace");
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> groupMessageApi(String groupId, userId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        '${ApiEndpoint.getGroupMsg}$groupId/$userId',
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> friendRequestApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.friendRequestChat,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> groupFriendRequestApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.listGroupRequest,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> addLikeCommentApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.addLikeComment,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
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

  Future<Response> groupMemberApi(String groupId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        '${ApiEndpoint.groupMember}$groupId',
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> removeGroupMemberApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.removeGroupMember,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> addGroupMemebrApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.addGroupMember,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> deleteGroupApi(String groupId, userId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        '${ApiEndpoint.deleteGroup}$groupId/?user_id=$userId',
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> getRequestAppApi(id) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.getRequestApp,
        queryParameters: {'user_id': id},
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
      debugPrint("❌ Dio Error: ${e.message}");
      throw Exception(handleDioError(e));
    } catch (e) {
      debugPrint("❌ General Error: $e");
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
  // class MessageBoardProvider extends ChangeNotifier {
  // Future<http.Response> conciergerlistApi(
  //   String user_id,
  // ) async {
  //   String url = '${baseUrl}/list-concierger?user_id=$user_id';
  //   print("Get conciergerlist Url : $url");
  //   try {
  //     final response = await http.get(Uri.parse(url)).timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw SocketException('Request timed out');
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       log("lat");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> getgrouplistapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/get-my-group';
  //   print("post Dwell time Url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> GetMyJoinGroup(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/my-joined-groups';
  //   print("post Dwell time Url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> localpostap(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/get_post_app';
  //   print("localpost url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> creategroupapi(
  //     Map<String, String> bodyData, List<String> memberIds,
  //     {File? imageFile}) async {
  //   const url = '${baseUrl}/add-group';
  //   print("Request URL: $url");
  //
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //
  //     bodyData.forEach((key, value) {
  //       request.fields[key] = value;
  //     });
  //
  //     for (int i = 0; i < memberIds.length; i++) {
  //       request.fields['members[$i]'] = memberIds[i];
  //       log("Member id jay che ${memberIds[i]}");
  //     }
  //
  //     if (imageFile != null) {
  //       var fileStream = http.ByteStream(imageFile.openRead());
  //       var fileLength = await imageFile.length();
  //
  //       var multipartFile = http.MultipartFile(
  //         'images',
  //         fileStream,
  //         fileLength,
  //         filename: imageFile.path.split('/').last,
  //         contentType: MediaType('image', imageFile.path.split('.').last),
  //       );
  //
  //       request.files.add(multipartFile);
  //       print("Image added to request: ${imageFile.path}");
  //     }
  //
  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);
  //
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  //}
  // Future<http.Response> sendmessageapi(Map<String, String> bodyData) async {
  //   const url = '$baseUrl/send-message';
  //   print("Request URL: $url");
  //
  //   try {
  //     final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));
  //
  //     bodyData.forEach((key, value) {
  //       if (key != 'files') {
  //         imageUploadRequest.fields[key] = value;
  //       }
  //     });
  //
  //     if (bodyData['files']?.isNotEmpty ?? false) {
  //       final String filePath = bodyData['files']!;
  //
  //       print('Uploading file: $filePath');
  //
  //       String fileExtension = filePath.split('.').last.toLowerCase();
  //       MediaType mediaType;
  //
  //       switch (fileExtension) {
  //         case "jpg":
  //         case "jpeg":
  //         case "png":
  //           mediaType = MediaType('image', fileExtension);
  //           break;
  //         case "mp4":
  //           mediaType = MediaType('video', 'mp4');
  //           break;
  //         case "pdf":
  //           mediaType = MediaType('application', 'pdf');
  //           break;
  //         default:
  //           throw Exception('Unsupported media type');
  //       }
  //
  //       final file = await http.MultipartFile.fromPath(
  //         'files',
  //         filePath,
  //         contentType: mediaType,
  //       );
  //       imageUploadRequest.files.add(file);
  //     }
  //
  //     final streamResponse = await imageUploadRequest.send();
  //     final response = await http.Response.fromStream(streamResponse);
  //
  //     return responses(response);
  //   } on SocketException {
  //     throw FetchDataException('No Internet connection');
  //   } catch (e, stackTrace) {
  //     throw Exception('Error: $e &&& \n strace error $stackTrace');
  //   }
  // }
  // Future<http.Response> getgroupmsgapi(String GroupId, UserId) async {
  //   String url = '${baseUrl}/group-chat/$GroupId/$UserId';
  //   print("urlurlurlurlurlurlurlurlurlurlurlurlurl>>>>>>${url}");
  //   print(url);
  //   var responseJson;
  //   final response = await http
  //       .get(
  //     Uri.parse(url),
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> Friendrequestapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/friend-request-chat';
  //   print("Friend request Url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> GetFriendListapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/list-friends-requests';
  //   print("Friend list request Url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> addpostapWithImages({
  //   required Map<String, String> bodyData,
  //   required List<XFile> images,
  // }) async {
  //   const url = '${baseUrl}/post_create_app';
  //   print("Post request URL: $url");
  //
  //   var request = http.MultipartRequest('POST', Uri.parse(url));
  //
  //   request.fields.addAll(bodyData);
  //
  //   for (int i = 0; i < images.length; i++) {
  //     final mimeType = lookupMimeType(images[i].path);
  //
  //     if (mimeType != null) {
  //       final mimeSplit = mimeType.split('/');
  //       var file = await http.MultipartFile.fromPath(
  //         'user_feed_image[$i]',
  //         images[i].path,
  //         contentType: MediaType(mimeSplit[0], mimeSplit[1]),
  //       );
  //       request.files.add(file);
  //       log("Added image: ${images[i].path} as user_feed_image[$i] with MIME type $mimeType");
  //     } else {
  //       log("Skipping image: ${images[i].path} - MIME type not detected");
  //     }
  //   }
  //
  //   var streamedResponse = await request.send().timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //
  //   final response = await http.Response.fromStream(streamedResponse);
  //   print("Response: ${response.body}");
  //   return response;
  // }
  // Future<http.Response> postlikeapii(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/add-like-comment';
  //   print("post like send Url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> getcommentsapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/get-post-comments';
  //   print("get comments list request Url: $url");
  //   try {
  //     final response = await http.post(Uri.parse(url), body: bodyData).timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw SocketException('Request timed out');
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> DeletePost(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/app-post-delete';
  //   print("get comments list request Url: $url");
  //   try {
  //     final response = await http.post(Uri.parse(url), body: bodyData).timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw SocketException('Request timed out');
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
// Future<http.Response> getcommentslocalpostap(
  //     Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/get-post-comments';
  //   print("get comments list request Url: $url");
  //   try {
  //     final response = await http.post(Uri.parse(url), body: bodyData).timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw SocketException('Request timed out');
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> sendcommentsapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/add-like-comment';
  //   print("send comments list request Url: $url");
  //   try {
  //     final response = await http.post(Uri.parse(url), body: bodyData).timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw SocketException('Request timed out');
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> getgroupmembers(
  //   String GroupId,
  // ) async {
  //   String url = '${baseUrl}/group-member/$GroupId';
  //   print("group members url${url}");
  //   print(url);
  //   var responseJson;
  //   final response = await http
  //       .get(
  //     Uri.parse(url),
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> RemoveGroupmemberapi(
  //     Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/remove-group-member';
  //   print("remove group Url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> AddGroupmemberapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/add-group-member';
  //   print("add group member Url : $url");
  //   var responseJson;
  //   final response = await http
  //       .post(
  //     Uri.parse(url),
  //     body: bodyData,
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> deletegroup(String GroupId, id) async {
  //   String url = '${baseUrl}/delete-my-group/$GroupId?user_id=$id';
  //   print("Delete group url${url}");
  //   print(url);
  //   var responseJson;
  //   final response = await http
  //       .get(
  //     Uri.parse(url),
  //   )
  //       .timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   responseJson = responses(response);
  //   print(response.body);
  //   return responseJson;
  // }
  // Future<http.Response> GetRequestApi(String user_id) async {
  //   String url = '${baseUrl}/get_request_app?user_id=$user_id';
  //   print("Get Request person  Url : $url");
  //   try {
  //     final response = await http
  //         .get(Uri.parse(url))
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       log("lat");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> AppFrienduserpersonalinfo(
  //   Map<String, String> bodyData,
  // ) async {
  //   const url = '${baseUrl}/residents-app-view';
  //   print("send comments list request Url: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> UpdatePost({
  //   required Map<String, String> bodyData,
  //   required List<File> images,
  // }) async {
  //   const url = '${baseUrl}/app_post_update_feed';
  //   print("Post request URL: $url");
  //   var request = http.MultipartRequest('POST', Uri.parse(url));
  //   request.fields.addAll(bodyData);
  //   for (int i = 0; i < images.length; i++) {
  //     final mimeType = lookupMimeType(images[i].path);
  //     if (mimeType != null) {
  //       final mimeSplit = mimeType.split('/');
  //       var file = await http.MultipartFile.fromPath(
  //         'feed_image[$i]',
  //         images[i].path,
  //         contentType: MediaType(mimeSplit[0], mimeSplit[1]),
  //       );
  //       request.files.add(file);
  //       log(
  //         "Added image: ${images[i].path} as feed_image[$i] with MIME type $mimeType",
  //       );
  //     } else {
  //       log("Skipping image: ${images[i].path} - MIME type not detected");
  //     }
  //   }
  //   var streamedResponse = await request.send().timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       throw const SocketException('Something went wrong');
  //     },
  //   );
  //   final response = await http.Response.fromStream(streamedResponse);
  //   print("Response: ${response.body}");
  //   return response;
  // }
// }