import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

import '../../../../comman/const.dart';

class CommunityDetailProvider extends ChangeNotifier {
  Future<Response> categoryDetailApi(String businessID, categoryID) async {
    try {
      String? token = await SaveDataLocal.getToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.productCategoryBusiness}${loginModel?.data?.user?.id.toString()}/$businessID/$categoryID",
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> categoryViewApi(String businessID) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      final response = await dio.get(
        "${ApiEndpoint.getProductCategory}$businessID",
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> categorySearchApi(
    String userId,
    businessID,
    searchTerm,
  ) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      final response = await dio.get(
        ApiEndpoint.searchBusinessProduct,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {
          'user_id': userId,
          'business_id': businessID,
          'search_term': searchTerm,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}


// class CommunityDetailProvider extends ChangeNotifier {
//   Future<http.Response> CategoryDetailApi(String businessID, categoryID) async {
//     String url =
//         '${baseUrl}/getProductsByCategoryForBusiness/${loginModel?.data?.user?.id.toString()}/$businessID/$categoryID';
//     
//     try {
//       final response = await http
//           .get(Uri.parse(url))
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw SocketException('Request timed out');
//             },
//           );
//       if (response.statusCode == 200) {
//         
//         log("lat");
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
//   Future<http.Response> CategoryViewApi(String businessID) async {
//     String url = '${baseUrl}/getBusinessProductCategories/$businessID';
//     
//     try {
//       final response = await http
//           .get(Uri.parse(url))
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw SocketException('Request timed out');
//             },
//           );
//       if (response.statusCode == 200) {
//         
//         log("lat");
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
//   Future<http.Response> ProductSearchApi(
//     String userId,
//     businessID,
//     search_term,
//   ) async {
//     String url =
//         '${baseUrl}/searchBusinessProducts?user_id=$userId&business_id=$businessID&search_term=$search_term';
//     
//     try {
//       final response = await http
//           .get(Uri.parse(url))
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw SocketException('Request timed out');
//             },
//           );
//       if (response.statusCode == 200) {
//         
//         log("lat");
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