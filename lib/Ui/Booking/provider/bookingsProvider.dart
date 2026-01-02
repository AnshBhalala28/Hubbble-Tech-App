import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../Utils/apiConfig.dart';
import '../../../Utils/apiEndpoint.dart';
import '../../../Utils/responses.dart';
import '../../../Utils/storeUserData.dart';

class AmenitiesProvider extends ChangeNotifier {
  Future<Response> amenitiesApi(
    String userId,
    String amenityId,
    String date,
    String page,
  ) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.amenities,
        options: Options(headers: {'X-Auth-Token': token}),
        queryParameters: {
          'user_id': userId,
          'amentites_id': amenityId,
          'date': date,
          "page": page,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addBookingApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.bookAmenity,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      log("error ${e.response!.data}");
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> bookingStatusApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.checkBooked,
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

  Future<Response> rejectBookingApi(Map<String, String> bookingId) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.cancleBookingAmenity,
        data: bookingId,
        options: Options(headers: {'X-Auth-Token': token}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> allAmenitiesApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.amenityStatus,
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

  Future<Response> eventBookingStatusApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.userEventRequests,
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

  Future<Response> rsvpToEventApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.rsvpToEvent,
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

  Future<Response> rsvpToAmenityApi(Map<String, String> bodyData) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.bookingUpdateRsvp,
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

  Future<Response> serviceBookingApi(String userId, String status) async {
    try {
      String token = await SaveDataLocal.getValidToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.bookedServices,
        queryParameters: {'user_id': userId, 'status': status},
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
