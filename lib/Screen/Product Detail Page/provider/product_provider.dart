import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

// class ProductProvider extends ChangeNotifier {
//   // Future<http.Response> ProductDetailApi(
//   //   String UserId,
//   //   String productid,
//   //   String type,
//   // ) async {
//   //   String url =
//   //       '${baseUrl}/getProductDetails?user_id=$UserId&id=$productid&type=$type';
//   //   print("Product Detail Url : $url");
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
//   // Future<http.Response> AddReviewApi(Map<String, String> bodyData) async {
//   //   const url = '$baseUrl/add-review';
//   //   print("Request URL: $url");
//   //   try {
//   //     final response = await http
//   //         .post(Uri.parse(url), body: bodyData)
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
//   // Future<http.Response> ShowAllReviewApi(String productid) async {
//   //   String url = '${baseUrl}/show-reviews?product_id=$productid';
//   //   print("Business Profile Url : $url");
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
//   Future<http.Response> AddToCart(Map<String, String> bodyData) async {
//     const url = '$baseUrl/addToCart';
//     print("Request URL: $url");
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

class ProductProvider extends ChangeNotifier {
  Future<Response> productDetailApi(
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

  Future<Response> addReviewApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.addReview,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> showAllReviewApi(String productid) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.productDetail,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {"product_id": productid},
      );
      print("Login Success: ${response.data}");
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> AddToCart(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.addtocart,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
