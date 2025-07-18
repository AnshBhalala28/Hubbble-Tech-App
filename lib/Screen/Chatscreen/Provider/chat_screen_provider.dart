// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../../../comman/const.dart';

// class ChatProvider extends ChangeNotifier {
//   Future<http.Response> ChatApi(user_id, lon, lat) async {
//     final url =
//         '$baseUrl/get-concierge?user_id=$user_id&longitude=$lon&latitude=$lat';
//     print("Request Chat URL: $url");
//     try {
//       final response = await http
//           .get(
//         Uri.parse(url),
//       )
//           .timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw const SocketException('Request timed out');
//         },
//       );
//       if (response.statusCode == 200) {
//         log("Successful response: ${response.body}");
//         return response;
//       } else {
//         log("Failed response: ${response.statusCode}");
//         throw Exception("Failed to connect to the server");
//       }
//     } on SocketException catch (e) {
//       throw Exception('No Internet connection: $e');
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }

//   Future<http.Response> ChatStoryApi(Map<String, String> bodyData) async {
//     const url = '${baseUrl}/allStoryPostsGetApp';
//     print("Request URL: $url");
//     try {
//       final response = await http.post(Uri.parse(url), body: bodyData).timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw SocketException('Request timed out');
//         },
//       );
//       if (response.statusCode == 200) {
//         print("Successful response: ${response.body}");
//         return response;
//       } else {
//         print("Failed response: ${response.statusCode}");
//         throw Exception("Failed to connect to the server");
//       }
//     } on SocketException catch (e) {
//       throw Exception('No Internet connection: $e');
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
// }
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/responses.dart';
import '../../../comman/const.dart';
import '../../../comman/apiConfig.dart'; // For DioHelper
import '../../../comman/apiEndpoint.dart'; // Optional if using endpoints constants

class ChatProvider extends ChangeNotifier {
  Future<Response> chatApi(String userId, String lon, String lat) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        '$baseUrl/get-concierge',
        queryParameters: {'user_id': userId, 'longitude': lon, 'latitude': lat},
      );
      log("✅ Chat API Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      log("❌ Dio Error: ${e.message}");
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<Response> chatStoryApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        '$baseUrl/allStoryPostsGetApp',
        data: bodyData,
      );
      log("✅ Chat Story Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      log("❌ Dio Error: ${e.message}");
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}
