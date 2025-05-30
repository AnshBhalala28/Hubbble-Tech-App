import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../comman/const.dart';

class AuthProvider extends ChangeNotifier {
  Future<http.Response> LoginApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/login';
    print("Request URL: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> ForgotApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/forget-password';
    print("Request URL: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Future<http.Response> DeleteAccount(Map<String, String> bodyData) async {
  //   LoginModel? userData = await SaveDataLocal.getDataFromLocal();
  //   String token = userData?.data?.token ?? '';
  //   print("my token is cpdfsdf:: ${token}");
  //   if (token.isEmpty) {
  //     throw Exception('Token not found');
  //   }
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer $token',
  //   };
  //   const url = '${baseUrl}/delete-account';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData, headers: headers)
  //         .timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw SocketException('Request timed out');
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  Future<http.Response> DeleteAccount(String id) async {
    // LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    // String token = userData?.data?.token ?? '';
    // print("my token ave che :: ${token}");
    //
    // if (token.isEmpty) {
    //   throw Exception('Token not found');
    // }
    //
    // Map<String, String> headers = {
    //   'Authorization': 'Bearer $token',
    // };

    final url = '${baseUrl}/delete-resident-app?id=$id';
    print("Request URL: $url");

    try {
      final response = await http
          .delete(
        Uri.parse(url),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );

      print("Server Response Code: ${response.statusCode}");
      print("Server Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            "Failed to connect to the server, Status Code: ${response.statusCode}");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
