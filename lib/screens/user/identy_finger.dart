import 'dart:async';

import 'package:flutter/services.dart';

class IdentyFinger {
  static const MethodChannel _channel = MethodChannel('identy_finger');
  static Future<String?> capture(String value) async {
    try {
      dynamic dataToPass = <String, dynamic>{
        'hand': value,
      };

      final String? result =
          (await _channel.invokeMethod<String>('capture', dataToPass));

      return result;
    } catch (e) {
      // print(e);

      return '';
    }
  }
}
