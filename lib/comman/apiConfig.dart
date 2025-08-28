import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Needed for DefaultHttpClientAdapter
import 'package:flutter/services.dart' show rootBundle;
import 'package:wavee/comman/apiEndpoint.dart';

class DioHelper {
  static Dio? _dio;

  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;
    final sslCert = await rootBundle.load('assets/certificates/wavee_cert.pem');
    SecurityContext context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
    final HttpClient client = HttpClient(context: context);
    final adapter = IOHttpClientAdapter();
    adapter.onHttpClientCreate = (HttpClient _) => client;
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoint.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    _dio!.httpClientAdapter = adapter;
    return _dio!;
  }
}
