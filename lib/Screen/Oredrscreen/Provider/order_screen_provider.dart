import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

// class OrderProvider extends ChangeNotifier {
//   // Future<http.Response> OrderListApi(String userID, status, type) async {
//   //   String url = '$baseUrl/myOrders?user_id=$userID&status=$status&type=$type';
//   //
//   //   try {
//   //     final response = await http
//   //         .get(Uri.parse(url))
//   //         .timeout(
//   //           const Duration(seconds: 60),
//   //           onTimeout: () {
//   //             throw const SocketException('Request timed out');
//   //           },
//   //         );
//   //     if (response.statusCode == 200) {
//   //       log("Successful response: ${response.body}");
//   //       return response;
//   //     } else {
//   //       log("Failed response: ${response.statusCode}");
//   //       throw Exception("Failed to connect to the server");
//   //     }
//   //   } on SocketException catch (e) {
//   //     throw Exception('No Internet connection: $e');
//   //   } catch (e) {
//   //     throw Exception('An error occurred: $e');
//   //   }
//   // }

//   // Future<http.Response> OrderDetailApi(
//   //   String userID,
//   //   orderid,
//   //   orderProductID,
//   // ) async {
//   //   String url =
//   //       '$baseUrl/orderDetails?user_id=$userID&order_id=$orderid&order_product_id=$orderProductID';
//   //
//   //   try {
//   //     final response = await http
//   //         .get(Uri.parse(url))
//   //         .timeout(
//   //           const Duration(seconds: 60),
//   //           onTimeout: () {
//   //             throw const SocketException('Request timed out');
//   //           },
//   //         );
//   //     if (response.statusCode == 200) {
//   //       log("Successful response: ${response.body}");
//   //       return response;
//   //     } else {
//   //       log("Failed response: ${response.statusCode}");
//   //       throw Exception("Failed to connect to the server");
//   //     }
//   //   } on SocketException catch (e) {
//   //     throw Exception('No Internet connection: $e');
//   //   } catch (e) {
//   //     throw Exception('An error occurred: $e');
//   //   }
//   // }

//   Future<http.Response> CancleOrder(Map<String, String> bodyData) async {
//     String url = '$baseUrl/cancelOrder';
//
//     try {
//       final response = await http
//           .post(Uri.parse(url), body: bodyData)
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw const SocketException('Request timed out');
//             },
//           );
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

class OrderProvider extends ChangeNotifier {
  Future<Response> orderListApi(String userID, status, type) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      log(
        "data url${ApiEndpoint.myOrder}?user_id=$userID&type=$type&status=$status",
      );
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.myOrder}?user_id=$userID&type=$type&status=$status",
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        // queryParameters: {'user_id': userID, 'status': status, 'type': type},
      );
      log("Sucess APi call");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> orderDetailApi(
    String userID,
    orderid,
    orderProductID,
  ) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
log(
  "${ApiEndpoint.myOrderDetail}user_id=$userID&order_id=$orderid&order_product_id=$orderProductID",

);
      final dio = await DioHelper.getDio();
      final response = await dio.get(
       "${ApiEndpoint.myOrderDetail}user_id=$userID&order_id=$orderid&order_product_id=$orderProductID",
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        // queryParameters: {
        //   'user_id': userID,
        //   'order_id': orderid,
        //   'order_product_id': orderProductID,
        // },
      );
      log("sucess");

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> cancleOrderApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.cancleOrder,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
