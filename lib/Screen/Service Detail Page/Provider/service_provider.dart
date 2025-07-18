import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';
// class ServiceProvider extends ChangeNotifier {
//   Future<http.Response> ServiceDetailApi(
//       String UserId, String serviceid, String type) async {
//     String url =
//         '${baseUrl}/getProductDetails?user_id=$UserId&id=$serviceid&type=$type';
//     print("Product Detail Url : $url");
//     try {
//       final response = await http.get(Uri.parse(url)).timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw SocketException('Request timed out');
//         },
//       );
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

class ServiceProvider extends ChangeNotifier {
  Future<Response> serviceDetailApi(
    String UserId,
    String productid,
    String type,
  ) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.productDetail,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': UserId, "id": productid, 'type': type},
      );
      print("Login Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
