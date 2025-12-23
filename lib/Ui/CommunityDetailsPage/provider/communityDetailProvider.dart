import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/const.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class CommunityDetailProvider extends ChangeNotifier {
  Future<Response> categoryDetailApi(String businessID, categoryID) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.productCategoryBusiness}${loginModel?.data?.user?.id.toString()}/$businessID/$categoryID",
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> categoryViewApi(String businessID) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();
      final response = await dio.get(
        "${ApiEndpoint.getProductCategory}$businessID",
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> categorySearchApi(
    String userId,
    businessID,
    searchTerm,
  ) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();
      final response = await dio.get(
        ApiEndpoint.searchBusinessProduct,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {
          'user_id': userId,
          'business_id': businessID,
          'search_term': searchTerm,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
