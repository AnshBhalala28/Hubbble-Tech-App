import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

class AmenitiesProvider extends ChangeNotifier {
  Future<Response> amenitiesApi(
    String userId,
    String amenityId,
    String date,
  ) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.amenities,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {
          'user_id': userId,
          'amentites_id': amenityId,
          'date': date,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> addBookingApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.bookAmenity,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> rejectBookingApi(Map<String, String> bookingId) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.cancleBookingAmenity,
        data: bookingId,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> allAmenitiesApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.amenityStatus,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> eventBookingStatusApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.userEventRequests,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> rsvpToEventApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.rsvpToEvent,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> rsvpToAmenityApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.bookingUpdateRsvp,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> serviceBookingApi(String userId, String status) async {
    try {
      String? token = await SaveDataLocal.getToken();
      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.bookedServices,
        queryParameters: {'user_id': userId, 'status': status},
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}



// class AmenitiesProvider extends ChangeNotifier {
  // Future<http.Response> AmenitiesApi(
  //   String userid,
  //   String amenitiesid,
  //   String date,
  // ) async {
  //   final url =
  //       '${baseUrl}/amenities?user_id=$userid&amentites_id=$amenitiesid&date=$date';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .get(Uri.parse(url))
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> AddBooking(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/bookAmenity';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> rejectBookingApi(Map<String, String> bookingId) async {
  //   const url = '${baseUrl}/cancel-amenity-booking';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bookingId)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> AllAmenitiesApi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/get-amenity-status';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> BookAmenitiesStatus(
  //   Map<String, String> bodyData,
  // ) async {
  //   const url = '${baseUrl}/get-amenity-status';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> EventBookingStatus(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/getUserEventRequests';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> RSVPtoEvetApi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/rsvpToEvent';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> RSVPtoAmenityApi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/booking-update-rsvp';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: bodyData)
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> ServiceBookingApi(String userid, String Status) async {
  //   final url =
  //       '${baseUrl}/getBookedServicesForUser?user_id=$userid&status=$Status';
  //   print("Request URL: $url");
  //   try {
  //     final response = await http
  //         .get(Uri.parse(url))
  //         .timeout(
  //           const Duration(seconds: 60),
  //           onTimeout: () {
  //             throw SocketException('Request timed out');
  //           },
  //         );
  //     if (response.statusCode == 200) {
  //       print("Successful response: ${response.body}");
  //       return response;
  //     } else {
  //       print("Failed response: ${response.statusCode}");
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
// }

