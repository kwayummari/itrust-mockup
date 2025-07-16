import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class CertificatePinningService {
  // Production certificate fingerprints - REPLACE WITH YOUR ACTUAL CERTIFICATES
  static const Map<String, List<String>> _certificatePins = {
    'investor.itrust.co.tz': [
      'sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=', // Replace with actual
      'sha256/Vjs8r4z+80wjNcr1YKepWQboSIRi63WsWXhIMN+eWys=', // Backup cert
    ],
    'investoruat.itrust.co.tz': [
      'sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=', // Replace with actual
      'sha256/Vjs8r4z+80wjNcr1YKepWQboSIRi63WsWXhIMN+eWys=', // Backup cert
    ],
  };

  static bool _isValidCertificate(X509Certificate cert, String host, int port) {
    try {
      final pins = _certificatePins[host];
      if (pins == null || pins.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No certificate pins configured for host: $host');
        }
        return false;
      }

      // Get certificate public key hash
      final publicKeyBytes = cert.der;
      final publicKeyHash = sha256.convert(publicKeyBytes).bytes;
      final publicKeyPin = 'sha256/${base64.encode(publicKeyHash)}';

      final isValid = pins.contains(publicKeyPin);

      if (!isValid) {
        if (kDebugMode) {
          print('❌ Certificate pinning failed for $host');
          print('Expected one of: ${pins.join(', ')}');
          print('Received: $publicKeyPin');
        }
      } else {
        if (kDebugMode) {
          print('✅ Certificate pinning successful for $host');
        }
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Certificate validation error: $e');
      }
      return false;
    }
  }

  static HttpClient createSecureHttpClient() {
    final client = HttpClient();

    // Set security context
    client.badCertificateCallback = (cert, host, port) {
      return _isValidCertificate(cert, host, port);
    };

    // Additional security settings
    client.connectionTimeout = const Duration(seconds: 10);
    client.idleTimeout = const Duration(seconds: 30);

    return client;
  }
}

class SecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return CertificatePinningService.createSecureHttpClient();
  }
}
