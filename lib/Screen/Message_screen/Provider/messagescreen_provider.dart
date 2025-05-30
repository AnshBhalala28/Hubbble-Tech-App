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
      String user_id, String concierge_id, String type) async {
    final String url = '$baseUrl/get-chat/$user_id/$concierge_id?type=$type';
    // final url = '$baseUrl/get-chat/$user_id/$concierge_id';
    print("Request URL: $url");
    print("concierge_id: $concierge_id");
    print("type: $type");
    print("user_id: $user_id");
    try {
      final response = await http
          .get(
        Uri.parse(url),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw const SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        log("Successful response: ${response.body}");
        return response;
      } else {
        log("Failed response: ${response.statusCode}");
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
      // Prepare a multipart request for both text and files
      final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));

      // Add text fields to the request (skip 'files' as we handle them separately)
      bodyData.forEach((key, value) {
        if (key != 'files') {
          // Exclude 'files' field from text fields
          imageUploadRequest.fields[key] = value;
        }
      });

      // Check if there are files to upload
      if (bodyData['files']?.isNotEmpty ?? false) {
        final String filePath = bodyData['files']!;

        // Log the file path for debugging
        print('Uploading file: $filePath');

        // Determine the media type based on the file extension or other logic
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

        // Add the file as an array of files
        final file = await http.MultipartFile.fromPath(
          'files', // Important: note the array-like naming 'files[]'
          filePath,
          contentType: mediaType,
        );
        imageUploadRequest.files.add(file);
      }

      // Send the request and get the response
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
    print("Request URL: $url");
    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: bodyData,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw const SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        log("Successful response: ${response.body}");
        return response;
      } else {
        log("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> removefriend(
    String ConId,
  ) async {
    String url = '${baseUrl}/remove-friends/$ConId';
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

  Future<http.Response> userpersonalinfo(
    String ConId,
  ) async {
    String url = '${baseUrl}/concierge-friends-profile/$ConId';
    print("userpersonalinfo url${url}");
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
}
