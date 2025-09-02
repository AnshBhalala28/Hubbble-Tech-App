import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class CartProvider extends ChangeNotifier {
  Future<Response> cartDetailApi(id) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.cartDetail,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': id},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> updateCartQuantityApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }

      final response = await dio.post(
        ApiEndpoint.updateCartQuantity,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> removeCartApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }

      final response = await dio.post(
        ApiEndpoint.removeFromCart,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        data: bodyData,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
