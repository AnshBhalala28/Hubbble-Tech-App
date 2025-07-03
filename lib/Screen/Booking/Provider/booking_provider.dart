import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../comman/const.dart';

class AmenitiesProvider extends ChangeNotifier {
  Future<http.Response> AmenitiesApi(
      String userid, String amenitiesid, String date) async {
    final url =
        '${baseUrl}/amenities?user_id=$userid&amentites_id=$amenitiesid&date=$date';
    print("Request URL: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> AddBooking(Map<String, String> bodyData) async {
    const url = '${baseUrl}/bookAmenity';
    print("Request URL: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> rejectBookingApi(Map<String, String> bookingId) async {
    const url = '${baseUrl}/cancel-amenity-booking';
    print("Request URL: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bookingId).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> AllAmenitiesApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/get-amenity-status';
    print("Request URL: $url");
    try {
      final response = await http.post(Uri.parse(url), body: bodyData).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> BookAmenitiesStatus(
      Map<String, String> bodyData) async {
    const url = '${baseUrl}/get-amenity-status';
    print("Request URL: $url");
    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: bodyData,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> EventBookingStatus(Map<String, String> bodyData) async {
    const url = '${baseUrl}/getUserEventRequests';
    print("Request URL: $url");
    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: bodyData,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> RSVPtoEvetApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/rsvpToEvent';
    print("Request URL: $url");
    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: bodyData,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> RSVPtoAmenityApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/booking-update-rsvp';
    print("Request URL: $url");
    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: bodyData,
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<http.Response> ServiceBookingApi(String userid, String Status) async {
    final url =
        '${baseUrl}/getBookedServicesForUser?user_id=$userid&status=$Status';
    print("Request URL: $url");
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw SocketException('Request timed out');
        },
      );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        return response;
      } else {
        print("Failed response: ${response.statusCode}");
        throw Exception("Failed to connect to the server");
      }
    } on SocketException catch (e) {
      throw Exception('No Internet connection: $e');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
