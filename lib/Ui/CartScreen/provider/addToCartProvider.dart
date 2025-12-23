import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class CartProvider extends ChangeNotifier {
  Future<Response> cartDetailApi(id) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.cartDetail,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {'user_id': id},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> amendOrderDetailapi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.amendOrderDetail,
        options: Options(headers: {'X-Auth-Token': token}),
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> amendOrderApi(Map<String, dynamic> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.prepareAmendOrder,
        options: Options(headers: {'X-Auth-Token': token}),
        data: bodyData, // JSON encode auto thase
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> amendPaymentApi(Map<String, dynamic> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.amendOrder,
        options: Options(headers: {'X-Auth-Token': token}),
        data: bodyData, // JSON encode auto thase
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateCartQuantityApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.post(
        ApiEndpoint.updateCartQuantity,
        options: Options(headers: {'X-Auth-Token': token}),
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> removeCartApi(Map<String, dynamic> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.post(
        ApiEndpoint.removeFromCart,
        options: Options(headers: {'X-Auth-Token': token}),
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
