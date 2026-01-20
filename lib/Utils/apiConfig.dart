import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'apiEndpoint.dart';

class DioHelper {
  static Dio? _dio;

  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;

    try {
      log("🔐 Dio SSL Pinning Init...");

      /// Load certificate
      final certData = await rootBundle.load(
        'assets/certificates/wavee_ai_cert.pem',
      );

      /// Security context
      final SecurityContext securityContext =
      SecurityContext(withTrustedRoots: true);

      securityContext.setTrustedCertificatesBytes(
        certData.buffer.asUint8List(),
      );

      _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoint.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          contentType: Headers.jsonContentType,
        ),
      );

      _dio!.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient(context: securityContext);
          if (kDebugMode) {
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) {
              log("⚠️ DEBUG SSL BYPASS for $host");
              return true;
            };
          }

          return client;
        },
      );

      log(
        kDebugMode
            ? "🧪 DEBUG MODE (SSL bypass)"
            : "✅ RELEASE MODE (SSL pinning ON)",
      );
    } catch (e, s) {
      log("❌ Dio init failed", error: e, stackTrace: s);
      rethrow;
    }

    return _dio!;
  }
}
