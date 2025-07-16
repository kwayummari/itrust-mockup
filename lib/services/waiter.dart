// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:iwealth/User/model/user_kyc.dart';
// import 'package:iwealth/User/providers/metadata.dart';
// import 'package:iwealth/main.dart';

// import 'package:iwealth/models/nidaQns.dart';
// import 'package:iwealth/models/nidamodel.dart';
// import 'package:iwealth/models/sector.dart';
// import 'package:iwealth/models/user.dart';
// import 'package:iwealth/providers/user_provider.dart';
// import 'package:iwealth/services/auth/token_service.dart';
// import 'package:iwealth/services/api_endpoints.dart';
// import 'package:iwealth/services/keys.dart';
// import 'package:iwealth/services/session/app_session.dart';

// import 'package:iwealth/stocks/widgets/btmSheet.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:iwealth/utility/device_info_helper.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

// class CustomHttpClient {
//   static Future<bool> checkInternetConnection() async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) {
//       return false;
//     }
//     return true;
//   }

//   static Future<Map<String, String>> getHeaders() async {
//     String deviceId = await DeviceInfoHelper.getDeviceId();
//     String deviceName = await DeviceInfoHelper.getDeviceName();
//     return {
//       'Content-Type': 'application/json',
//       'Device-Id': deviceId,
//       'Device-Name': deviceName,
//     };
//   }

//   static Future<Map<String, String>> getAuthHeaders() async {
//     if (kDebugMode) {
//       print('\n=== Getting Auth Headers ===');
//     }

//     final headers = await getHeaders();

//     if (TokenService.isTokenExpired()) {
//       if (kDebugMode) {
//         print('🔄 Token needs refresh, attempting refresh...');
//       }

//       final refreshed = await TokenService.refreshToken();
//       if (!refreshed) {
//         if (kDebugMode) {
//           print('❌ Token refresh failed');
//         }
//         throw Exception('Token refresh failed');
//       }

//       if (kDebugMode) {
//         print('✅ Token refreshed successfully');
//       }
//     } else if (kDebugMode) {
//       print('✅ Token is still valid');
//     }

//     final token = SessionPref.getToken()?[0];
//     if (kDebugMode) {
//       print('Token length: ${token?.length}');
//     }

//     headers['Authorization'] = 'Bearer $token';
//     return headers;
//   }

//   static Future<http.Response> post(Uri url,
//       {Map<String, String>? headers, Object? body}) async {
//     if (!await checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       if (kDebugMode) {
//         print('\n=== HTTP POST Request ===');
//         print('URL: $url');
//       }

//       final combinedHeaders = headers != null
//           ? {...await getAuthHeaders(), ...headers}
//           : await getAuthHeaders();

//       if (kDebugMode) {
//         print('Headers: $combinedHeaders');
//         print('Body: $body');
//       }

//       final response =
//           await http.post(url, headers: combinedHeaders, body: body);

//       if (kDebugMode) {
//         print('\nResponse status: ${response.statusCode}');
//         print('Response body length: ${response.body.length}');
//       }

//       if (response.statusCode == 401) {
//         if (kDebugMode) {
//           print('⚠️ Unauthorized response, attempting token refresh...');
//         }

//         final refreshed = await TokenService.refreshToken();
//         if (refreshed) {
//           if (kDebugMode) {
//             print('✅ Token refreshed, retrying request');
//           }
//           combinedHeaders['Authorization'] =
//               'Bearer ${SessionPref.getToken()![0]}';
//           return http.post(url, headers: combinedHeaders, body: body);
//         }
//       }
//       return response;
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('\n❌ HTTP POST error:');
//         print('Error: $e');
//         print('Stack trace:\n$stackTrace');
//       }
//       rethrow;
//     }
//   }

//   static Future<http.Response> get(Uri url,
//       {Map<String, String>? headers}) async {
//     if (!await checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       final combinedHeaders = headers != null
//           ? {...await getAuthHeaders(), ...headers}
//           : await getAuthHeaders();

//       final response = await http.get(url, headers: combinedHeaders);

//       if (response.statusCode == 401) {
//         // Try refreshing token on unauthorized
//         final refreshed = await TokenService.refreshToken();
//         if (refreshed) {
//           // Retry the request with new token
//           combinedHeaders['Authorization'] =
//               'Bearer ${SessionPref.getToken()![0]}';
//           return http.get(url, headers: combinedHeaders);
//         }
//       }
//       return response;
//     } catch (e) {
//       print('HTTP GET error: $e');
//       rethrow;
//     }
//   }
// }

// class VerificationResult {
//   final String status;
//   final dynamic success;
//   final String message;
//   final dynamic data;

//   VerificationResult({
//     required this.status,
//     this.success,
//     required this.message,
//     this.data,
//   });
// }

// class Waiter {
//   // final mainGate = API().mainDoor;
//   final brokerageGate = API().brokerLinkMainDoor;

//   generateToken() async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     var url = Uri.https("192.168.1.49:7777", "/core/connect/token");
//     var headers = await CustomHttpClient.getHeaders();
//     var res = await http.post(url, headers: headers, body: {
//       "grant_type": "client_credentials",
//       "scope": "innovaSuiteApi",
//       "client_id": "innovaSuiteApi",
//       "client_secret": "secret"
//     });

//     var decodeBody = jsonDecode(res.body);

