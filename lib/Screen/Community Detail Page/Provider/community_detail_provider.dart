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
