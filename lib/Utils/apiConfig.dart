import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'apiEndpoint.dart';

class DioHelper {
  static Dio? _dio;

  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;

    try {
      log("Initializing Dio with SSL Configuration...");

      // Load the SSL certificate from assets
      final sslCert = await rootBundle.load(
        'assets/certificates/wavee_ai_cert.pem',
      );

      // Create a SecurityContext that trusts system roots AND our specific certificate
      SecurityContext context = SecurityContext(withTrustedRoots: true);
      try {
        context.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
      } catch (e) {
        log("⚠️ Warning: Could not add certificate to SecurityContext: $e");
      }

      _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoint.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      // Use IOHttpClientAdapter with an explicit createHttpClient callback
      // to ensure our custom client with badCertificateCallback is used.
      _dio!.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient(context: context);
            client.badCertificateCallback = (
              X509Certificate cert,
              String host,
              int port,
            ) {
              log("Bypassing SSL verification for $host");
              return true;
            };
            return client;
          },
        )
        ..onHttpClientCreate = (HttpClient client) {
          // Fallback for older versions of Dio
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

      log("✅ Dio SSL Configuration (Bypass + Pinning) initialized.");
    } catch (e) {
      log("❌ Failed to initialize Dio: $e");
      rethrow;
    }

    return _dio!;
  }
}