//     if (res.statusCode == 200) {
//       if (kDebugMode) {
//         print(decodeBody);
//       }
//     } else {
//       if (kDebugMode) {
//         print(decodeBody);
//       }
//     }
//   }

//   /* ============================================ BROKERAGE APIs ==============================================
//       All Brokerage API will be consumed belows
//     ===========================================================================================================
//   */

//   requestOTP(
//       {required String? phone,
//       String? appSignature,
//       required BuildContext context}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       var url = Uri.https(brokerageGate, API().requestOTPEndpoint);
//       var headers = await CustomHttpClient.getHeaders();
//       var body = jsonEncode({"mobile": phone, "appSignature": appSignature});

//       var res = await http.post(url, headers: headers, body: body);
//       var decoded = jsonDecode(res.body);

//       if (res.statusCode == 200 && decoded["code"] == 100) {
//         if (kDebugMode) {
//           print("OTP SENT SUCCESSFULLY, $decoded");
//         }

//         String? testOtp;
//         if (decoded.containsKey("data") && decoded["data"]["otp"] != null) {
//           testOtp = decoded["data"]["otp"].toString();
//         }

//         return {
//           'status': 'success',
//           'otp': testOtp,
//           'message': 'OTP sent successfully'
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': decoded["message"] ?? "Failed to send OTP"
//         };
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("EXCEPTION ON REQUESTING OTP DUE TO: $e");
//       }
//       return {'status': 'error', 'message': "Failed to send OTP"};
//     }
//   }

//   resendOTP({required phone, required context}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       var url = Uri.https(brokerageGate, API().resendOTPEndpoint);
//       var headers = await CustomHttpClient.getHeaders();
//       var body = jsonEncode({
//         "mobile": phone,
//       });
//       var res = await http.post(url, headers: headers, body: body);
//       if (res.statusCode == 200) {
//         if (kDebugMode) {
//           print("OTP SENT SUCCESSFULLY");
//         }
//         return "success";
//       } else {
//         if (kDebugMode) {
//           print("FAIL TO SEND OTP");
//         }
//         return "fail";
//       }
//     } catch (e) {
//       Btmsheet().errorSheet(context, "Resend OTP Failed",
//           "Unable to resend OTP. Please check your internet connection and try again.");
//       if (kDebugMode) {
//         print("EXCEPTION ON RESENDING OTP DUE TO: $e");
//       }
//     }
//   }

//   validateOTP({required phone, required otp, required context}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       var url = Uri.https(brokerageGate, API().verifyOTPEndpoint);
//       var headers = await CustomHttpClient.getHeaders();
//       var body = jsonEncode({
//         "mobile": phone,
//         "user_otp": otp,
//       });
//       var res = await http.post(url, headers: headers, body: body);
//       var decoded = jsonDecode(res.body);
//       if (res.statusCode == 200 && "${decoded["code"]}" == "100") {
//         SessionPref.saveOnboardData(email: "", phone: phone);
//         SessionPref.setChallenge(data: decoded["data"]["challenge"]);
//         if (kDebugMode) {
//           print("OTP VERIFIED SUCCESSFULLY: $decoded");
//         }
//         return "success";
//       } else {
//         if (kDebugMode) {
//           print("FAIL TO VALIDATE OTP: $decoded");
//         }
//         return "fail";
//       }
//     } catch (e) {
//       Btmsheet().errorSheet(context, "Validate OTP Failed",
//           "Unable to validate OTP. Please check your internet connection and try again.");
//       if (kDebugMode) {
//         print("EXCEPTION ON REQUESTING OTP DUE TO: $e");
//       }
//     }
//   }

//   resetPIN({required pin, required confirmPIN, required context}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     var url = Uri.https(brokerageGate, API().resetPINEndpoint);
//     var headers = await CustomHttpClient.getHeaders();
//     var body = jsonEncode({
//       "challenge": SessionPref.getChallenge(),
//       "mobile": SessionPref.getOnboardData()![0],
//       "user_pin": pin,
//       "user_pin_confirmation": confirmPIN,
//     });
//     if (kDebugMode) {
//       print("reset pin body: $body");
//     }

//     try {
//       var res = await http.post(url, body: body, headers: headers);
//       var decoded = jsonDecode(res.body);

//       if (res.statusCode == 200 && decoded["code"] == 100) {
//         if (kDebugMode) {
//           print("RESET PIN BODY: $decoded");
//         }

//         return "success";
//       } else {
//         Btmsheet().errorSheet(context, "PIN Reset Failed",
//             "Failed to reset PIN. Please try again.");
//         if (kDebugMode) {
//           print("FAIL TO RESET DUE TO: $decoded");
//         }
//         return "fail";
//       }
//     } catch (e) {
//       Btmsheet().errorSheet(context, "PIN Reset Failed",
//           "Unable to reset PIN. Please check your internet connection and try again.");
//       if (kDebugMode) {
//         print("EXCEPTION ON RESETING PASSWORD: $e");
//       }
//     }
//   }

//   // Investor Registration:
//   Future<Map<String, dynamic>> registInvestor(
//       {User? user, pin, confirmPIN, required context}) async {
//     try {
//       var headers = await CustomHttpClient.getHeaders();
//       var body = jsonEncode({
//         "type": "individual",
//         "firstname": user?.fname,
//         "middlename": user?.mname,
//         "lastname": user?.lname,
//         "email": user?.email,
//         "country_code": user?.country,
//         "mobile": "${user?.phone}",
//         "user_pin": "$pin",
//         "user_pin_confirmation": confirmPIN,
//         "terms_of_service": true,
//         "required_email_verification": true,
//       });

