import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../comman/apiConfig.dart';
import '../../../comman/apiEndpoint.dart';
import '../../../comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

// class ProfileProvider extends ChangeNotifier {
//   Future<http.Response> ProfileEdit(
//       Map<String, String> bodyData, File? imageFile) async {
//     const url = '${baseUrl}/update-app-resident';
//
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(url));
//       bodyData.forEach((key, value) {
//         request.fields[key] = value;
//       });
//       if (imageFile != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'member_image[0]',
//           imageFile.path,
//           contentType: MediaType('image', 'jpeg'),
//         ));
//         log("image file path jay che ${imageFile.path}");
//         log("image file path jay che ${imageFile}");
//       }
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       if (response.statusCode == 200) {
//
//         return response;
//       } else {
//
//         throw Exception("Failed to connect to the server");
//       }
//     } on SocketException catch (e) {
//       throw Exception('No Internet connection: $e');
//     } catch (e) {
//       throw Exception('An error occurred: $e');
//     }
//   }
// }

class ProfileProvider extends ChangeNotifier {
  Future<Response> profileApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.profile,
        data: bodyData,

        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> updateProfile(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.profile,
        data: bodyData,

        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  // MediaType? _getMediaType(String path) {
  //   final mimeType = lookupMimeType(path);
  //   if (mimeType != null) {
  //     final parts = mimeType.split('/');
  //     return MediaType(parts[0], parts[1]);
  //   }
  //   return null;
  // }
}
