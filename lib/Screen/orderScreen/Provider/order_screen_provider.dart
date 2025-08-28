import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class OrderProvider extends ChangeNotifier {
  Future<Response> orderListApi(String userID, status, type, page) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.myOrder}?user_id=$userID&type=$type&status=$status&page=$page",
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        // queryParameters: {'user_id': userID, 'status': status, 'type': type},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> orderDetailApi(
    String userID,
    orderid,
    orderProductID,
  ) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': token};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.myOrderDetail}user_id=$userID&order_id=$orderid&order_product_id=$orderProductID",
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        // queryParameters: {
        //   'user_id': userID,
        //   'order_id': orderid,
        //   'order_product_id': orderProductID,
        // },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> cancleOrderApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.cancleOrder,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