//       var url = Uri.https(brokerageGate, API().createInvestor);
//       var res = await http.post(url, body: body, headers: headers);
//       var decodedBody = jsonDecode(res.body);

//       if (kDebugMode) {
//         print("Registration response: ${res.body}");
//       }

//       if (res.statusCode == 200) {
//         if (decodedBody["code"] == 100) {
//           return {
//             "code": decodedBody["code"],
//             "message": decodedBody["message"],
//             "data": decodedBody
//           };
//         }
//         return {
//           "code": decodedBody["code"],
//           "message": decodedBody["message"] ?? "Registration status unknown",
//           "data": decodedBody
//         };
//       } else {
//         return {
//           "code": decodedBody["code"] ?? res.statusCode,
//           "message": decodedBody["message"] ?? "Registration status unknown",
//           "data": decodedBody
//         };
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("EXCEPTION ON USER REGISTRATION DUE TO: $e");
//       }
//       return {"code": 500, "message": "Registration failed: ${e.toString()}"};
//     }
//   }

//   authenticateInvestor({required pin, required context}) async {
//     var url = Uri.https(brokerageGate, API().authenticate);

//     var body = jsonEncode({
//       "password": pin,
//       "username": SessionPref.getOnboardData()![0],
//       "challenge": SessionPref.getChallenge(),
//       "grant_type": "password",
//       "client_id": Keys().clientId,
//       "client_secret": Keys().clientSecret,
//       "scope": "*",
//     });

//     if (kDebugMode) {
//       print("AUTHENTICATE BODY: $body");
//     }

//     try {
//       var headers = await CustomHttpClient.getHeaders();
//       var res = await http.post(url, body: body, headers: headers);
//       var decodedBody = jsonDecode(res.body);

//       if (res.statusCode == 200) {
//         return {"status": true, "data": decodedBody};
//       } else {
//         return {
//           "status": false,
//           "code": decodedBody["code"],
//           "message": decodedBody["message"]
//         };
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("EXCEPTION ON USER AUTHENTICATION: $e");
//       }
//       return {
//         "status": false,
//         "code": "exception",
//         "message":
//             "Unable to authenticate investor. Please check your internet connection and try again."
//       };
//     }
//   }

//   logOUT(context) async {
//     await SessionPref.logOUT().then((val) => {
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => const LandingPage()),
//               (route) => false)
//         });
//   }

//   getUserProfile(token) async {
//     if (kDebugMode) {
//       print("\n=== Getting User Profile ===");
//     }

//     try {
//       var url = Uri.https(brokerageGate, API().userProfile);
//       // Use CustomHttpClient.get without passing headers - it will handle auth automatically
//       var res = await CustomHttpClient.get(url);
//       var decodeBody = jsonDecode(res.body);

//       if (kDebugMode) {
//         print("Profile Response: ${res.body}");
//       }

//       if (res.statusCode == 200) {
//         if (decodeBody != null && decodeBody["status"] != null) {
//           await SessionPref.setUserProfile(
//               id: decodeBody["id"],
//               status: decodeBody["status"],
//               onboardStatus: decodeBody["onboard_status"],
//               fname: decodeBody["firstname"] ?? "Investor",
//               mname: decodeBody["middlename"] ?? "Investor",
//               lname: decodeBody["lastname"] ?? "Investor",
//               email: decodeBody["email"],
//               phone: decodeBody["mobile"],
//               wallet: decodeBody["wallet"] ?? "0.0",
//               accounNumber: decodeBody["meta"]["nbc_account"] ??= "..",
//               innova: decodeBody["meta"]["innova_client_identifier"] ??=
//                   "INACTIVE",
//               subscriptions: decodeBody["subscriptions"]);

//           if (kDebugMode) {
//             print("✅ User profile updated successfully");
//           }
//           return "1";
//         }
//       }
//       throw Exception(decodeBody["message"] ?? "Failed to get user profile");
//     } catch (e) {
//       if (kDebugMode) {
//         print("❌ Error getting user profile: $e");
//       }
//       return "0";
//     }
//   }

//   //  ================ Metadata API ========================================
//   getCountries() async {
//     var url = Uri.https(brokerageGate, API().countriesList);
//     var res = await http.get(url);

//     var decodeBody = jsonDecode(res.body);

//     if (res.statusCode == 200) {
//       print(decodeBody);
//     } else {
//       print(decodeBody);
//     }
//   }

// // Metadata

//   // sector
//   Future getSectors(String identifier, container) async {
//     String endpoint = "";
//     identifier == "bank"
//         ? endpoint = API().banks
//         : identifier == "sector"
//             ? endpoint = API().sectors
//             : endpoint;
//     print("ENDPOINT IS: $endpoint");
//     var url = Uri.https(brokerageGate, endpoint);
//     var headers = await CustomHttpClient.getHeaders();
//     headers['Authorization'] = 'Bearer ${SessionPref.getToken()![0]}';
//     var res = await http.get(url, headers: headers);
//     var decodeBody = jsonDecode(res.body);
//     if (res.statusCode == 200) {
//       List<Metadata>? sectors = [];
//       for (var each in decodeBody["data"]) {
//         Metadata sector = Metadata(id: each["id"], name: each["name"]);
//         sectors.add(sector);
//       }

