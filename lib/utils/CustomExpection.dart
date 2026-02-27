import 'package:flutter/foundation.dart';

class CustomException implements Exception {
  final dynamic _message;
  final String? _prefix;
  final dynamic context;

  CustomException([this._message, this._prefix, this.context]);

  @override
  String toString() {
    // In production, we avoid exposing raw error messages or internal details.
    if (kDebugMode) {
      String result = _prefix ?? "";
      if (_message != null) {
        result += _message.toString();
      } else {
        result += "No additional details available.";
      }
      return result;
    } else {
      // In production, return a generic user-friendly message based on the prefix.
      if (_prefix != null && _prefix.isNotEmpty) {
        // Clean up prefix (e.g., "Error: " -> "Error")
        return _prefix.replaceAll(RegExp(r'[:\s]+$'), "");
      }
      return "An unexpected error occurred. Please try again later.";
    }
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message])
    : super(
        message,
        kDebugMode ? "Error During Communication: " : "Connection Error: ",
      );
}

class BadRequestException extends CustomException {
  BadRequestException([message])
    : super(message, kDebugMode ? "Invalid Request: " : "Bad Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message])
    : super(message, kDebugMode ? "Unauthorised: " : "Access Denied: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message])
    : super(message, kDebugMode ? "Invalid Input: " : "Invalid Input: ");
}
