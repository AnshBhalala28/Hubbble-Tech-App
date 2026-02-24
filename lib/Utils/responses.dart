import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/customSnackBars.dart';

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
      debugLog("Validation Error (${response.statusCode}): ${response.body}");
      // Extract message safely to avoid surfacing raw JSON or stack traces
      String message = "Invalid request. Please check your input.";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      throw BadRequestException(
        kDebugMode ? "($message) Details: ${response.body}" : message,
      );

    case 401:
    case 403:
    case 405:
      debugLog("Auth Error: ${response.statusCode}");
      throw UnauthorisedException("Unauthorized access. Please log in again.");

    case 429:
      if (Get.context != null) {
        showSnackBar(
          context: Get.context!,
          // <--- Use Get.context! here
          title: "Server Unavailable",
          message: "Too many requests. Please try again later.",
          backgoundColor: AppColors.redColor,
          ColorText: Colors.white,
        );
      }

      throw FetchDataException("Rate limit exceeded.");

    case 500:
    default:
      debugLog("Server Error: ${response.statusCode}");
      throw FetchDataException(
        kDebugMode
            ? 'Error occurred while communicating with server (StatusCode: ${response.statusCode})'
            : 'Error occurred while communicating with server.',
      );
  }
}

/// ------------------------------------------------------------
/// DIO ERROR HANDLER (PRODUCTION SAFE)
/// ------------------------------------------------------------
handleDioError(DioException e) {
  String message = "Something went wrong.";

  /// Debug-only logs (Sanitized: only logging error type and status code)
  debugLog("===== DIO ERROR =====");
  debugLog("Type: ${e.type}");
  debugLog("Status Code: ${e.response?.statusCode}");
  // We avoid logging full error message or response body as it might contain sensitive info
  debugLog("=====================");

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      message = "Request timed out. Please try again.";
      break;

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? "Unknown";
      message =
          kDebugMode
              ? "Server error (Status Code: $statusCode)"
              : "Server error. Please try again later.";
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

  // Generic message returned to the caller or handled via UI if needed.
  return message;
}
