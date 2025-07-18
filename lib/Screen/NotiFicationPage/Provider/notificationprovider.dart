import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

// class NotificationProvider extends ChangeNotifier {
//   // Future<http.Response> NotificationApi(String UserId) async {
//   //   String url = '${baseUrl}/Appnotification?user_id=$UserId';
//   //   print("Notification Url  : $url");
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
//   //       print("Successful response: ${response.body}");
//   //       log("lat");
//   //       return response;
//   //     } else {
//   //       print("Failed response: ${response.statusCode}");
//   //       throw Exception("Failed to connect to the server");
//   //     }
//   //   } on SocketException catch (e) {
//   //     throw Exception('No Internet connection: $e');
//   //   } catch (e) {
//   //     throw Exception('An error occurred: $e');
//   //   }
//   // }

//   Future<http.Response> ReadNotificationApi(String UserId) async {
//     String url = '${baseUrl}/notifications-read?user_id=$UserId';
//     print("Notification Url  : $url");
//     try {
//       final response = await http
//           .get(Uri.parse(url))
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw SocketException('Request timed out');
//             },
//           );
//       if (response.statusCode == 200) {
//         print("Successful response: ${response.body}");
//         log("lat");
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

class NotificationProvider extends ChangeNotifier {
  Future<Response> notificationApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.appNotification,
        queryParameters: {'user_id': userId},
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> notificationReadApi(String userId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.notificatonRead,
        queryParameters: {'user_id': userId},
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
