import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  Future<http.Response> SignUpApi(Map<String, String> bodyData) async {
    const url = 'https://pets.wavee.ai/api/app_register';

    try {
      final response = await http
          .post(Uri.parse(url), body: bodyData)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );

      return response;
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
