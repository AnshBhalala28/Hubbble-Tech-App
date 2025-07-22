import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wavee/comman/apiConfig.dart';
import 'package:wavee/comman/apiEndpoint.dart';
import 'package:wavee/comman/responses.dart';
import 'package:wavee/comman/store_local.dart';
import '../../../../comman/const.dart';

class CommunityProvider extends ChangeNotifier {
  Future<Response> businessProfileApi(
    String userId,
    latitude,
    longitude,
  ) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        ApiEndpoint.businessProfile,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {
          'user_id': userId,
          'longitude': longitude,
          'latitude': latitude,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> businessProfileViewApi(String id, lat, lon) async {
    try {
      // '${baseUrl}/businessProfile/$UserId/$id?longitude=$lon&latitude=$lat';
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.get(
        "${ApiEndpoint.businessProfileView}${loginModel?.data?.user?.id.toString()}/$id?longitude=$lon&latitude=$lat",
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> businessLikeApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.likeBusiness,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> searchBusinessApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.searchBusiness,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> getLikeBusinessApi(
    String userId,
    latitude,
    longitude,
  ) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.get(
        ApiEndpoint.getLikeBusiness,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {
          'user_id': userId,
          'longitude': longitude,
          'latitude': latitude,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> getVisitorApi(String userId, latitude, longitude) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.get(
        ApiEndpoint.getVisitor,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {
          'user_id': userId,
          'longitude': longitude,
          'latitude': latitude,
        },
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<Response> getCategoryApi() async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.get(
        ApiEndpoint.category,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
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
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.get(
        ApiEndpoint.categoryView,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
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
    }
  }

  Future<Response> postLikeApi(Map<String, String> bodyData) async {
    try {
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final dio = await DioHelper.getDio();
      final response = await dio.post(
        ApiEndpoint.postLike,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> recoedDwellApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.post(
        ApiEndpoint.recordTime,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> postMarkViewApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.post(
        ApiEndpoint.postView,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> markOfferPromoApi(Map<String, String> bodyData) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.post(
        ApiEndpoint.markOfferPromo,
        data: bodyData,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception("Something went wrong.");
    }
  }

  Future<Response> storyViewApi(String userId, businessId) async {
    try {
      final dio = await DioHelper.getDio();
      String? token = await SaveDataLocal.getToken();
      if (token != null && token.isNotEmpty) {
        Map<String, String> headers = {'X-Auth-Token': '$token'};
      }

      final response = await dio.get(
        ApiEndpoint.featuredPosts,
        options: Options(headers: {'X-Auth-Token': token ?? ''}),
        queryParameters: {'user_id': userId, 'business_id': businessId},
      );

      return response;
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}


// class CommunityProvider extends ChangeNotifier {
  // Future<http.Response> BussinessProfileApi(String UserId, lat, lon) async {
  //   String url =
  //       '${baseUrl}/business-profiles?user_id=$UserId&longitude=$lon&latitude=$lat';
  //   
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
  //       
  //       log("lat");
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> BussinessViewApi(String UserId, id, lat, lon) async {
  //   String url = '${baseUrl}/businessProfile/$UserId/$id/$lat/$lon';
  //   
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
  //       
  //       log("lat");
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> projectlistapi(String UserId, id, lat, lon) async {
  //   String url =
  //       '${baseUrl}/businessProfile/$UserId/$id?longitude=$lon&latitude=$lat';
  //   
  //   LoginModel? userData = await SaveDataLocal.getDataFromLocal();
  //   String token = userData?.data?.token ?? '';
  //   
  //   if (token.isEmpty) {
  //     throw Exception('Token not found');
  //   }
  //   Map<String, String> headers = {'Authorization': 'Bearer $token'};
  //   
  //   var responseJson;
  //   final response = await http
  //       .get(Uri.parse(url), headers: headers)
  //       .timeout(
  //         const Duration(seconds: 60),
  //         onTimeout: () {
  //           throw const SocketException('Something went wrong');
  //         },
  //       );
  //   responseJson = responses(response);
  //   
  //   return responseJson;
  // }
  // Future<http.Response> IsLikeApi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/like-business';
  //   
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
  //       
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> BusinessSearch(Map<String, String> bodyData) async {
  //   String url = '${baseUrl}/searchBusinessByName';
  //   
  //   LoginModel? userData = await SaveDataLocal.getDataFromLocal();
  //   String token = userData?.data?.token ?? '';
  //   
  //   if (token.isEmpty) {
  //     throw Exception('Token not found');
  //   }
  //   Map<String, String> headers = {'Authorization': 'Bearer $token'};
  //   
  //   var responseJson;
  //   final response = await http
  //       .post(Uri.parse(url), body: bodyData, headers: headers)
  //       .timeout(
  //         const Duration(seconds: 60),
  //         onTimeout: () {
  //           throw const SocketException('Something went wrong');
  //         },
  //       );
  //   responseJson = responses(response);
  //   
  //   return responseJson;
  // }
  // Future<http.Response> GetLikeApi(String user_id, lat, lon) async {
  //   String url =
  //       '${baseUrl}/get-liked-businesses?user_id=$user_id&longitude=$lon&latitude=$lat';
  //   
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
  //       
  //       log("lat");
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> GetVisitedApi(String user_id, lat, lon) async {
  //   String url =
  //       '${baseUrl}/getVisitedBusinessesByUser?user_id=$user_id&longitude=$lon&latitude=$lat';
  //   
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
  //       
  //       log("lat");
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> requestapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/storeServiceRequest';
  //   
  //   var responseJson;
  //   final response = await http
  //       .post(Uri.parse(url), body: bodyData)
  //       .timeout(
  //         const Duration(seconds: 60),
  //         onTimeout: () {
  //           throw const SocketException('Something went wrong');
  //         },
  //       );
  //   responseJson = responses(response);
  //   
  //   return responseJson;
  // }
  // Future<http.Response> CategoriesApi() async {
  //   String url = '${baseUrl}/getCategories';
  //   
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
  //       
  //       log("lat");
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> categoriesViewApi(
  //   String UserId,
  //   lon,
  //   lat,
  //   CatId,
  // ) async {
  //   String url =
  //       '${baseUrl}/business-profiles-category?user_id=$UserId&longitude=$lon&latitude=$lat&category_id=$CatId';
  //   
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
  //       
  //       log("lat");
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
  // Future<http.Response> postlikeapi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/post-offers-promo-like-dislike';
  //   
  //   var responseJson;
  //   final response = await http
  //       .post(Uri.parse(url), body: bodyData)
  //       .timeout(
  //         const Duration(seconds: 60),
  //         onTimeout: () {
  //           throw const SocketException('Something went wrong');
  //         },
  //       );
  //   responseJson = responses(response);
  //   
  //   return responseJson;
  // }
  // Future<http.Response> postDwellTime(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/record-dwell-time';
  //   
  //   var responseJson;
  //   final response = await http
  //       .post(Uri.parse(url), body: bodyData)
  //       .timeout(
  //         const Duration(seconds: 60),
  //         onTimeout: () {
  //           throw const SocketException('Something went wrong');
  //         },
  //       );
  //   responseJson = responses(response);
  //   
  //   return responseJson;
  // }
  // Future<http.Response> PostAsViewedApi(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/markPostAsViewed';
  //   
  //   var responseJson;
  //   final response = await http
  //       .post(Uri.parse(url), body: bodyData)
  //       .timeout(
  //         const Duration(seconds: 60),
  //         onTimeout: () {
  //           throw const SocketException('Something went wrong');
  //         },
  //       );
  //   responseJson = responses(response);
  //   
  //   return responseJson;
  // }
  // Future<http.Response> OfferPromoAsViewed(Map<String, String> bodyData) async {
  //   const url = '${baseUrl}/markOfferPromoAsViewed';
  //   
  //   var responseJson;
  //   final response = await http
  //       .post(Uri.parse(url), body: bodyData)
  //       .timeout(
  //         const Duration(seconds: 60),
  //         onTimeout: () {
  //           throw const SocketException('Something went wrong');
  //         },
  //       );
  //   responseJson = responses(response);
  //   
  //   return responseJson;
  // }
  // Future<http.Response> stroyapi(String UserId, id) async {
  //   String url = '${baseUrl}/listFeaturedPosts?user_id=$UserId&business_id=$id';
  //   
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
  //       
  //       log("lat");
  //       return response;
  //     } else {
  //       
  //       throw Exception("Failed to connect to the server");
  //     }
  //   } on SocketException catch (e) {
  //     throw Exception('No Internet connection: $e');
  //   } catch (e) {
  //     throw Exception('An error occurred: $e');
  //   }
  // }
// }
