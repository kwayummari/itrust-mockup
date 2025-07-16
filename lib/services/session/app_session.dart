import 'package:flutter/foundation.dart';
import 'package:iwealth/models/nidamodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionPref {
  static late SharedPreferences pref;
  static const keyName = "tokeni";
  static const jadu = "jadu";
  static const mengi = "mengi";
  static const img = 'user';
  static const utype = "utype";
  static const keyLog = "hasLog";
  static const nidaKey = "nidaKi";
  static const onboardKey = "okey";
  static const challenge = "persistentChallengTkn";
  static const subscriptionsKey = "subscriptions";

  static Future init() async => pref = await SharedPreferences.getInstance();

  static Future setToken(String accessToken, refreshToken, expireOn) async {
    // Convert expireIn (seconds) to actual expiry timestamp
    final expiryTime = DateTime.now()
        .add(Duration(seconds: int.parse(expireOn)))
        .millisecondsSinceEpoch
        .toString();

    if (kDebugMode) {
      print('Setting new token:');
      print('Access Token Length: ${accessToken.length}');
      print('Refresh Token Length: ${refreshToken.length}');
      print('Expires In: $expireOn seconds');
      print('Expiry Time: $expiryTime');
    }

    return await pref.setStringList(
      keyName,
      <String>[accessToken, refreshToken, expiryTime],
    );
  }

  static Future setName(name) async => await pref.setString(jadu, name);

  static Future setChallenge({required data}) async =>
      await pref.setString(challenge, data);

  static Future setUserType(type) async => await pref.setString(utype, type);
  static Future saveOnboardData({phone, email}) async =>
      await pref.setStringList(onboardKey, [phone, email]);

  static Future<bool> setUserProfile({
    String? id = '',
    String? status = '',
    String? onboardStatus = '',
    String? fname = '',
    String? mname = '',
    String? lname = '',
    String? email = '',
    String? phone = '',
    String? wallet = '',
    String? accounNumber = '',
    String? innova = '',
    List<dynamic>? subscriptions,
  }) async {
    try {
      await pref.setStringList(mengi, <String>[
        fname ?? '', // 0
        mname ?? '', // 1
        lname ?? '', // 2
        email ?? '', // 3
        phone ?? '', // 4
        id ?? '', // 5
        onboardStatus ?? 'pending', // 6
        status ?? '', // 7
        wallet ?? '0', // 8
        accounNumber ?? '', // 9
        innova ?? '' //10
      ]);

      // Store subscriptions separately as JSON
      if (subscriptions != null) {
        await pref.setString(subscriptionsKey, jsonEncode(subscriptions));
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error setting user profile: $e");
      }
      return false;
    }
  }

  static String? getUserType() {
    var data = pref.getString(utype);
    return data;
  }

  static String? getChallenge() {
    var data = pref.getString(challenge);
    return data;
  }

  static List<String>? getUserProfile() {
    var data = pref.getStringList(mengi);
    return data;
  }

  static List<String>? getOnboardData() {
    var data = pref.getStringList(onboardKey);

    return data;
  }

  static List<String>? getToken() {
    final data = pref.getStringList(keyName);
    if (kDebugMode && data != null) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(data[2]),
      );
      if (kDebugMode) {
        print('Token expiry time: $expiryTime');
      }
    }
    return data;
  }

  static Future deleteToken() async => pref.remove(keyName);

  static String? getDataList() {
    var data = pref.getString(jadu);
    return data;
  }

  static Future createSession(session) async =>
      await pref.setString(keyLog, session);

  static getSession() {
    var data = pref.getString(keyLog);

    return data;
  }

  static Future logOUT() async => await pref.remove(keyLog);

  // nida info list

  static Future setNIDA(NIDA nida, String nin) async =>
      await pref.setStringList(nidaKey, <String>[
        nida.birthCountry, // 0
        nida.birthDistrict, // 1
        nida.birthRegion, // 2
        nida.dob, // 3
        nida.fname, // 4
        nida.lname, // 5
        nida.mname, // 6
        nida.nin, // 7
        nida.pob, // 8
        nida.resDistrict, // 9
        nida.resRegion, // 10
        nida.resVillage, // 11
        nida.resWard, // 12
        nida.sex,
        nida.photo
      ]);

  static List<String>? getNIDA() {
    var data = pref.getStringList(nidaKey);
    return data;
  }

  static clearNIDA() async => await pref.remove(nidaKey);

  static List<dynamic>? getUserSubscriptions() {
    try {
      final subsString = pref.getString(subscriptionsKey);
      if (subsString == null) {
        if (kDebugMode) {
          print("No subscriptions data found in preferences");
        }
        return null;
      }

      final decodedData = jsonDecode(subsString);
      if (kDebugMode) {
        print("Decoded subscription data:");
        print(decodedData);
      }
      return decodedData;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting subscriptions: $e");
      }
      return null;
    }
  }

  // Add this method to your SessionPref class
  static Future<void> clearSession() async {
    try {
      await deleteToken();
      await logOUT();
      await clearNIDA();
      await pref.remove(challenge);
      await pref.remove(onboardKey);
      await pref.remove(mengi);
      await pref.remove(subscriptionsKey);
      await pref.remove(jadu);
      await pref.remove(utype);

      if (kDebugMode) {
        print('Session cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing session: $e');
      }
    }
  }
}
