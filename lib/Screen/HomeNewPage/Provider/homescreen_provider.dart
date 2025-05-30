import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../comman/const.dart';

class HomeProvider extends ChangeNotifier {
  Future<http.Response> ParcerShowCount(Map<String, String> bodyData) async {
    const url = '$baseUrl/get-parcel-data';
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

  Future<http.Response> VisitorShowCount(Map<String, String> bodyData) async {
    const url = '$baseUrl/view-visitor';
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

  Future<http.Response> LatestVisitor(Map<String, String> bodyData) async {
    const url = '$baseUrl/view-visitor';
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
        log("Successful Ave che: ${response.body}");
        return response;
      } else {
        log("Failed response error ave che: ${response.statusCode}");
        throw Exception("Failed to connect to the servers ");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> ChatShowCount(Map<String, String> bodyData) async {
    String url = '${baseUrl}/get-total-new-messages';
    print("Business Profile Url : $url");
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

  Future<http.Response> MessageBoardApi(Map<String, String> bodyData) async {
    const url = '$baseUrl/message-board';
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

// Future<http.Response> Notification(String UserId) async {
//   String url = '${baseUrl}/Appnotification?user_id=$UserId';
//   print("Notification Url  : $url");
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
}
