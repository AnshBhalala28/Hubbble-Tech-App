import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class CartProvider extends ChangeNotifier {
  Future<Response> cartDetailApi(id) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.cartDetail,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': id},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> updateCartQuantityApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.post(
        ApiEndpoint.updateCartQuantity,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> removeCartApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.post(
        ApiEndpoint.removeFromCart,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}

// class CartProvider extends ChangeNotifier {
//   Future<http.Response> GetCartDetailsApi(String UserId) async {
//     String url = '${baseUrl}/getCart?user_id=$UserId';
//     
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
//   Future<http.Response> UpdateCartQuantity(Map<String, String> bodyData) async {
//     const url = '$baseUrl/updateCartQuantity';
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
//   Future<http.Response> RemoveFromCartApi(Map<String, String> bodyData) async {
//     const url = '$baseUrl/removeFromCart';
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
