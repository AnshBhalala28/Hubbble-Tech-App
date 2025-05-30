import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../comman/const.dart';

class ParcelProvider extends ChangeNotifier {
  Future<http.Response> ParcelApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/get-parcel-data';
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
