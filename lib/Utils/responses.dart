import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'CustomExpection.dart';

responses(http.Response response) {
  switch (response.statusCode) {
    case 200:
      {
        if (jsonDecode(response.body)['statusCode'] == 101) {}
        return response;
      }
    case 400:
    case 422:
      return response;
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 405:
      throw UnauthorisedException(response.body.toString());
    case 429:
      Get.snackbar(
        "Server Unavailable",
        "Server's are Unavailable Please Try Again Later",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw response;
    case 500:
    default:
      throw FetchDataException(
        'Error occurred while Communication with Server with StatusCode :${response.statusCode}',
      );
  }
}

handleDioError(DioException e) {
  String? message; // make it nullable so we can skip snackbar when needed

  debugPrint("===== Dio Error Debug Info =====");
  debugPrint("Type: ${e.type}");
  debugPrint("Message: ${e.message}");
  debugPrint("Error: ${e.error}");
  debugPrint("Response : ${e.response}");
  debugPrint("StackTrace: ${e.stackTrace}");
  debugPrint("===============================");

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    message = "Request timed out. Please try again.";
  } else if (e.type == DioExceptionType.badResponse) {
    final statusCode = e.response?.statusCode ?? "Unknown";
    message = "Server error (Status Code: $statusCode)";
  } else if (e.type == DioExceptionType.unknown) {
    if (e.error is SocketException) {
      message = "No internet connection.";
    } else {
      debugPrint("Unexpected unknown Dio error: ${e.error}");
    }
  } else {
    message = "Something went wrong.";
  }
  // if (message != null && message.isNotEmpty) {
  //   Get.snackbar(
  //     "Error",
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     backgroundColor: Colors.red.withOpacity(0.1),
  //     colorText: Colors.black,
  //     margin: const EdgeInsets.all(12),
  //   );
  // }
}

// handleDioError(DioException e) {
//   String message = "";
//   if (e.type == DioExceptionType.connectionTimeout ||
//       e.type == DioExceptionType.receiveTimeout ||
//       e.type == DioExceptionType.sendTimeout) {
//     message = "Request timed out. Please try again.";
//   } else if (e.type == DioExceptionType.badResponse) {
//     final statusCode = e.response?.statusCode ?? "Unknown";
//     message = "Server error (Status Code: $statusCode)";
//   } else if (e.type == DioExceptionType.unknown) {
//     message = "No internet connection.";
//   } else {
//     message = "Something went wrong.";
//   }
//   Get.snackbar(
//     "Error",
//     message,
//     snackPosition: SnackPosition.BOTTOM,
//     backgroundColor: Colors.red.withOpacity(0.1),
//     colorText: Colors.black,
//     margin: const EdgeInsets.all(12),
//     // duration: const Duration(seconds: 3),
//   );
// }
