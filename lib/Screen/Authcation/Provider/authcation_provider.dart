import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import '../../../comman/apiConfig.dart';
import 'package:dio/dio.dart';
import '../../../comman/responses.dart';

// class AuthProvider extends ChangeNotifier {
//   Future<http.Response> LoginApi(Map<String, String> bodyData) async {
//     const url = '${baseUrl}/login';
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
//
//   Future<http.Response> ForgotApi(Map<String, String> bodyData) async {
//     const url = '${baseUrl}/forget-password';
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
//
//   Future<http.Response> DeleteAccount(String id) async {
//     final url = '${baseUrl}/delete-resident-app?id=$id';
//
//
//     try {
//       final response = await http
//           .delete(Uri.parse(url))
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw SocketException('Request timed out');
//             },
//           );
//
//
//
//
//       if (response.statusCode == 200) {
//         return response;
//       } else {
//         throw Exception(
//           "Failed to connect to the server, Status Code: ${response.statusCode}",
//         );
//       }
//     } on SocketException catch (e) {
//       throw Exception('No Internet connection: $e');
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
//
//   Future<http.Response> Logout(Map<String, String> bodyData) async {
//     const url = '${baseUrl}/api-logout';
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

class AuthProvider extends ChangeNotifier {
  Future<Response> loginApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(ApiEndpoint.login, data: bodyData);
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> forgetPasswordApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.forgetPassword,
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> deleteAccApi(id) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.delete(
        ApiEndpoint.deleteAccount,
        queryParameters: {'id': id},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> logoutApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      final response = await dio.post(ApiEndpoint.logout, data: bodyData);

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
