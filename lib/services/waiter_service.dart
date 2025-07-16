import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/User/model/user_kyc.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/main.dart';
import 'package:iwealth/models/sector.dart';
import 'package:iwealth/models/user.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/services/api_endpoints.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:http/http.dart' as http;
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_service.dart';
import 'config.dart';
import 'error_handler.dart';
import 'http_client.dart';

class Waiter {
  final AppConfig _config = AppConfig();

  // Keep the original property for backward compatibility
  String get brokerageGate => _config.brokerMainDoor;

  // ============================================
  // Authentication & User Management
  // ============================================

  /// Generate token - Original implementation preserved
  // Future<void> generateToken() async {
  //   if (!await HttpClientService.hasInternetConnection()) {
  //     throw Exception('No internet connection');
  //   }

  //   var url = Uri.https("192.168.1.49:7777", "/core/connect/token");
  //   var headers = await HttpClientService.getBaseHeaders();

  //   var res = await http.post(url, headers: headers, body: {
  //     "grant_type": "client_credentials",
  //     "scope": "innovaSuiteApi",
  //     "client_id": "innovaSuiteApi",
  //     "client_secret": "secret"
  //   });

  //   var decodeBody = jsonDecode(res.body);

  //   if (res.statusCode == 200) {
  //     if (kDebugMode) {
  //       print(decodeBody);
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print(decodeBody);
  //     }
  //   }
  // }

  /// Request OTP for phone verification - Enhanced with new error handling
  Future<Map<String, dynamic>> requestOTP({
    required String? phone,
    String? appSignature,
    required BuildContext context,
  }) async {
    if (phone == null) {
      ErrorHandler.showError(context, 'Phone number is required');
      return {'status': 'error', 'message': 'Phone number is required'};
    }

    try {
      final result = await APIService.requestOTP(
        phone: phone,
        appSignature: appSignature,
        context: context,
      );

      // Convert to legacy format for backward compatibility
      return {
        'status': result['success'] ? 'success' : 'error',
        'otp': result['otp'],
        'message': result['message'],
      };
    } catch (e) {
      if (kDebugMode) {
        print("EXCEPTION ON REQUESTING OTP DUE TO: $e");
      }
      return {'status': 'error', 'message': "Failed to send OTP"};
    }
  }

  /// Resend OTP - Enhanced with new error handling
  Future<String> resendOTP({
    required String phone,
    required BuildContext context,
  }) async {
    try {
      final result = await APIService.resendOTP(
        phone: phone,
        context: context,
      );

      if (result['success']) {
        if (kDebugMode) {
          print("OTP SENT SUCCESSFULLY");
        }
        return "success";
      } else {
        if (kDebugMode) {
          print("FAIL TO SEND OTP");
        }
        return "fail";
      }
    } catch (e) {
      AppSnackbar(
        isError: true,
        response:
            "Unable to resend OTP. Please check your internet connection and try again.",
      ).show(context);
      if (kDebugMode) {
        print("EXCEPTION ON RESENDING OTP DUE TO: $e");
      }
      return "fail";
    }
  }

  /// Validate OTP - Enhanced with new error handling
  Future<String> validateOTP({
    required String phone,
    required String otp,
    required BuildContext context,
  }) async {
    try {
      final result = await APIService.validateOTP(
        phone: phone,
        otp: otp,
        context: context,
      );

      if (result['success']) {
        if (kDebugMode) {
          print("OTP VERIFIED SUCCESSFULLY");
        }
        return "success";
      } else {
        if (kDebugMode) {
          print("FAIL TO VALIDATE OTP");
        }
        return "fail";
      }
    } catch (e) {
      AppSnackbar(
        isError: true,
        response:
            "Unable to validate OTP. Please check your internet connection and try again.",
      ).show(context);
      if (kDebugMode) {
        print("EXCEPTION ON REQUESTING OTP DUE TO: $e");
      }
      return "fail";
    }
  }

