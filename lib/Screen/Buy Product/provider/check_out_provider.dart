// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;

// import '../../../../comman/const.dart';

// class CheckoutProvider extends ChangeNotifier {
//   Future<http.Response> ProductCheckoutApi(Map<String, String> bodyData) async {
//     const url = '$baseUrl/placeOrder';
//
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

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

import '../../../../comman/apiEndpoint.dart';
import '../../../../comman/apiConfig.dart'; // For DioHelper and handleDioError

class CheckoutProvider extends ChangeNotifier {
  Future<Response> productCheckoutApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.placeOrder,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong.");
    }
  }
}