//       // add to providers
//       identifier == "bank"
//           ? container.metadatabank = sectors
//           : identifier == "sector"
//               ? container.metadatasector = sectors
//               : container.metadataincome;

//       return "1";
//     } else {
//       print(decodeBody);
//     }
//   }

//   // source of income ..
//   Future getSourceOfIncome(String data, provider) async {
//     String dataField = "";

//     data == "kin"
//         ? dataField = "kins"
//         : data == "source"
//             ? dataField = "source_of_income"
//             : data == "income_frequency"
//                 ? dataField = "income_frequency"
//                 : dataField;
//     var url = Uri.https(brokerageGate, API().metadata);
//     var headers = await CustomHttpClient.getHeaders();
//     headers['Authorization'] = 'Bearer ${SessionPref.getToken()![0]}';
//     var res = await http.get(url, headers: headers);

//     var decodeBody = jsonDecode(res.body);

//     if (res.statusCode == 200) {
//       List<Metadata> sourceIncome = [];
//       for (var each in decodeBody[dataField]) {
//         Metadata sector = Metadata(id: each, name: each);
//         sourceIncome.add(sector);
//       }
//       data == "source"
//           ? provider.metadataincome = sourceIncome
//           : data == "kin"
//               ? provider.metadatarelation = sourceIncome
//               : data == "income_frequency"
//                   ? provider.metadataincomefreq = sourceIncome
//                   : provider.metadataincome;

//       return "1";
//     } else {
//       print("EROR $decodeBody");
//     }
//   }

//   //  =============== KYC KYC KYC KYC KYC KYC KYC KYC ============================================

//   // In waiter.dart - Improved nidaBioVerification method
//   Future<VerificationResult> nidaBioVerification(nin, fingerCode, fingerImage,
//       UserProvider up, context, bool isFingerScanner) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }

//     var userId = base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));
//     var url = Uri.https(API().brokerLinkMainDoor,
//         isFingerScanner ? API().nidaBio : API().nidaAnswerQuestion);

//     var reqBody = jsonEncode(
//         {"nin": nin, "fingerCode": fingerCode, "fingerImage": fingerImage});

//     var headers = await CustomHttpClient.getHeaders();
//     headers['Authorization'] = 'Bearer ${SessionPref.getToken()![0]}';
//     headers['id'] = userId;

//     try {
//       var res = await http.post(url, body: reqBody, headers: headers).timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw TimeoutException('Request timed out after 60 seconds');
//         },
//       );

//       if (res.statusCode == 500) {
//         // Server error - likely API timeout issue
//         if (kDebugMode) {
//           print('Server error (500): ${res.body}');
//         }
//         return VerificationResult(
//           status: "error",
//           message:
//               "Server is experiencing issues. Please try again in a moment.",
//         );
//       }

//       if (res.statusCode != 200) {
//         return VerificationResult(
//           status: "error",
//           message: "Network error (${res.statusCode}). Please try again.",
//         );
//       }

//       Map<String, dynamic> decodedBody;
//       try {
//         decodedBody = jsonDecode(res.body);
//       } catch (e) {
//         return VerificationResult(
//           status: "error",
//           message: "Invalid response format. Please try again.",
//         );
//       }

//       if (decodedBody["status"] == "00") {
//         NIDA nida = NIDA(
//           birthCountry: decodedBody["birthCountry"] ?? "",
//           birthDistrict: decodedBody["birthDistrict"] ?? "",
//           birthRegion: decodedBody["birthRegion"] ?? "",
//           dob: decodedBody["dateOfBirth"] ?? "",
//           fname: decodedBody["firstName"] ?? "",
//           lname: decodedBody["surName"] ?? "",
//           mname: decodedBody["middleName"] ?? "",
//           nin: decodedBody["nin"] ?? nin,
//           pob:
//               "${decodedBody["birthRegion"] ?? ""}, ${decodedBody["birthDistrict"] ?? ""}",
//           resDistrict: decodedBody["residentDistrict"] ?? "",
//           resRegion: decodedBody["residentRegion"] ?? "",
//           resVillage: decodedBody["residentVillage"] ?? "",
//           resWard: decodedBody["residentWard"] ?? "",
//           sex: decodedBody["sex"] ?? "",
//         );

//         await SessionPref.setNIDA(nida, nin);
//         return VerificationResult(
//           status: "success",
//           message: "Verification successful",
//           data: nida,
//         );
//       }
//       // Handle maximum attempts
//       else if (decodedBody["status"] == "111") {
//         return VerificationResult(
//           status: "repeat",
//           message: "Maximum attempts reached. Please try again later.",
//         );
//       }

//       // Handle security questions
//       else {
//         Nidaqns nidaqns = Nidaqns(
//           swQuestion: decodedBody["sw"] ?? "",
//           questionCode: decodedBody["rqCode"] ?? "",
//           enQuestion: decodedBody["en"] ?? "",
//         );

//         up.nidaqns = nidaqns;
//         return VerificationResult(
//           status: "question",
//           message: "Additional verification required",
//           data: nidaqns,
//         );
//       }
//     } on SocketException {
//       return VerificationResult(
//         status: "error",
//         message: "No internet connection. Please check your network.",
//       );
//     } on TimeoutException catch (e) {
//       if (kDebugMode) {
//         print("Timeout exception: $e");
//       }
//       return VerificationResult(
//         status: "error",
//         message: "Request timed out. The server may be busy. Please try again.",
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print("Exception during NIDA verification: $e");
//       }
//       return VerificationResult(
//         status: "error",
//         message: "An unexpected error occurred. Please try again later.",
//       );
//     }
//   }

