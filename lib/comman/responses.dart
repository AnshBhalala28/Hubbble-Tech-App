import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'CustomExpection.dart';

responses(http.Response response) {
  switch (response.statusCode) {
    case 200:
      {
        if (jsonDecode(response.body)['statusCode'] == 101) {
          // SaveDataLocal.clearUserData();
        }
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
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw response;
    case 500:
    default:
      throw FetchDataException(
          'Error occurred while Communication with Server with StatusCode :${response.statusCode}');
  }
}
