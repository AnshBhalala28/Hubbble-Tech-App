import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../comman/const.dart';

class ProfileProvider extends ChangeNotifier {
  Future<http.Response> ProfileApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/residents-app-view';
    print("Request URL: $url");
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
        print("Failed response  ==>>>: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> ProfileEdit(  Map<String, String> bodyData, File? imageFile) async {
    const url = '${baseUrl}/update-app-resident';
    print("Request URL: $url");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // **Add Text Fields**
      bodyData.forEach((key, value) {
        request.fields[key] = value;
      });

      // **Add Image File (if selected)**
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'member_image[0]', // <-- API Parameter Name
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),

        ));
        log("image file path jay che ${imageFile.path}");
        log("image file path jay che ${imageFile}");
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
}
