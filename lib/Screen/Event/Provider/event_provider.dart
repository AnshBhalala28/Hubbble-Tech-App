import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:wavee/comman/const.dart';

import '../../../comman/responses.dart';
import '../../../comman/store_local.dart';
import '../../Authcation/model/login_model.dart';

class EventProvider extends ChangeNotifier {
  Future<http.Response> eventapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/getEvents';
    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';
    print("my token :: ${token}");
    if (token.isEmpty) {
      throw Exception('Token not found');
    }
    Map<String, String> headers = {'Authorization': 'Bearer $token'};
    print(url);
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData, headers: headers)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> sendeventapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/sendEventRequest';
    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';
    print("my token :: ${token}");
    if (token.isEmpty) {
      throw Exception('Token not found');
    }
    Map<String, String> headers = {'Authorization': 'Bearer $token'};
    print(url);
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData, headers: headers)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }
}
