import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorageService {
  static final _random = Random.secure();
  static const _keyLength = 32; // 256 bits
  static const _ivLength = 16; // 128 bits

  // Generate a secure random key
  static List<int> _generateSecureKey() {
    return List<int>.generate(_keyLength, (i) => _random.nextInt(256));
  }

  // Generate a secure random IV
  static List<int> _generateSecureIV() {
    return List<int>.generate(_ivLength, (i) => _random.nextInt(256));
  }

  // Encrypt data using AES-GCM
  static Map<String, String> encryptData(String data) {
    try {
      final keyBytes = _generateSecureKey();
      final ivBytes = _generateSecureIV();

      // Properly create Key and IV objects
      final key = encrypt.Key.fromBase16(
          keyBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join());
      final iv = encrypt.IV.fromBase16(
          ivBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join());

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
      final encrypted = encrypter.encrypt(data, iv: iv);

      return {
        'data': encrypted.base64,
        'iv': base64.encode(ivBytes),
        'key': base64.encode(keyBytes),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Encryption error: $e');
      }
      throw Exception('Encryption failed');
    }
  }

  // Decrypt data using AES-GCM
  static String decrypt(Map<String, String> encryptedData) {
    try {
      final keyBytes = base64.decode(encryptedData['key']!);
      final ivBytes = base64.decode(encryptedData['iv']!);

      // Properly create Key and IV objects
      final key = encrypt.Key(Uint8List.fromList(keyBytes));
      final iv = encrypt.IV(Uint8List.fromList(ivBytes));

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData['data']!);

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      if (kDebugMode) {
        print('Decryption error: $e');
      }
      throw Exception('Decryption failed');
    }
  }

  // Hash data using SHA-256
  static String hash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }
}
