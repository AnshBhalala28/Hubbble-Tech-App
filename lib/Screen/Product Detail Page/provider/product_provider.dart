import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../comman/const.dart';

class ProductProvider extends ChangeNotifier {


  // Future<http.Response> ProductDetailApi(String UserId, productid) async {
  //   String url =
  //       '${baseUrl}/getProductDetails?user_id=$UserId&product_id=$productid';
  //   print("Business Profile Url : $url");
  //   try {
  //     final response = await http.get(Uri.parse(url)).timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw SocketException('Request timed out');
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       log("lat");
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


  Future<http.Response> ProductDetailApi(String UserId, String productid, String type) async {
    String url =
        '${baseUrl}/getProductDetails?user_id=$UserId&id=$productid&type=$type';
    print("Product Detail Url : $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> AddReviewApi(Map<String, String> bodyData) async {
    const url = '$baseUrl/add-review';
    print("Request URL: $url");
    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: bodyData,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw const SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        log("Successful response: ${response.body}");
        return response;
      } else {
        log("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> ShowAllReviewApi(String productid) async {
    String url = '${baseUrl}/show-reviews?product_id=$productid';
    print("Business Profile Url : $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> AddToCart(Map<String, String> bodyData) async {
    const url = '$baseUrl/addToCart';
    print("Request URL: $url");
    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: bodyData,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw const SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        log("Successful response: ${response.body}");
        return response;
      } else {
        log("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
