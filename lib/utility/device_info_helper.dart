import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/security/secure_storage_service.dart';

class DeviceInfoHelper {
  static const String _deviceIdKey = 'secure_device_id';
  static const String _deviceNameKey = 'secure_device_name';

  static Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString(_deviceIdKey);

      if (encryptedData != null) {
        final Map<String, String> storedData =
            Map<String, String>.from(json.decode(encryptedData));
        return SecureStorageService.decrypt(storedData);
      }

      // Generate new device ID if none exists
      final deviceId = await _generatePersistentDeviceId();
      final encryptedId = SecureStorageService.encryptData(deviceId);
      await prefs.setString(_deviceIdKey, json.encode(encryptedId));
      return deviceId;
    } catch (e) {
      if (kDebugMode) {
        print('Error accessing device ID: $e');
      }
      return await _generatePersistentDeviceId();
    }
  }

  static Future<String> getDeviceName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString(_deviceNameKey);

      if (encryptedData != null) {
        final Map<String, String> storedData =
            Map<String, String>.from(json.decode(encryptedData));
        return SecureStorageService.decrypt(storedData);
      }

      final deviceName = await _generateDeviceName();
      final encryptedName = SecureStorageService.encryptData(deviceName);
      await prefs.setString(_deviceNameKey, json.encode(encryptedName));
      return deviceName;
    } catch (e) {
      return 'Unknown Device';
    }
  }

  static Future<String> _generatePersistentDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Use hardware-specific information that persists across app reinstalls
        String deviceData = '${androidInfo.board}-${androidInfo.brand}-'
            '${androidInfo.device}-${androidInfo.hardware}-'
            '${androidInfo.fingerprint}';
        return const Uuid().v5(Uuid.NAMESPACE_URL, deviceData);
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // Use hardware-specific information that persists across app reinstalls
        String deviceData = '${iosInfo.systemName}-${iosInfo.model}-'
            '${iosInfo.systemVersion}-${iosInfo.utsname.machine}-'
            '${iosInfo.utsname.nodename}';
        return const Uuid().v5(Uuid.NAMESPACE_URL, deviceData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating device ID: $e');
      }
    }
    // Fallback to random UUID if device info cannot be retrieved
    return const Uuid().v4();
  }

  static Future<String> _generateDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        // Capitalize brand name and clean up the model name
        String brand = info.brand.toString().capitalize();
        String model = info.model.toString().replaceAll(brand, '').trim();
        return "$brand $model";
      } else if (Platform.isIOS) {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        // Convert machine name to friendly name (e.g., iPhone14,3 -> iPhone 13 Pro)
        String deviceName = _getiOSDeviceName(info.utsname.machine);
        return deviceName;
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  static String _getiOSDeviceName(String identifier) {
    // Map of iOS device identifiers to their marketing names
    final deviceNames = {
      'iPhone14,2': 'iPhone 13 Pro',
      'iPhone14,3': 'iPhone 13 Pro Max',
      'iPhone14,4': 'iPhone 13 Mini',
      'iPhone14,5': 'iPhone 13',
      'iPhone15,2': 'iPhone 14 Pro',
      'iPhone15,3': 'iPhone 14 Pro Max',
      'iPhone15,4': 'iPhone 14',
      'iPhone15,5': 'iPhone 14 Plus',
      'iPhone16,1': 'iPhone 15 Pro',
      'iPhone16,2': 'iPhone 15 Pro Max',
      'iPhone16,3': 'iPhone 15',
      'iPhone16,4': 'iPhone 15 Plus',
      // Add more identifiers as needed
    };

    return deviceNames[identifier] ?? 'iPhone';
  }
}

// Add this extension to help capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
