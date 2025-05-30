import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../comman/const.dart';

class CheckoutProvider extends ChangeNotifier {
  Future<http.Response> ProductCheckoutApi(Map<String, String> bodyData) async {
    const url = '$baseUrl/placeOrder';
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
}
