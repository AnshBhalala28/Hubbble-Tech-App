import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

// class VisitorProvider extends ChangeNotifier {
//   Future<http.Response> VisitorApi(Map<String, String> bodyData) async {
//     const url = '${baseUrl}/add-visitor';
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
class VisitorProvider extends ChangeNotifier {
  Future<Response> visitorApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

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
}
