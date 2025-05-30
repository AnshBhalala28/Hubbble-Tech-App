import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../comman/const.dart';

class ServiceProvider extends ChangeNotifier {


  Future<http.Response> ServiceDetailApi(String UserId, String serviceid, String type) async {
    String url =
        '${baseUrl}/getProductDetails?user_id=$UserId&id=$serviceid&type=$type';
    print("Product Detail Url : $url");
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


}