  /// Reset PIN - Enhanced with new error handling
  Future<String> resetPIN({
    required String pin,
    required String confirmPIN,
    required BuildContext context,
  }) async {
    try {
      final result = await APIService.resetPIN(
        pin: pin,
        confirmPIN: confirmPIN,
        context: context,
      );

      if (result['success']) {
        if (kDebugMode) {
          print("RESET PIN SUCCESSFUL");
        }
        return "success";
      } else {
        // Keep original error handling for backward compatibility
        AppSnackbar(
          isError: true,
          response: "Failed to reset PIN. Please try again.",
        ).show(context);
        if (kDebugMode) {
          print("FAIL TO RESET PIN");
        }
        return "fail";
      }
    } catch (e) {
      // Keep original error handling for backward compatibility
      AppSnackbar(
        isError: true,
        response:
            "Unable to reset PIN. Please check your internet connection and try again.",
      ).show(context);
      if (kDebugMode) {
        print("EXCEPTION ON RESETING PASSWORD: $e");
      }
      return "fail";
    }
  }

  /// Register investor - Enhanced with new error handling
  Future<Map<String, dynamic>> registInvestor({
    User? user,
    required String pin,
    required String confirmPIN,
    required BuildContext context,
  }) async {
    if (user == null) {
      return {
        'code': 400,
        'message': 'User information is required',
      };
    }

    return await APIService.registerInvestor(
      user: user,
      pin: pin,
      confirmPIN: confirmPIN,
      context: context,
    );
  }

  /// Authenticate investor - Enhanced with new error handling
  Future<Map<String, dynamic>> authenticateInvestor({
    required String pin,
    required BuildContext context,
  }) async {
    return await APIService.authenticateInvestor(
      pin: pin,
      context: context,
    );
  }