//   Future<VerificationResult> nidaGetQuestions({
//     required String nin,
//     required UserProvider up,
//     required BuildContext context,
//   }) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }

//     var userId = base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));
//     var url = Uri.https(API().brokerLinkMainDoor, API().nidaQuestions);

//     var reqBody = jsonEncode(
//         {"nin": nin, "idType": "NIDARQ", "rqCode": null, "qnAnsw": null});

//     var headers = await CustomHttpClient.getHeaders();
//     headers['Authorization'] = 'Bearer ${SessionPref.getToken()![0]}';
//     headers['id'] = userId;

//     try {
//       var res = await http.post(url, body: reqBody, headers: headers).timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw TimeoutException('Request timed out after 60 seconds');
//         },
//       );

//       Map<String, dynamic> decodedBody;
//       try {
//         decodedBody = jsonDecode(res.body);
//       } catch (e) {
//         return VerificationResult(
//           status: "error",
//           message: "Invalid response format. Please try again.",
//         );
//       }

//       if (decodedBody.containsKey("error") &&
//           decodedBody.containsKey("status") &&
//           decodedBody["status"] == 500) {
//         return VerificationResult(
//           status: "error",
//           message: "Server error. Please try again later.",
//         );
//       }

//       if (res.statusCode != 200) {
//         return VerificationResult(
//           status: "error",
//           message: "Network error (${res.statusCode}). Please try again.",
//         );
//       }

//       // Handle successful question fetch
//       if (decodedBody["status"] == "00" ||
//           decodedBody.containsKey("sw") ||
//           decodedBody.containsKey("en")) {
//         if (kDebugMode) {
//           print('\n=== NIDA QUESTIONS RESPONSE DEBUG ===');
//           print('Full response body: ${res.body}');
//           print('Decoded response: $decodedBody');
//           print('SW Question: ${decodedBody["sw"]}');
//           print('EN Question: ${decodedBody["en"]}');
//           print('Question Code (rqCode): ${decodedBody["rqCode"]}');
//           print('Question Code (questionCode): ${decodedBody["questionCode"]}');
//           print('Question Code (qCode): ${decodedBody["qCode"]}');
//           print('Question Code (code): ${decodedBody["code"]}');
//           print('All keys in response: ${decodedBody.keys.toList()}');
//           print('=== END DEBUG ===\n');
//         }

//         // Try different possible field names for question code
//         String? questionCode = decodedBody["rqCode"] ??
//             decodedBody["questionCode"] ??
//             decodedBody["qCode"] ??
//             decodedBody["code"] ??
//             decodedBody["question_code"] ??
//             decodedBody["id"] ??
//             "";

//         Nidaqns nidaqns = Nidaqns(
//           swQuestion: decodedBody["sw"] ?? "",
//           questionCode: questionCode.toString(),
//           enQuestion: decodedBody["en"] ?? "",
//         );

//         up.nidaqns = nidaqns;
//         return VerificationResult(
//           status: "success",
//           message: "Questions fetched successfully",
//           data: nidaqns,
//         );
//       }
//       // Handle no questions available
//       else if (decodedBody["status"] == "01") {
//         return VerificationResult(
//           status: "no_questions",
//           message:
//               "No security questions available. Please use biometric verification.",
//         );
//       }
//       // Handle other status codes
//       else {
//         return VerificationResult(
//           status: "error",
//           message:
//               decodedBody["message"] ?? "Unable to fetch security questions.",
//         );
//       }
//     } on SocketException {
//       return VerificationResult(
//         status: "error",
//         message: "No internet connection. Please check your network.",
//       );
//     } on TimeoutException catch (e) {
//       if (kDebugMode) {
//         print("Timeout exception: $e");
//       }
//       return VerificationResult(
//         status: "error",
//         message: "Request timed out. Please try again.",
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print("Exception during NIDA questions fetch: $e");
//       }
//       return VerificationResult(
//         status: "error",
//         message: "An unexpected error occurred. Please try again later.",
//       );
//     }
//   }

//   Future<void> _updateProfileStatus(String status) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String>? profile = SessionPref.getUserProfile();
//     if (profile != null && profile.length > 6) {
//       profile[6] = status;
//       await prefs.setStringList('user_profile', profile);
//     }
//   }

//   Future<Map<String, dynamic>> submitKYC(
//       {required USERKYC userkyc, required MetadataProvider mp, context}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       var url = Uri.https(brokerageGate, API().kyc);
//       var fileUrl = Uri.https(brokerageGate, API().fileEndpoint);

