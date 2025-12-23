import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ensure SSL certificate pinning is not disabled', () {
    final file = File('lib/Utils/apiConfig.dart');
    final content = file.readAsStringSync();

    // Check if the SecurityContext is initialized with withTrustedRoots: false
    expect(content.contains('SecurityContext(withTrustedRoots: false)'), isTrue,
        reason: 'SSL Pinning should be enabled with withTrustedRoots: false');

    // Check if the certificate is being loaded
    expect(content.contains("rootBundle.load('assets/certificates/api_cert3.pem')"), isTrue,
        reason: 'API certificate should be loaded from assets');

    // Ensure HttpClient is created with the secure context
    expect(content.contains('HttpClient(context: context)'), isTrue,
        reason: 'HttpClient must be initialized with the SecurityContext');
    
    // Ensure the code is not commented out
    final lines = content.split('\n');
    for (var line in lines) {
      if (line.contains('SecurityContext(withTrustedRoots: false)')) {
        expect(line.trim().startsWith('//'), isFalse, 
            reason: 'SSL Pinning code should not be commented out');
      }
    }
  });
}
