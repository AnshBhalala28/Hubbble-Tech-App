import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../comman/const.dart';

class MyRequestProvider extends ChangeNotifier {
  Future<http.Response> GetMyRequest(
    String user_id,
  ) async {
    String url = '${baseUrl}/get_request_my?user_id=$user_id';
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

  Future<http.Response> GetFriendRequest(
    String user_id,
  ) async {
    String url = '${baseUrl}/get_request_app?user_id=$user_id';
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

  Future<http.Response> GetMyGroupApi(
    String user_id,
  ) async {
    String url = '${baseUrl}/resident_group_request?user_id=$user_id';
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

  Future<http.Response> RequestActionApi(Map<String, String> bodyData) async {
    String url = '${baseUrl}/friends-request-action';
    print("Actioon Api  $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
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

  Future<http.Response> RequestActionGroupApi(
      Map<String, String> bodyData) async {
    String url = '${baseUrl}/group-request-action';
    print("Actioon Api  $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
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
