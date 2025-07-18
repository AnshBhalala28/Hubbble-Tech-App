import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/store_local.dart';
import '../../../comman/apiConfig.dart';
import '../../../comman/apiEndpoint.dart';
import '../../../comman/responses.dart';
//
// class HomeProvider extends ChangeNotifier {
//   Future<http.Response> ParcerShowCount(Map<String, String> bodyData) async {
//     const url = '$baseUrl/get-parcel-data';
//     print("Request URL: $url");
//     try {
//       final response = await http
//           .post(
//         Uri.parse(url),
//         body: bodyData,
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
//
//   Future<http.Response> VisitorShowCount(Map<String, String> bodyData) async {
//     const url = '$baseUrl/view-visitor';
//     print("Request URL: $url");
//     try {
//       final response = await http
//           .post(
//         Uri.parse(url),
//         body: bodyData,
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
//
//   Future<http.Response> LatestVisitor(Map<String, String> bodyData) async {
//     const url = '$baseUrl/view-visitor';
//     log("Request URL: $url");
//     try {
//       final response = await http
//           .post(
//         Uri.parse(url),
//         body: bodyData,
//       )
//           .timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw const SocketException('Request timed out');
//         },
//       );
//       if (response.statusCode == 200) {
//         log("Successful Ave che: ${response.body}");
//         return response;
//       } else {
//         log("Failed response error ave che: ${response.statusCode}");
//         throw Exception("Failed to connect to the servers ");
//       }
//     } on SocketException catch (e) {
//       throw Exception('No Internet connection: $e');
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
//
//   Future<http.Response> ChatShowCount(Map<String, String> bodyData) async {
//     String url = '${baseUrl}/get-total-new-messages';
//     print("Business Profile Url : $url");
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
//
//   Future<http.Response> MessageBoardApi(Map<String, String> bodyData) async {
//     const url = '$baseUrl/message-board';
//     print("Request URL: $url");
//     try {
//       final response = await http
//           .post(
//         Uri.parse(url),
//         body: bodyData,
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
// }

class HomeProvider extends ChangeNotifier {
  Future<Response> parcelShowCountApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.parcel,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> visitorShowCountApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      log("Auth T");
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.visitor,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> chatCountApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.chatCount,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> messageBoardApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.messageBoard,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      print("Login Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
