import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apiConfig.dart';
import '../../../utils/apiEndpoint.dart';
import '../../../utils/responses.dart';
import '../../../utils/storeUserData.dart';

class ProductProvider extends ChangeNotifier {
  Future<Response> productDetailApi(
    String UserId,
    String productid,
    String type,
  ) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.productDetail,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {'user_id': UserId, "id": productid, 'type': type},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addReviewApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.addReview,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> showAllReviewApi(String productid) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.productDetail,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {"product_id": productid},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> AddToCart(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.addtocart,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
