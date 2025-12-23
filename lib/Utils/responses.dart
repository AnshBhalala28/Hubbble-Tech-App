// import 'dart:convert';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// import 'CustomExpection.dart';
//
// responses(http.Response response) {
//   switch (response.statusCode) {
//     case 200:
//       {
//         if (jsonDecode(response.body)['statusCode'] == 101) {}
//         return response;
//       }
//     case 400:
//     case 422:
//       return response;
//     case 401:
//     case 403:
//       throw UnauthorisedException(response.body.toString());
//     case 405:
//       throw UnauthorisedException(response.body.toString());
//     case 429:
//       Get.snackbar(
//         "Server Unavailable",
//         "Server's are Unavailable Please Try Again Later",
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 3),
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       throw response;
//     case 500:
//     default:
//       throw FetchDataException(
//         'Error occurred while Communication with Server with StatusCode :${response.statusCode}',
//       );
//   }
// }
//
// handleDioError(DioException e) {
//   String? message;
//
//   debugPrint("===== Dio Error Debug Info =====");
//   debugPrint("Type: ${e.type}");
//   debugPrint("Message: ${e.message}");
//   debugPrint("Error: ${e.error}");
//   debugPrint("Response : ${e.response}");
//   debugPrint("StackTrace: ${e.stackTrace}");
//   debugPrint("===============================");
//
//   if (e.type == DioExceptionType.connectionTimeout ||
//       e.type == DioExceptionType.receiveTimeout ||
//       e.type == DioExceptionType.sendTimeout) {
//     message = "Request timed out. Please try again.";
//   } else if (e.type == DioExceptionType.badResponse) {
//     final statusCode = e.response?.statusCode ?? "Unknown";
//     message = "Server error (Status Code: $statusCode)";
//   } else if (e.type == DioExceptionType.unknown) {
//     if (e.error is SocketException) {
//       message = "No internet connection.";
//     } else {
//       debugPrint("Unexpected unknown Dio error: ${e.error}");
//     }
//   } else {
//     message = "Something went wrong.";
//   }
//   // if (message != null && message.isNotEmpty) {
//   //   Get.snackbar(
//   //     "Error",
//   //     message,
//   //     snackPosition: SnackPosition.BOTTOM,
//   //     backgroundColor: Colors.red.withValues(alpha: 0.1),
//   //     colorText: Colors.black,
//   //     margin: const EdgeInsets.all(12),
//   //   );
//   // }
// }
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'CustomExpection.dart';

/// ------------------------------------------------------------
/// SAFE DEBUG LOGGER
/// Logs only in DEBUG mode (disabled in release)
/// ------------------------------------------------------------
void debugLog(Object? message) {
  if (kDebugMode) {
    debugPrint(message?.toString());
  }
}

/// ------------------------------------------------------------
/// HTTP RESPONSE HANDLER
/// ------------------------------------------------------------
responses(http.Response response) {
  switch (response.statusCode) {
    case 200:
      {
        final decoded = jsonDecode(response.body);
        if (decoded['statusCode'] == 101) {
          // Handle custom success state if needed
        }
        return response;
      }

    case 400:
    case 422:
      return response;

    case 401:
    case 403:
    case 405:
      throw UnauthorisedException(response.body.toString());

    case 429:
      Get.snackbar(
        "Server Unavailable",
        "Servers are unavailable. Please try again later.",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw response;

    case 500:
    default:
      throw FetchDataException(
        'Error occurred while communicating with server '
            '(StatusCode: ${response.statusCode})',
      );
  }
}

/// ------------------------------------------------------------
/// DIO ERROR HANDLER (PRODUCTION SAFE)
/// ------------------------------------------------------------
handleDioError(DioException e) {
  String message = "Something went wrong.";

  /// Debug-only logs
  debugLog("===== DIO ERROR =====");
  debugLog("Type: ${e.type}");
  debugLog("Message: ${e.message}");
  debugLog("Error: ${e.error}");
  debugLog("Status Code: ${e.response?.statusCode}");
  debugLog("StackTrace: ${e.stackTrace}");
  debugLog("=====================");

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      message = "Request timed out. Please try again.";
      break;

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? "Unknown";
      message = "Server error (Status Code: $statusCode)";
      break;

    case DioExceptionType.unknown:
      if (e.error is SocketException) {
        message = "No internet connection.";
      }
      break;

    case DioExceptionType.cancel:
      message = "Request was cancelled.";
      break;

    default:
      message = "Unexpected error occurred.";
  }

  /// OPTIONAL UI ERROR (Enable if needed)
  /*
  Get.snackbar(
    "Error",
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.withOpacity(0.1),
    colorText: Colors.black,
    margin: const EdgeInsets.all(12),
  );
  */
}
