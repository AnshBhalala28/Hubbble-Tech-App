import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/store_local.dart';
import '../../../comman/responses.dart';

// class EventProvider extends ChangeNotifier {
//   Future<http.Response> eventapi(Map<String, String> bodyData) async {
//     const url = '${baseUrl}/getEvents';
//     LoginModel? userData = await SaveDataLocal.getDataFromLocal();
//     String token = userData?.data?.token ?? '';
//
//     if (token.isEmpty) {
//       throw Exception('Token not found');
//     }
//     Map<String, String> headers = {
//       'Authorization': 'Bearer $token',
//     };
//
//     var responseJson;
//     final response = await http
//         .post(Uri.parse(url), body: bodyData, headers: headers)
//         .timeout(
//       const Duration(seconds: 60),
//       onTimeout: () {
//         throw const SocketException('Something went wrong');
//       },
//     );
//     responseJson = responses(response);
//
//     return responseJson;
//   }
//   Future<http.Response> sendeventapi(Map<String, String> bodyData) async {
//     const url = '${baseUrl}/sendEventRequest';
//     LoginModel? userData = await SaveDataLocal.getDataFromLocal();
//     String token = userData?.data?.token ?? '';
//
//     if (token.isEmpty) {
//       throw Exception('Token not found');
//     }
//     Map<String, String> headers = {
//       'Authorization': 'Bearer $token',
//     };
//
//     var responseJson;
//     final response = await http
//         .post(Uri.parse(url), body: bodyData, headers: headers)
//         .timeout(
//       const Duration(seconds: 60),
//       onTimeout: () {
//         throw const SocketException('Something went wrong');
//       },
//     );
//     responseJson = responses(response);
//
//     return responseJson;
//   }
// }
class EventProvider extends ChangeNotifier {
  Future<Response> eventapi(Map<String, String> bodyData) async {
    // LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    // String token = userData?.data?.token ?? '';
    //
    // if (token.isEmpty) {
    //   throw Exception('Token not found');
    // }
    // Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      final dio = Dio();
      String? token = await SaveDataLocal.getToken();

      final response = await dio.post(
        ApiEndpoint.event,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Response> sendeventapi(Map<String, String> bodyData) async {
    // const url = '${baseUrl}/sendEventRequest';
    // LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    // String token = userData?.data?.token ?? '';
    //
    // if (token.isEmpty) {
    //   throw Exception('Token not found');
    // }
    // Map<String, String> headers = {'Authorization': 'Bearer $token'};
    //
    try {
      final dio = Dio();
      String? token = await SaveDataLocal.getToken();
      final response = await dio.post(
        ApiEndpoint.sendEventRequest,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
