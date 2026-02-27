import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../utils/apiConfig.dart';
import '../../../utils/apiEndpoint.dart';
import '../../../utils/responses.dart';
import '../../../utils/storeUserData.dart';

class OrderProvider extends ChangeNotifier {
  Future<Response> orderListApi(String userID, status, type, page) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.myOrder}?user_id=$userID&type=$type&status=$status&page=$page",
        options: Options(headers: {'X-Auth-Token': token}),
      );
      print(
        "URL VAE${ApiEndpoint.myOrder}?user_id=$userID&type=$type&status=$status&page=$page",
      );
      return response;
    } on DioException catch (e) {
      print(
        "URL VAE${ApiEndpoint.myOrder}?user_id=$userID&type=$type&status=$status&page=$page",
      );
      throw Exception(handleDioError(e));
    } catch (e) {
      print(
        "URL VAE${ApiEndpoint.myOrder}?user_id=$userID&type=$type&status=$status&page=$page",
      );
      rethrow;
    }
  }

  Future<Response> orderDetailApi(
    String userID,
    orderid,
    orderProductID,
  ) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.myOrderDetail}user_id=$userID&order_id=$orderid&order_product_id=$orderProductID",
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> cancleOrderApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.cancleOrder,
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

  Future<Response> cancleOrderApi1(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.cancleOrder1,
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
