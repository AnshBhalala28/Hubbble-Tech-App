import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../comman/CustomExpection.dart';
import '../../../comman/const.dart';
import '../../../comman/responses.dart';

class MessageProvider extends ChangeNotifier {
  Future<http.Response> MessageApi(
    String user_id,
    String concierge_id,
    String type,
    String orderproductid,
  ) async {
    final String url =
        '$baseUrl/get-chat/$user_id/$concierge_id?type=$type&order_product_id=$orderproductid';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw const SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        return response;
      } else {
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

    try {
      final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));

      bodyData.forEach((key, value) {
        if (key != 'files') {
          imageUploadRequest.fields[key] = value;
        }
      });

      if (bodyData['files']?.isNotEmpty ?? false) {
        final String filePath = bodyData['files']!;

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

  Future<http.Response> SendMessagApi(Map<String, String> bodyData) async {
    const url = '$baseUrl/send-message';

    try {
      final response = await http
          .post(Uri.parse(url), body: bodyData)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw const SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> removefriend(String ConId) async {
    String url = '${baseUrl}/remove-friends/$ConId';

    var responseJson;
    final response = await http
        .get(Uri.parse(url))
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);

    return responseJson;
  }

  Future<http.Response> userpersonalinfo(String ConId) async {
    String url = '${baseUrl}/concierge-friends-profile/$ConId';

    var responseJson;
    final response = await http
        .get(Uri.parse(url))
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);

    return responseJson;
  }

  Future<http.Response> sendmessageorderapi(
    Map<String, String> data,
    File? file,
  ) async {
    var uri = Uri.parse("https://portal.wavee.ai/api/sendOrderChat");
    var request = http.MultipartRequest("POST", uri);

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (file != null && file.existsSync()) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    try {
      var streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e, stackTrace) {
      log('Error in sendmessageorderapi: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }
}