  /// Logout user - Original implementation preserved
  Future<void> logOUT(BuildContext context) async {
    await SessionPref.logOUT().then((val) => {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
          )
        });
  }

  /// Get user profile - Enhanced with new error handling
  Future<String> getUserProfile(String token) async {
    return await APIService.getUserProfile();
  }

  /// Get countries - Original implementation preserved
  Future<void> getCountries() async {
    try {
      var url = Uri.https(brokerageGate, APIEndpoints.countriesList);
      var res = await http.get(url);
      var decodeBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        print(decodeBody);
      } else {
        print(decodeBody);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting countries: $e");
      }
    }
  }

  // ============================================
  // NIDA Verification - All original methods preserved
  // ============================================

  /// NIDA biometric verification - Original implementation with enhanced error handling
  Future<VerificationResult> nidaBioVerification(
    String nin,
    String fingerCode,
    String fingerImage,
    UserProvider up,
    BuildContext context,
    bool isFingerScanner,
  ) async {
    return await APIService.nidaBioVerification(
      nin: nin,
      fingerCode: fingerCode,
      fingerImage: fingerImage,
      up: up,
      context: context,
      isFingerScanner: isFingerScanner,
    );
  }

  /// Get NIDA security questions - Original implementation with enhanced error handling
  Future<VerificationResult> nidaGetQuestions({
    required String nin,
    required UserProvider up,
    required BuildContext context,
  }) async {
    return await APIService.nidaGetQuestions(
      nin: nin,
      up: up,
      context: context,
    );
  }

  /// Answer NIDA security question - Original implementation with enhanced error handling
  Future<VerificationResult> nidaAnswerQuestion({
    required String nin,
    required String questionCode,
    required String answer,
    required UserProvider up,
    required BuildContext context,
  }) async {
    return await APIService.nidaAnswerQuestion(
      nin: nin,
      questionCode: questionCode,
      answer: answer,
      up: up,
      context: context,
    );
  }

  // ============================================
  // KYC Operations - Original implementation preserved
  // ============================================

  /// Submit KYC information - Enhanced with new error handling
  Future<Map<String, dynamic>> submitKYC({
    required USERKYC userkyc,
    required MetadataProvider mp,
    required BuildContext context,
  }) async {
    return await APIService.submitKYC(
      userkyc: userkyc,
      mp: mp,
      context: context,
    );
  }

  /// Update profile status - Original private method preserved
  Future<void> _updateProfileStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? profile = SessionPref.getUserProfile();
    if (profile != null && profile.length > 6) {
      profile[6] = status;
      await prefs.setStringList('user_profile', profile);
    }
  }

  // ============================================
  // Metadata Operations - All original methods preserved
  // ============================================

  /// Get sectors or banks - Original implementation with enhanced error handling
  Future<String> getSectors(String identifier, dynamic container) async {
    try {
      print("===========$identifier");
      return await APIService.getSectors(identifier, container);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting sectors: $e");
      }
      return "0";
    }
  }

  // Future<String> getRelations(dynamic container) async {
  //   try {
  //     return await APIService.getSectors('relationships', container);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error getting sectors: $e");
  //     }
  //     return "0";
  //   }
  // }

  /// Get source of income metadata - Original implementation with enhanced error handling
  Future<String> getSourceOfIncome(String data, dynamic provider) async {
    try {
      return await APIService.getSourceOfIncome(data, provider);
    } catch (e) {
      if (kDebugMode) {
        print("EROR getting source of income: $e");
      }
      return "0";
    }
  }

  Future<String> getTitles(dynamic provider) async {
    try {
      return await APIService.getTitles(provider);
    } catch (e) {
      if (kDebugMode) {
        print("ERROR getting titles: $e");
      }
      return "0";
    }
  }

  /// Get metadata helper - Original private method preserved
  Future<http.Response> _getMetadata(
      {required String endpoint, Map<String, String>? params}) async {
    var url = Uri.https(brokerageGate, endpoint, params);
    var headers = await HttpClientService.getBaseHeaders();
    var res = await http.get(url, headers: headers);
    return res;
  }

  /// Get regions - Original implementation preserved
  Future<String> getRegionBR({required MetadataProvider mp}) async {
    if (!await HttpClientService.hasInternetConnection()) {
      throw Exception('No internet connection');
    }

    try {
      List<Metadata> meta = [];
      var url = Uri.https(brokerageGate, APIEndpoints.regionEp);
      var headers = await HttpClientService.getBaseHeaders();
      var res = await http.get(url, headers: headers);
      var decoded = jsonDecode(res.body);

      if (res.statusCode == 200) {
        print("REGIONS: $decoded");

        for (var each in decoded) {
          Metadata metadata =
              Metadata(id: each["regioncode"], name: each["region"]);
          meta.add(metadata);
        }
        mp.regions = meta;
        return "success";
      } else {
        print("REGIONS PULLER FAIL DUE TO: $decoded");
        return "fail";
      }
    } catch (e) {
      print("EXCEPTION ON REGIONS OCCUR DUE TO: $e");
      return "fail";
    }
  }

  /// Get districts by region code - Original implementation preserved
  Future<List<Metadata>?> getDistrictBR({required String code}) async {
    if (!await HttpClientService.hasInternetConnection()) {
      throw Exception('No internet connection');
    }

    try {
      List<Metadata> meta = [];
      var res = await _getMetadata(
          endpoint: APIEndpoints.districtEp, params: {"code": code});
      var decoded = jsonDecode(res.body);

      if (res.statusCode == 200) {
        print("PULL DISTRICT SUCCESSFULLY: $decoded");
        for (var each in decoded) {
          Metadata metadata =
              Metadata(id: each["districtcode"], name: each["district"]);
          meta.add(metadata);
        }
        return meta;
      } else {
        print("FAIL TO PULL DISTRICT: $decoded");
        return null;
      }
    } catch (e) {
      print("EXCEPTION ON PULLING DISTRICTS DUE TO: $e");
      return null;
    }
  }

  Future<String> getRelations(MetadataProvider provider) async {
    if (!await HttpClientService.hasInternetConnection()) {
      return "0";
    }

    try {
      List<Metadata> meta = [];
      var res = await _getMetadata(
          endpoint: APIEndpoints.relations); // <- use the correct endpoint
      var decoded = jsonDecode(res.body);

      if (res.statusCode == 200) {
        print("PULL RELATIONSHIPS SUCCESSFULLY: $decoded");
        for (var each in decoded) {
          Metadata metadata = Metadata(id: each["id"], name: each["name"]);
          meta.add(metadata);
        }

        provider.kins = meta; // ✅ THIS IS THE KEY LINE YOU'RE MISSING

        return "1";
      } else {
        print("FAIL TO PULL RELATIONSHIPS: $decoded");
        return "0";
      }
    } catch (e) {
      print("EXCEPTION ON PULLING RELATIONSHIPS DUE TO: $e");
      return "0";
    }
  }


  /// Get wards by district code - Original implementation preserved
  Future<List<Metadata>?> getWardBR({required String code}) async {
    if (!await HttpClientService.hasInternetConnection()) {
      throw Exception('No internet connection');
    }

    try {
      List<Metadata> meta = [];
      var res = await _getMetadata(
          endpoint: APIEndpoints.wardEp, params: {"code": code});
      var decoded = jsonDecode(res.body);

      if (res.statusCode == 200) {
        print("PULL WARDS SUCCESSFULLY: $decoded");
        for (var each in decoded) {
          Metadata metadata =
              Metadata(id: each["wardcode"], name: each["ward"]);
          meta.add(metadata);
        }
        return meta;
      } else {
        print("FAIL TO PULL WARDS: $decoded");
        return null;
      }
    } catch (e) {
      print("EXCEPTION ON PULLING WARDS DUE TO: $e");
      return null;
    }
  }

  /// Fetch regions - Original implementation preserved
  Future<List<Metadata>> fetchRegions() async {
    if (!await HttpClientService.hasInternetConnection()) {
      throw Exception('No internet connection');
    }

    var url = Uri.https(brokerageGate, APIEndpoints.regionEp);
    var headers = await HttpClientService.getBaseHeaders();
    var res = await http.get(url, headers: headers);
    var decoded = jsonDecode(res.body);

    if (res.statusCode == 200) {
      List<Metadata> regions = [];
      for (var each in decoded) {
        Metadata region =
            Metadata(id: each["regioncode"], name: each["region"]);
        regions.add(region);
      }
      return regions;
    } else {
      throw Exception("Failed to load regions");
    }
  }

  /// Fetch districts by region code - Original implementation preserved
  Future<List<Metadata>> fetchDistricts(String regionCode) async {
    if (!await HttpClientService.hasInternetConnection()) {
      throw Exception('No internet connection');
    }

    var url =
        Uri.https(brokerageGate, APIEndpoints.districtEp, {"code": regionCode});
    var headers = await HttpClientService.getBaseHeaders();
    var res = await http.get(url, headers: headers);
    var decoded = jsonDecode(res.body);

    if (res.statusCode == 200) {
      List<Metadata> districts = [];
      for (var each in decoded) {
        Metadata district =
            Metadata(id: each["districtcode"], name: each["district"]);
        districts.add(district);
      }
      return districts;
    } else {
      throw Exception("Failed to load districts");
    }
  }

  /// Fetch wards by district code - Original implementation preserved
  Future<List<Metadata>> fetchWards(String districtCode) async {
    if (!await HttpClientService.hasInternetConnection()) {
      throw Exception('No internet connection');
    }

    var url =
        Uri.https(brokerageGate, APIEndpoints.wardEp, {"code": districtCode});
    var headers = await HttpClientService.getBaseHeaders();
    var res = await http.get(url, headers: headers);
    var decoded = jsonDecode(res.body);

    if (res.statusCode == 200) {
      List<Metadata> wards = [];
      for (var each in decoded) {
        Metadata ward = Metadata(id: each["wardcode"], name: each["ward"]);
        wards.add(ward);
      }
      return wards;
    } else {
      throw Exception("Failed to load wards");
    }
  }

  // ============================================
  // External Links - Original implementation preserved
  // ============================================

  final _url = Uri.parse(
      "https://drive.google.com/file/d/1gJFrWi_EMVKCLkIxm3Gikj_X7jpMeOKZ/view?usp=sharing");

  final _itrGPT = Uri.parse("https://chatgpt.com/g/g-BpdhkA1hL-itrust-gpt");

  /// Launch help document in browser - Original implementation preserved
  Future<void> launchInBrowser() async {
    if (!await launchUrl(
      _url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $_url');
    }
  }

  /// Launch iTrust GPT in browser - Original implementation preserved
  Future<void> launchITRGPT() async {
    if (!await launchUrl(
      _itrGPT,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $_itrGPT');
    }
  }
}
