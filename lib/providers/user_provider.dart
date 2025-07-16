import 'package:iwealth/models/nidaQns.dart';
import 'package:iwealth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  Nidaqns? _nidaqns;

  User? get user => _user;
  Nidaqns? get nidaqns => _nidaqns;

  set user(User? fname) {
    _user = fname;
    notifyListeners();
  }

  set nidaqns(Nidaqns? nidaqns) {
    _nidaqns = nidaqns;
    notifyListeners();
  }

  Future<void> updateProfileStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? profile = SessionPref.getUserProfile();
    if (profile != null && profile.length > 6) {
      profile[6] = status;
      await prefs.setStringList(
          'mengi', profile); // Use 'mengi' instead of 'user_profile'
      notifyListeners();
    }
  }
}