//       var reqBody = jsonEncode({
//         "mobile": userkyc.investorPhone,
//         "dse_account": userkyc.dseAccount ?? "",
//         "region": userkyc.region,
//         "district": userkyc.district,
//         "ward": userkyc.ward,
//         "place_birth": userkyc.placeOfBirth,
//         "firstname": userkyc.fname,
//         "middlename": userkyc.mname,
//         "lastname": userkyc.lname,
//         "title": userkyc.title,
//         "dob": userkyc.dob,
//         "gender": userkyc.gender,
//         "identity": userkyc.nida,
//         "tin": userkyc.tinNumber,
//         "address": userkyc.address,
//         "nationality": userkyc.nationality,
//         "country": userkyc.country,
//         "bank_account_number": userkyc.banckAcNo ?? "",
//         "bank_account_name": userkyc.bankAcName ?? "",
//         "bank_branch": userkyc.bankBranch ?? "",
//         "bank": userkyc.bank ?? "",
//         "employment_status": userkyc.employmentStatus,
//         "other_business": userkyc.other ?? "NOT PROVIDED",
//         "business_sector": userkyc.businessSector ?? "",
//         "employer_name": userkyc.employerName ?? "",
//         "other_employment": userkyc.other,
//         "current_occupation": userkyc.occupation ?? "",
//         "source_of_income": userkyc.sourceOfIncome,
//         "income_frequency": userkyc.incomeFreq,
//         "k_name": userkyc.nextKinName,
//         "k_mobile": userkyc.nextKinMobile,
//         "k_email": userkyc.kinEmail,
//         "k_relationship": userkyc.kinRelationship,
//         "nbc_otp": mp.copOTP?.name,
//         "copreference": mp.copOTP?.id,
//       });

//       var headers = await CustomHttpClient.getHeaders();
//       var userId = base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));
//       headers['Authorization'] = 'Bearer ${SessionPref.getToken()![0]}';
//       headers['id'] = userId;
//       headers['Content-Type'] = 'application/json';

//       var res = await http.post(url, headers: headers, body: reqBody);
//       var decodedBody = jsonDecode(res.body);

//       if (res.statusCode != 200) {
//         return {
//           'success': false,
//           'code': decodedBody['code'] ?? res.statusCode,
//           'message': decodedBody['message'] ?? 'KYC submission failed',
//           'errors': decodedBody['errors']
//         };
//       }

//       if (decodedBody['code'] != 100) {
//         return {
//           'success': false,
//           'code': decodedBody['code'],
//           'message': decodedBody['message'],
//           'errors': decodedBody['errors']
//         };
//       }

//       // Handle file uploads with better error handling
//       var fileUploadRequest = http.MultipartRequest('POST', fileUrl);

//       if (kDebugMode) {
//         print('Starting file upload process');
//         print('File upload URL: $fileUrl');
//         print('Headers for file upload: ${fileUploadRequest.headers}');
//       }
//       headers.remove('Content-Type'); // Remove Content-Type for multipart
//       fileUploadRequest.headers.addAll(headers);

//       // Validate files before uploading
//       for (var file in [
//         {'name': 'passport_file', 'file': userkyc.passportSizeDoc},
//         // {'name': 'tin_file', 'file': userkyc.tinDoc},
//         {'name': 'signature_file', 'file': userkyc.signatureDoc},
//       ]) {
//         if (file['file'] != null) {
//           final fileToUpload = file['file'] as File;
//           if (!await fileToUpload.exists()) {
//             if (kDebugMode) {
//               print('File does not exist: ${fileToUpload.path}');
//             }
//             continue;
//           }

//           if (kDebugMode) {
//             print('Adding ${file['name']}: ${fileToUpload.path}');
//             print('File size: ${await fileToUpload.length()} bytes');
//           }

//           try {
//             fileUploadRequest.files.add(
//               await http.MultipartFile.fromPath(
//                 file['name'] as String,
//                 fileToUpload.path,
//               ),
//             );
//           } catch (e) {
//             if (kDebugMode) {
//               print('Error adding file ${file['name']}: $e');
//             }
//           }
//         }
//       }

//       if (kDebugMode) {
//         print(
//             'Sending file upload request with ${fileUploadRequest.files.length} files');
//       }

//       Map<String, dynamic> fileResponseBody = {};
//       try {
//         final fileUploadResponse = await fileUploadRequest.send().timeout(
//           const Duration(seconds: 30),
//           onTimeout: () {
//             throw TimeoutException('File upload timed out');
//           },
//         );

//         final fileResponseStr = await fileUploadResponse.stream.bytesToString();
//         fileResponseBody = jsonDecode(fileResponseStr);

//         if (kDebugMode) {
//           print(
//               'File upload response status: ${fileUploadResponse.statusCode}');
//           print('Raw response: $fileResponseStr');
//         }

//         // Check if response is HTML instead of JSON
//         if (fileResponseStr.trim().toLowerCase().startsWith('<html')) {
//           if (kDebugMode) {
//             print('Received HTML response instead of JSON');
//           }
//           return {
//             'success': false,
//             'code': fileUploadResponse.statusCode,
//             'message': 'Invalid server response format',
//             'errors': {
//               'server': [
//                 'Server returned HTML instead of JSON. This might indicate a server error.'
//               ]
//             }
//           };
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           print('Error during file upload: $e');
//         }
//         return {
//           'success': false,
//           'code': 500,
//           'message': 'File upload failed',
//           'errors': {
//             'upload': [e.toString()]
//           }
//         };
//       }

//       await _updateProfileStatus("submitted");

//       return {
//         'success': true,
//         'code': fileResponseBody['code'],
//         'message': 'KYC submitted successfully',
//         'data': decodedBody['data']
//       };
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error during KYC submission: $e');
//       }
//       return {
//         'success': false,
//         'code': 500,
//         'message': 'An error occurred while processing your request',
//         'errors': {
//           'system': [e.toString()]
//         }
//       };
//     }
//   }

