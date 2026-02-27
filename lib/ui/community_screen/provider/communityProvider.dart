import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apiConfig.dart';
import '../../../utils/apiEndpoint.dart';
import '../../../utils/const.dart';
import '../../../utils/responses.dart';
import '../../../utils/storeUserData.dart';

class CommunityProvider extends ChangeNotifier {
  Future<Response> businessProfileApi(
    String userId,
    latitude,
    longitude,
  ) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.businessProfile,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {
          'user_id': userId,
          'longitude': longitude,
          'latitude': latitude,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> businessProfileViewApi(String id, lat, lon) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.businessProfileView}${loginModel?.data?.user?.id.toString()}/$id?latitude=$lat&longitude=$lon",
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> businessLikeApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.likeBusiness,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in businessLikeApi: $e");
      rethrow;
    }
  }

  Future<Response> searchBusinessApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.searchBusiness,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in searchBusinessApi: $e");
      rethrow;
    }
  }

  Future<Response> getLikeBusinessApi(
    String userId,
    latitude,
    longitude,
  ) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.get(
        ApiEndpoint.getLikeBusiness,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {
          'user_id': userId,
          'longitude': longitude,
          'latitude': latitude,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getVisitorApi(String userId, latitude, longitude) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.get(
        ApiEndpoint.getVisitor,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {
          'user_id': userId,
          'longitude': longitude,
          'latitude': latitude,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCategoryApi() async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.get(
        ApiEndpoint.category,
        options: Options(headers: {'X-Auth-Token': token}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> categoryViewApi(
    String userId,
    latitude,
    longitude,
    catID,
  ) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.get(
        ApiEndpoint.categoryView,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {
          'user_id': userId,
          'longitude': longitude,
          'latitude': latitude,
          'category_id': catID,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in categoryViewApi: $e");
      rethrow;
    }
  }

  Future<Response> postLikeApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.postLike,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in postLikeApi: $e");
      rethrow;
    }
  }

  Future<Response> recoedDwellApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.post(
        ApiEndpoint.recordTime,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in recoedDwellApi: $e");
      rethrow;
    }
  }

  Future<Response> postMarkViewApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.post(
        ApiEndpoint.postView,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in postMarkViewApi: $e");
      rethrow;
    }
  }

  Future<Response> markOfferPromoApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.post(
        ApiEndpoint.markOfferPromo,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      debugLog("Error in markOfferPromoApi: $e");
      rethrow;
    }
  }

  Future<Response> storyViewApi(String userId, businessId) async {
    try {
      final dio = await DioHelper.getDio();
      String token = await SaveDataLocal.getValidToken();

      final response = await dio.get(
        ApiEndpoint.featuredPosts,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {'user_id': userId, 'business_id': businessId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
