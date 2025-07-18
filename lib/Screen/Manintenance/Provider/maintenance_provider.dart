import 'package:dio/dio.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

// class MaintenanceProvider extends ChangeNotifier {
//   Future<http.Response> AddMaintenanceRequest(
//     Map<String, String> bodyData,
//   ) async {
//     const url = '$baseUrl/maintenance-request-app';
//     print("Request URL: $url");
//     try {
//       final response = await http
//           .post(Uri.parse(url), body: bodyData)
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw const SocketException('Request timed out');
//             },
//           );
//       if (response.statusCode == 200) {
//         log("Successful response: ${response.body}");
//         return response;
//       } else {
//         log("Failed response: ${response.statusCode}");
//         throw Exception("Failed to connect to the server");
//       }
//     } on SocketException catch (e) {
//       throw Exception('No Internet connection: $e');
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }

//   Future<http.Response> AllMaintenanceStaus(
//     Map<String, String> bodyData,
//   ) async {
//     const url = '$baseUrl/get-maintenance-request-app';
//     print("Request URL: $url");
//     try {
//       final response = await http
//           .post(Uri.parse(url), body: bodyData)
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw const SocketException('Request timed out');
//             },
//           );
//       if (response.statusCode == 200) {
//         log("Successful response: ${response.body}");
//         return response;
//       } else {
//         log("Failed response: ${response.statusCode}");
//         throw Exception("Failed to connect to the server");
//       }
//     } on SocketException catch (e) {
//       throw Exception('No Internet connection: $e');
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
// }

class MaintenanceProvider {
  Future<Response> addMaintanceRequestApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      final response = await dio.post(
        ApiEndpoint.maintanceRequest,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> getMaintanceApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      final response = await dio.post(
        ApiEndpoint.getMaintance,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