// //  Banks
// // Future getBanks()async{
// //   var url = Uri.http(brokerageGate, API().banks);
// //   var res = await http
// // }

// // =========================== METADATA ==================================
//   _getMetadata({required String endpoint, params}) async {
//     var url = Uri.https(brokerageGate, endpoint, params);
//     var headers = await CustomHttpClient.getHeaders();
//     var res = await http.get(url, headers: headers);
//     return res;
//   }

//   getRegionBR({required MetadataProvider mp}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       List<Metadata> meta = [];
//       var url = Uri.https(brokerageGate, API().regionEp);
//       var headers = await CustomHttpClient.getHeaders();
//       var res = await http.get(url, headers: headers);
//       var decoded = jsonDecode(res.body);

//       if (res.statusCode == 200) {
//         print("REGIONS: $decoded");

//         for (var each in decoded) {
//           Metadata metadata =
//               Metadata(id: each["regioncode"], name: each["region"]);
//           meta.add(metadata);
//         }
//         mp.regions = meta;
//         return "success";
//       } else {
//         print("REGIONS PULLER FAIL DUE TO: $decoded");
//         return "fail";
//       }
//     } catch (e) {
//       print("EXCEPTION ON REGIONS OCCUR DUE TO: $e");
//     }
//   }

//   Future getDistrictBR({required String code}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       List<Metadata> meta = [];
//       var res = await _getMetadata(
//           endpoint: API().districtEp, params: {"code": code});
//       var decoded = jsonDecode(res.body);

//       if (res.statusCode == 200) {
//         print("PULL DISTRICT SUCCESSFULLY: $decoded");
//         for (var each in decoded) {
//           Metadata metadata =
//               Metadata(id: each["districtcode"], name: each["district"]);
//           meta.add(metadata);
//         }
//         // mp.districts = meta;
//         return meta;
//       } else {
//         print("FAIL TO PULL DISTRICT: $decoded");
//       }
//     } catch (e) {
//       print("EXCEPTION ON PULLING DISTRICTS DUE TO: $e");
//     }
//   }

//   Future getWardBR({required String code}) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     try {
//       List<Metadata> meta = [];
//       var res =
//           await _getMetadata(endpoint: API().wardEp, params: {"code": code});
//       var decoded = jsonDecode(res.body);

//       if (res.statusCode == 200) {
//         print("PULL WARDS SUCCESSFULLY: $decoded");
//         for (var each in decoded) {
//           Metadata metadata =
//               Metadata(id: each["wardcode"], name: each["ward"]);
//           meta.add(metadata);
//         }
//         return meta;
//       } else {
//         print("FAIL TO PULL WARDS: $decoded");
//       }
//     } catch (e) {
//       print("EXCEPTION ON PULLING WARDS DUE TO: $e");
//     }
//   }

//   Future<List<Metadata>> fetchRegions() async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     var url = Uri.https(brokerageGate, API().regionEp);
//     var headers = await CustomHttpClient.getHeaders();
//     var res = await http.get(url, headers: headers);
//     var decoded = jsonDecode(res.body);

//     if (res.statusCode == 200) {
//       List<Metadata> regions = [];
//       for (var each in decoded) {
//         Metadata region =
//             Metadata(id: each["regioncode"], name: each["region"]);
//         regions.add(region);
//       }
//       return regions;
//     } else {
//       throw Exception("Failed to load regions");
//     }
//   }

//   Future<List<Metadata>> fetchDistricts(String regionCode) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     var url = Uri.https(brokerageGate, API().districtEp, {"code": regionCode});
//     var headers = await CustomHttpClient.getHeaders();
//     var res = await http.get(url, headers: headers);
//     var decoded = jsonDecode(res.body);

//     if (res.statusCode == 200) {
//       List<Metadata> districts = [];
//       for (var each in decoded) {
//         Metadata district =
//             Metadata(id: each["districtcode"], name: each["district"]);
//         districts.add(district);
//       }
//       return districts;
//     } else {
//       throw Exception("Failed to load districts");
//     }
//   }

//   Future<List<Metadata>> fetchWards(String districtCode) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }
//     var url = Uri.https(brokerageGate, API().wardEp, {"code": districtCode});
//     var headers = await CustomHttpClient.getHeaders();
//     var res = await http.get(url, headers: headers);
//     var decoded = jsonDecode(res.body);

//     if (res.statusCode == 200) {
//       List<Metadata> wards = [];
//       for (var each in decoded) {
//         Metadata ward = Metadata(id: each["wardcode"], name: each["ward"]);
//         wards.add(ward);
//       }
//       return wards;
//     } else {
//       throw Exception("Failed to load wards");
//     }
//   }

//   final _url = Uri.parse(
//       "https://drive.google.com/file/d/1gJFrWi_EMVKCLkIxm3Gikj_X7jpMeOKZ/view?usp=sharing");

//   final _itrGPT = Uri.parse("https://chatgpt.com/g/g-BpdhkA1hL-itrust-gpt");
//   Future<void> launchInBrowser() async {
//     if (!await launchUrl(
//       _url,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw Exception('Could not launch $_url');
//     }
//   }

//   Future<void> launchITRGPT() async {
//     if (!await launchUrl(
//       _itrGPT,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw Exception('Could not launch $_itrGPT');
//     }
//   }

