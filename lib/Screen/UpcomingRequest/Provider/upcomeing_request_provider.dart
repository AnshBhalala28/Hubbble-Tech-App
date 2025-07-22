import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../comman/const.dart';
import 'package:dio/dio.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

// class MyRequestProvider extends ChangeNotifier {
//   // Future<http.Response> GetMyRequest(String user_id) async {
//   //   String url = '${baseUrl}/get_request_my?user_id=$user_id';
//   //
//   //   try {
//   //     final response = await http
//   //         .get(Uri.parse(url))
//   //         .timeout(
//   //           const Duration(seconds: 60),
//   //           onTimeout: () {
//   //             throw SocketException('Request timed out');
//   //           },
//   //         );
//   //     if (response.statusCode == 200) {
//   //
//   //       log("lat");
//   //       return response;
//   //     } else {
//   //
//   //       throw Exception("Failed to connect to the server");
//   //     }
//   //   } on SocketException catch (e) {
//   //     throw Exception('No Internet connection: $e');
//   //   } catch (e) {
//   //     throw Exception('An error occurred: $e');
//   //   }
//   // }

//   // Future<http.Response> GetFriendRequest(String user_id) async {
//   //   String url = '${baseUrl}/get_request_app?user_id=$user_id';
//   //
//   //   try {
//   //     final response = await http
//   //         .get(Uri.parse(url))
//   //         .timeout(
//   //           const Duration(seconds: 60),
//   //           onTimeout: () {
//   //             throw SocketException('Request timed out');
//   //           },
//   //         );
//   //     if (response.statusCode == 200) {
//   //
//   //       log("lat");
//   //       return response;
//   //     } else {
//   //
//   //       throw Exception("Failed to connect to the server");
//   //     }
//   //   } on SocketException catch (e) {
//   //     throw Exception('No Internet connection: $e');
//   //   } catch (e) {
//   //     throw Exception('An error occurred: $e');
//   //   }
//   // }

//   // Future<http.Response> GetMyGroupApi(String user_id) async {
//   //   String url = '${baseUrl}/resident_group_request?user_id=$user_id';
//   //
//   //   try {
//   //     final response = await http
//   //         .get(Uri.parse(url))
//   //         .timeout(
//   //           const Duration(seconds: 60),
//   //           onTimeout: () {
//   //             throw SocketException('Request timed out');
//   //           },
//   //         );
//   //     if (response.statusCode == 200) {
//   //
//   //       log("lat");
//   //       return response;
//   //     } else {
//   //
//   //       throw Exception("Failed to connect to the server");
//   //     }
//   //   } on SocketException catch (e) {
//   //     throw Exception('No Internet connection: $e');
//   //   } catch (e) {
//   //     throw Exception('An error occurred: $e');
//   //   }
//   // }

//   // Future<http.Response> RequestActionApi(Map<String, String> bodyData) async {
//   //   String url = '${baseUrl}/friends-request-action';
//   //
//   //   try {
//   //     final response = await http
//   //         .post(Uri.parse(url), body: bodyData)
//   //         .timeout(
//   //           const Duration(seconds: 60),
//   //           onTimeout: () {
//   //             throw SocketException('Request timed out');
//   //           },
//   //         );
//   //     if (response.statusCode == 200) {
//   //
//   //       log("lat");
//   //       return response;
//   //     } else {
//   //
//   //       throw Exception("Failed to connect to the server");
//   //     }
//   //   } on SocketException catch (e) {
//   //     throw Exception('No Internet connection: $e');
//   //   } catch (e) {
//   //     throw Exception('An error occurred: $e');
//   //   }
//   // }

//   Future<http.Response> RequestActionGroupApi(
//     Map<String, String> bodyData,
//   ) async {
//     String url = '${baseUrl}/group-request-action';
//
//     try {
//       final response = await http
//           .post(Uri.parse(url), body: bodyData)
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw SocketException('Request timed out');
//             },
//           );
//       if (response.statusCode == 200) {
//
//         log("lat");
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

class MyRequestProvider extends ChangeNotifier {
  Future<Response> myRequestApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.myRequest,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': userId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myFriendRequestApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.myFriendRequest,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': userId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myGroupRequestApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.myGroupRequest,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': userId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myRequestActionApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.myrequestAction,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> myRequestGroupActionApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.myrequestGroupAction,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
