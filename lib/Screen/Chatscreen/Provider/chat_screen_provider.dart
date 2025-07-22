// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../../../comman/const.dart';

// class ChatProvider extends ChangeNotifier {
//   Future<http.Response> ChatApi(user_id, lon, lat) async {
//     final url =
//         '$baseUrl/get-concierge?user_id=$user_id&longitude=$lon&latitude=$lat';
//
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
//
//     try {
//       final response = await http.post(Uri.parse(url), body: bodyData).timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw SocketException('Request timed out');
//         },
//       );
//       if (response.statusCode == 200) {
//
//         return response;
//       } else {
//
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

import '../../../comman/apiConfig.dart'; // For DioHelper
import '../../../comman/apiEndpoint.dart'; // Optional if using endpoints constants
import '../../../comman/const.dart';
import '../../../comman/store_local.dart';

class ChatProvider extends ChangeNotifier {
  Future<Response> chatApi(String userId, String lon, String lat) async {
    try {
      final dio = await DioHelper.getDio();
      log(
        '${ApiEndpoint.getConcierge}?user_id=$userId&longitude=$lon&latitude=$lat',
      );
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final response = await dio.get(
        '${ApiEndpoint.getConcierge}?user_id=$userId&longitude=$lon&latitude=$lat',
        options: Options(headers: {'X-Auth-Token': token ?? ''}),

        // queryParameters: {'user_id': userId, 'longitude': lon, 'latitude': lat},
      );
      log("Sucess");

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<Response> chatStoryApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
       ApiEndpoint.allStory,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),

      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}