//   // Add this method to waiter.dart for answering NIDA questions
//   Future<VerificationResult> nidaAnswerQuestion({
//     required String nin,
//     required String questionCode,
//     required String answer,
//     required UserProvider up,
//     required BuildContext context,
//   }) async {
//     if (!await CustomHttpClient.checkInternetConnection()) {
//       throw Exception('No internet connection');
//     }

//     if (kDebugMode) {
//       print('Answering NIDA question');
//       print('NIN: $nin');
//       print('Question Code: $questionCode');
//       print('Answer: $answer');
//     }

//     var userId = base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));
//     var url = Uri.https(API().brokerLinkMainDoor, API().nidaAnswerQuestion);

//     var reqBody = jsonEncode({
//       "nin": nin,
//       "idType": "NIDARQ",
//       "rqCode": questionCode,
//       "qnAnsw": answer,
//     });

//     var headers = await CustomHttpClient.getHeaders();
//     headers['Authorization'] = 'Bearer ${SessionPref.getToken()![0]}';
//     headers['id'] = userId;

//     if (kDebugMode) {
//       print('Request URL: $url');
//       print('Request body: $reqBody');
//     }

//     try {
//       var res = await http.post(url, body: reqBody, headers: headers).timeout(
//         const Duration(seconds: 60),
//         onTimeout: () {
//           throw TimeoutException('Request timed out after 60 seconds');
//         },
//       );

//       if (kDebugMode) {
//         print('Response status: ${res.statusCode}');
//         print('Response body: ${res.body}');
//       }

//       // Safely decode JSON response
//       Map<String, dynamic> decodedBody;
//       try {
//         decodedBody = jsonDecode(res.body);
//       } catch (e) {
//         if (kDebugMode) {
//           print('JSON decode error: $e');
//         }
//         return VerificationResult(
//           status: "error",
//           message: "Invalid response format. Please try again.",
//         );
//       }

//       // Check for server errors (even with status 200)
//       if (decodedBody.containsKey("error") &&
//           decodedBody.containsKey("status") &&
//           decodedBody["status"] == 500) {
//         return VerificationResult(
//           status: "error",
//           message: "Server error. Please try again later.",
//         );
//       }

//       if (res.statusCode != 200) {
//         return VerificationResult(
//           status: "error",
//           message: "Network error (${res.statusCode}). Please try again.",
//         );
//       }

//       // Handle successful verification after answering question
//       if (decodedBody["status"] == "00") {
//         NIDA nida = NIDA(
//           birthCountry: decodedBody["birthCountry"] ?? "",
//           birthDistrict: decodedBody["birthDistrict"] ?? "",
//           birthRegion: decodedBody["birthRegion"] ?? "",
//           dob: decodedBody["dateOfBirth"] ?? "",
//           fname: decodedBody["firstName"] ?? "",
//           lname: decodedBody["surName"] ?? "",
//           mname: decodedBody["middleName"] ?? "",
//           nin: decodedBody["nin"] ?? nin,
//           pob:
//               "${decodedBody["birthRegion"] ?? ""}, ${decodedBody["birthDistrict"] ?? ""}",
//           resDistrict: decodedBody["residentDistrict"] ?? "",
//           resRegion: decodedBody["residentRegion"] ?? "",
//           resVillage: decodedBody["residentVillage"] ?? "",
//           resWard: decodedBody["residentWard"] ?? "",
//           sex: decodedBody["sex"] ?? "",
//         );

//         await SessionPref.setNIDA(nida, nin);
//         return VerificationResult(
//           status: "success",
//           message: "Verification successful",
//           data: nida,
//         );
//       }
//       // Handle another question (multiple questions scenario)
//       else if (decodedBody.containsKey("sw") || decodedBody.containsKey("en")) {
//         Nidaqns nidaqns = Nidaqns(
//           swQuestion: decodedBody["sw"] ?? "",
//           questionCode: decodedBody["rqCode"] ?? "",
//           enQuestion: decodedBody["en"] ?? "",
//         );

//         up.nidaqns = nidaqns;
//         return VerificationResult(
//           status: "question",
//           message: "Additional verification required",
//           data: nidaqns,
//         );
//       }
//       // Handle wrong answer
//       else if (decodedBody["status"] == "01" || decodedBody["status"] == "10") {
//         return VerificationResult(
//           status: "wrong_answer",
//           message: "Incorrect answer. Please try again.",
//         );
//       }
//       // Handle maximum attempts exceeded
//       else if (decodedBody["status"] == "111") {
//         return VerificationResult(
//           status: "repeat",
//           message: "Maximum attempts reached. Please try again later.",
//         );
//       }
//       // Handle verification failed
//       else {
//         return VerificationResult(
//           status: "failed",
//           message: decodedBody["message"] ??
//               "Verification failed. Please try biometric verification instead.",
//         );
//       }
//     } on SocketException {
//       return VerificationResult(
//         status: "error",
//         message: "No internet connection. Please check your network.",
//       );
//     } on TimeoutException catch (e) {
//       if (kDebugMode) {
//         print("Timeout exception: $e");
//       }
//       return VerificationResult(
//         status: "error",
//         message: "Request timed out. Please try again.",
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print("Exception during NIDA question answer: $e");
//       }
//       return VerificationResult(
//         status: "error",
//         message: "An unexpected error occurred. Please try again later.",
//       );
//     }
//   }
// }
