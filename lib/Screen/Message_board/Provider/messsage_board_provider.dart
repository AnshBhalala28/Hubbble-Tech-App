import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../../comman/CustomExpection.dart';
import '../../../comman/const.dart';
import '../../../comman/responses.dart';

class MessageBoardProvider extends ChangeNotifier {
  Future<http.Response> conciergerlistApi(
    String user_id,
  ) async {
    String url = '${baseUrl}/list-concierger?user_id=$user_id';
    print("Get conciergerlist Url : $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> getgrouplistapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/get-my-group';
    print("post Dwell time Url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> GetMyJoinGroup(Map<String, String> bodyData) async {
    const url = '${baseUrl}/my-joined-groups';
    print("post Dwell time Url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> localpostap(Map<String, String> bodyData) async {
    const url = '${baseUrl}/get_post_app';
    print("localpost url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> creategroupapi(
      Map<String, String> bodyData, List<String> memberIds,
      {File? imageFile}) async {
    const url = '${baseUrl}/add-group';
    print("Request URL: $url");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      bodyData.forEach((key, value) {
        request.fields[key] = value;
      });

      for (int i = 0; i < memberIds.length; i++) {
        request.fields['members[$i]'] = memberIds[i];
        log("Member id jay che ${memberIds[i]}");
      }

      if (imageFile != null) {
        var fileStream = http.ByteStream(imageFile.openRead());
        var fileLength = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images',
          fileStream,
          fileLength,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', imageFile.path.split('.').last),
        );

        request.files.add(multipartFile);
        print("Image added to request: ${imageFile.path}");
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> sendmessageapi(Map<String, String> bodyData) async {
    const url = '$baseUrl/send-message';
    print("Request URL: $url");

    try {
      final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));

      bodyData.forEach((key, value) {
        if (key != 'files') {
          imageUploadRequest.fields[key] = value;
        }
      });

      if (bodyData['files']?.isNotEmpty ?? false) {
        final String filePath = bodyData['files']!;

        print('Uploading file: $filePath');

        String fileExtension = filePath.split('.').last.toLowerCase();
        MediaType mediaType;

        switch (fileExtension) {
          case "jpg":
          case "jpeg":
          case "png":
            mediaType = MediaType('image', fileExtension);
            break;
          case "mp4":
            mediaType = MediaType('video', 'mp4');
            break;
          case "pdf":
            mediaType = MediaType('application', 'pdf');
            break;
          default:
            throw Exception('Unsupported media type');
        }

        final file = await http.MultipartFile.fromPath(
          'files',
          filePath,
          contentType: mediaType,
        );
        imageUploadRequest.files.add(file);
      }

      final streamResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamResponse);

      return responses(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e, stackTrace) {
      throw Exception('Error: $e &&& \n strace error $stackTrace');
    }
  }

  Future<http.Response> getgroupmsgapi(String GroupId, UserId) async {
    String url = '${baseUrl}/group-chat/$GroupId/$UserId';
    print("urlurlurlurlurlurlurlurlurlurlurlurlurl>>>>>>${url}");
    print(url);
    var responseJson;
    final response = await http
        .get(
      Uri.parse(url),
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> Friendrequestapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/friend-request-chat';
    print("Friend request Url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> GetFriendListapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/list-friends-requests';
    print("Friend list request Url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> addpostapWithImages({
    required Map<String, String> bodyData,
    required List<XFile> images,
  }) async {
    const url = '${baseUrl}/post_create_app';
    print("Post request URL: $url");

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields.addAll(bodyData);

    for (int i = 0; i < images.length; i++) {
      final mimeType = lookupMimeType(images[i].path);

      if (mimeType != null) {
        final mimeSplit = mimeType.split('/');
        var file = await http.MultipartFile.fromPath(
          'user_feed_image[$i]',
          images[i].path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        );
        request.files.add(file);
        log("Added image: ${images[i].path} as user_feed_image[$i] with MIME type $mimeType");
      } else {
        log("Skipping image: ${images[i].path} - MIME type not detected");
      }
    }

    var streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );

    final response = await http.Response.fromStream(streamedResponse);
    print("Response: ${response.body}");
    return response;
  }

  Future<http.Response> postlikeapii(Map<String, String> bodyData) async {
    const url = '${baseUrl}/add-like-comment';
    print("post like send Url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> getcommentsapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/get-post-comments';
    print("get comments list request Url: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> DeletePost(Map<String, String> bodyData) async {
    const url = '${baseUrl}/app-post-delete';
    print("get comments list request Url: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> getcommentslocalpostap(
      Map<String, String> bodyData) async {
    const url = '${baseUrl}/get-post-comments';
    print("get comments list request Url: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> sendcommentsapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/add-like-comment';
    print("send comments list request Url: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> getgroupmembers(
    String GroupId,
  ) async {
    String url = '${baseUrl}/group-member/$GroupId';
    print("group members url${url}");
    print(url);
    var responseJson;
    final response = await http
        .get(
      Uri.parse(url),
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> RemoveGroupmemberapi(
      Map<String, String> bodyData) async {
    const url = '${baseUrl}/remove-group-member';
    print("remove group Url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> AddGroupmemberapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/add-group-member';
    print("add group member Url : $url");
    var responseJson;
    final response = await http
        .post(
      Uri.parse(url),
      body: bodyData,
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> deletegroup(String GroupId, id) async {
    String url = '${baseUrl}/delete-my-group/$GroupId?user_id=$id';
    print("Delete group url${url}");
    print(url);
    var responseJson;
    final response = await http
        .get(
      Uri.parse(url),
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> GetRequestApi(
    String user_id,
  ) async {
    String url = '${baseUrl}/get_request_app?user_id=$user_id';
    print("Get Request person  Url : $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> AppFrienduserpersonalinfo(
      Map<String, String> bodyData) async {
    const url = '${baseUrl}/residents-app-view';
    print("send comments list request Url: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> UpdatePost({
    required Map<String, String> bodyData,
    required List<File> images,
  }) async {
    const url = '${baseUrl}/app_post_update_feed';
    print("Post request URL: $url");

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields.addAll(bodyData);

    for (int i = 0; i < images.length; i++) {
      final mimeType = lookupMimeType(images[i].path);

      if (mimeType != null) {
        final mimeSplit = mimeType.split('/');
        var file = await http.MultipartFile.fromPath(
          'feed_image[$i]',
          images[i].path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        );
        request.files.add(file);
        log("Added image: ${images[i].path} as feed_image[$i] with MIME type $mimeType");
      } else {
        log("Skipping image: ${images[i].path} - MIME type not detected");
      }
    }

    var streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Something went wrong');
      },
    );

    final response = await http.Response.fromStream(streamedResponse);
    print("Response: ${response.body}");
    return response;
  }
}
