import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:wavee/Screen/Authcation/model/login_model.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';

import '../../../../comman/const.dart';

class CommunityProvider extends ChangeNotifier {
  Future<http.Response> BussinessProfileApi(String UserId, lat, lon) async {
    String url =
        '${baseUrl}/business-profiles?user_id=$UserId&longitude=$lon&latitude=$lat';

    //
    //
    // String url =
    //     '${baseUrl}/business-profiles?user_id=241&longitude=0.0755867&latitude=51.5022582';
    print("Business Profile Url : $url");
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> BussinessViewApi(String UserId, id, lat, lon) async {
    String url = '${baseUrl}/businessProfile/$UserId/$id/$lat/$lon';
    print("Business Profile Url shu ave che  : $url");
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> projectlistapi(String UserId, id, lat, lon) async {
    String url =
        '${baseUrl}/businessProfile/$UserId/$id?longitude=$lon&latitude=$lat';
    print("urlurlurlurlurlurlurlurlurlurlurlurlurl>>>>>>${url}");
    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';
    print("my token :: ${token}");
    if (token.isEmpty) {
      throw Exception('Token not found');
    }
    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use the retrieved token
    };
    print(url);
    var responseJson;
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> IsLikeApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/like-business';
    print("Request URL: $url");
    try {
      final response = await http
          .post(Uri.parse(url), body: bodyData)
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

  Future<http.Response> BusinessSearch(Map<String, String> bodyData) async {
    String url = '${baseUrl}/searchBusinessByName';
    print("urlurlurlurlurlurlurlurlurlurlurlurlurl>>>>>>${url}");
    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    String token = userData?.data?.token ?? '';
    print("my token :: ${token}");
    if (token.isEmpty) {
      throw Exception('Token not found');
    }
    Map<String, String> headers = {
      'Authorization': 'Bearer $token', // Use the retrieved token
    };
    print(url);
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData, headers: headers)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> GetLikeApi(String user_id, lat, lon) async {
    String url =
        '${baseUrl}/get-liked-businesses?user_id=$user_id&longitude=$lon&latitude=$lat';
    print("Get like Business Profile Url : $url");
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> GetVisitedApi(String user_id, lat, lon) async {
    String url =
        '${baseUrl}/getVisitedBusinessesByUser?user_id=$user_id&longitude=$lon&latitude=$lat';
    print("Get Visited Business Profile Url : $url");
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> requestapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/storeServiceRequest';
    print("request send Url : $url");
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> CategoriesApi() async {
    String url = '${baseUrl}/getCategories';
    print("categories Profile Url : $url");
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> categoriesViewApi(
    String UserId,
    lon,
    lat,
    CatId,
  ) async {
    String url =
        '${baseUrl}/business-profiles-category?user_id=$UserId&longitude=$lon&latitude=$lat&category_id=$CatId';
    print("Business Categories Profile Url : $url");
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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

  Future<http.Response> postlikeapi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/post-offers-promo-like-dislike';
    print("post like send Url : $url");
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> postDwellTime(Map<String, String> bodyData) async {
    const url = '${baseUrl}/record-dwell-time';
    print("post Dwell time Url : $url");
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> PostAsViewedApi(Map<String, String> bodyData) async {
    const url = '${baseUrl}/markPostAsViewed';
    print("post Dwell time Url : $url");
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> OfferPromoAsViewed(Map<String, String> bodyData) async {
    const url = '${baseUrl}/markOfferPromoAsViewed';
    print("markOfferPromoAsViewed Url : $url");
    var responseJson;
    final response = await http
        .post(Uri.parse(url), body: bodyData)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);
    print(response.body);
    return responseJson;
  }

  Future<http.Response> stroyapi(String UserId, id) async {
    //    String url = '${baseUrl}/business-profiles?user_id=$UserId&longitude=$lon&latitude=$lat';
    String url = '${baseUrl}/listFeaturedPosts?user_id=$UserId&business_id=$id';
    print("listFeaturedPosts Profile Url : $url");
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw SocketException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        print("Successful response: ${response.body}");
        log("lat");
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
