import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/User/model/user_kyc.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/models/nidaQns.dart';
import 'package:iwealth/models/nidamodel.dart';
import 'package:iwealth/models/sector.dart';
import 'package:iwealth/models/user.dart';
import 'package:iwealth/providers/user_provider.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import 'config.dart';
import 'error_handler.dart';
import 'http_client.dart';

class APIService {
  static final AppConfig _config = AppConfig();

  // ============================================
  // Authentication & User Management
  // ============================================

  /// Request OTP for phone number verification
  static Future<Map<String, dynamic>> requestOTP({
    required String phone,
    String? appSignature,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.requestOTP,
        requiresAuth: false,
        body: {
          'mobile': phone,
          'appSignature': appSignature,
        },
      );

      if (response['success']) {
        final data = response['data'];
        if (data['code'] == 100) {
          String? testOtp;
          if (data.containsKey('data') && data['data']['otp'] != null) {
            testOtp = data['data']['otp'].toString();
          }

          ErrorHandler.showSuccess(context, 'OTP sent successfully');
          return {
            'success': true,
            'otp': testOtp,
            'message': 'OTP sent successfully'
          };
        }
      }

      ErrorHandler.showError(
          context, response['message'] ?? 'Failed to send OTP');
      return response;
    } catch (e) {
      ErrorHandler.showError(context, 'Failed to send OTP', error: e);
      return ErrorHandler.createResponse(
        success: false,
        message: 'Failed to send OTP',
      );
    }
  }

  /// Resend OTP
  static Future<Map<String, dynamic>> resendOTP({
    required String phone,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.resendOTP,
        requiresAuth: false,
        body: {'mobile': phone},
      );

      if (response['success']) {
        ErrorHandler.showSuccess(context, 'OTP resent successfully');
        return response;
      }

      ErrorHandler.showError(context, 'Failed to resend OTP');
      return response;
    } catch (e) {
      ErrorHandler.showError(context, 'Failed to resend OTP', error: e);
      return ErrorHandler.createResponse(
        success: false,
        message: 'Failed to resend OTP',
      );
    }
  }

  /// Validate OTP
  static Future<Map<String, dynamic>> validateOTP({
    required String phone,
    required String otp,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.verifyOTP,
        requiresAuth: false,
        body: {
          'mobile': phone,
          'user_otp': otp,
        },
      );

      if (response['success']) {
        final data = response['data'];
        if (data['code'] == 100) {
          SessionPref.saveOnboardData(email: "", phone: phone);
          SessionPref.setChallenge(data: data['data']['challenge']);
          ErrorHandler.showSuccess(context, 'OTP verified successfully');
          return ErrorHandler.createResponse(success: true, message: 'success');
        }
      }

      ErrorHandler.showError(context, 'Invalid OTP. Please try again.');
      return ErrorHandler.createResponse(success: false, message: 'fail');
    } catch (e) {
      ErrorHandler.showError(context, 'Failed to validate OTP', error: e);
      return ErrorHandler.createResponse(success: false, message: 'fail');
    }
  }

  /// Reset PIN
  static Future<Map<String, dynamic>> resetPIN({
    required String pin,
    required String confirmPIN,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.resetPIN,
        requiresAuth: false,
        body: {
          'challenge': SessionPref.getChallenge(),
          'mobile': SessionPref.getOnboardData()![0],
          'user_pin': pin,
          'user_pin_confirmation': confirmPIN,
        },
      );

      if (response['success']) {
        final data = response['data'];
        if (data['code'] == 100) {
          ErrorHandler.showSuccess(context, 'PIN reset successfully');
          return ErrorHandler.createResponse(success: true, message: 'success');
        }
      }

      ErrorHandler.showError(context, 'Failed to reset PIN. Please try again.');
      return ErrorHandler.createResponse(success: false, message: 'fail');
    } catch (e) {
      ErrorHandler.showError(context, 'Failed to reset PIN', error: e);
      return ErrorHandler.createResponse(success: false, message: 'fail');
    }
  }

  /// Register new investor
  static Future<Map<String, dynamic>> registerInvestor({
    required User user,
    required String pin,
    required String confirmPIN,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.createInvestor,
        requiresAuth: false,
        body: {
          'type': 'individual',
          'firstname': user.fname,
          'middlename': user.mname,
          'lastname': user.lname,
          'email': user.email,
          'country_code': user.country,
          'mobile': user.phone.toString(),
          'user_pin': pin,
          'user_pin_confirmation': confirmPIN,
          'terms_of_service': true,
          'required_email_verification': true,
        },
      );

      if (response['success']) {
        final data = response['data'];
        if (data['code'] == 100) {
          ErrorHandler.showSuccess(context, 'Registration successful');
        }
        return {
          'code': data['code'],
          'message': data['message'],
          'data': data,
        };
      } else {
        ErrorHandler.showError(
            context, response['message'] ?? 'Registration failed');
      }

      return response;
    } catch (e) {
      ErrorHandler.showError(context, 'Registration failed', error: e);
      return ErrorHandler.createResponse(
        success: false,
        code: 500,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  /// Authenticate investor
  static Future<Map<String, dynamic>> authenticateInvestor({
    required String pin,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.authenticate,
        requiresAuth: false,
        body: {
          'password': pin,
          'username': SessionPref.getOnboardData()![0],
          'challenge': SessionPref.getChallenge(),
          'grant_type': 'password',
          'client_id': _config.clientCredentials['clientId'],
          'client_secret': _config.clientCredentials['clientSecret'],
          'scope': '*',
        },
      );

      if (response['success']) {
        return {'status': true, 'data': response['data']};
      }

      final data = response['data'];
      ErrorHandler.showError(
          context, data?['message'] ?? 'Authentication failed');
      return {
        'status': false,
        'code': data?['code'],
        'message': data?['message'],
      };
    } catch (e) {
      ErrorHandler.showError(context, 'Authentication failed', error: e);
      return {
        'status': false,
        'code': 'exception',
        'message':
            'Unable to authenticate investor. Please check your internet connection and try again.',
      };
    }
  }

  /// Get user profile
  static Future<String> getUserProfile() async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.userProfile,
        requiresAuth: true,
      );

      if (response['success']) {
        final data = response['data'];
        if (data != null && data['status'] != null) {
          await SessionPref.setUserProfile(
            id: data['id'],
            status: data['status'],
            onboardStatus: data['onboard_status'],
            fname: data['firstname'] ?? 'Investor',
            mname: data['middlename'] ?? 'Investor',
            lname: data['lastname'] ?? 'Investor',
            email: data['email'],
            phone: data['mobile'],
            wallet: data['wallet'] ?? '0.0',
            accounNumber: data['meta']['nbc_account'] ?? '..',
            innova: data['meta']['innova_client_identifier'] ?? 'INACTIVE',
            subscriptions: data['subscriptions'],
          );

          if (kDebugMode) {
            print('✅ User profile updated successfully');
          }
          return '1';
        }
      }

      throw Exception(response['message'] ?? 'Failed to get user profile');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user profile: $e');
      }
      return '0';
    }
  }

  // ============================================
  // NIDA Verification
  // ============================================

  /// NIDA biometric verification
  static Future<VerificationResult> nidaBioVerification({
    required String nin,
    required String fingerCode,
    required String fingerImage,
    required UserProvider up,
    required BuildContext context,
    required bool isFingerScanner,
  }) async {
    try {
      final userId =
          base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));
      final endpoint = isFingerScanner
          ? APIEndpoints.nidaBio
          : APIEndpoints.nidaAnswerQuestion;

      final response = await HttpClientService.post(
        endpoint: endpoint,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
        body: {
          'nin': nin,
          'fingerCode': fingerCode,
          'fingerImage': fingerImage,
        },
        timeout: const Duration(seconds: 60),
      );

      if (response['success']) {
        final data = response['data'];

        if (data['status'] == '00') {
          NIDA nida = NIDA(
              birthCountry: data['birthCountry'] ?? '',
              birthDistrict: data['birthDistrict'] ?? '',
              birthRegion: data['birthRegion'] ?? '',
              dob: data['dateOfBirth'] ?? '',
              fname: data['firstName'] ?? '',
              lname: data['surName'] ?? '',
              mname: data['middleName'] ?? '',
              nin: data['nin'] ?? nin,
              pob:
                  '${data['birthRegion'] ?? ''}, ${data['birthDistrict'] ?? ''}',
              resDistrict: data['residentDistrict'] ?? '',
              resRegion: data['residentRegion'] ?? '',
              resVillage: data['residentVillage'] ?? '',
              resWard: data['residentWard'] ?? '',
              sex: data['sex'] ?? '',
              photo: data['photo'] ?? '');

          await SessionPref.setNIDA(nida, nin);
          return VerificationResult(
            status: 'success',
            message: 'Verification successful',
            data: nida,
          );
        } else if (data['status'] == '111') {
          return VerificationResult(
            status: 'repeat',
            message: 'Maximum attempts reached. Please try again later.',
          );
        } else {
          Nidaqns nidaqns = Nidaqns(
            swQuestion: data['sw'] ?? '',
            questionCode: data['rqCode'] ?? '',
            enQuestion: data['en'] ?? '',
          );

          up.nidaqns = nidaqns;
          return VerificationResult(
            status: 'question',
            message: 'Additional verification required',
            data: nidaqns,
          );
        }
      }

      return VerificationResult(
        status: 'error',
        message: response['message'] ?? 'Verification failed',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Exception during NIDA verification: $e');
      }
      return VerificationResult(
        status: 'error',
        message: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  /// Get NIDA security questions
  static Future<VerificationResult> nidaGetQuestions({
    required String nin,
    required UserProvider up,
    required BuildContext context,
  }) async {
    try {
      final userId =
          base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));

      final response = await HttpClientService.post(
        endpoint: APIEndpoints.nidaQuestions,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
        body: {
          'nin': nin,
          'idType': 'NIDARQ',
          'rqCode': null,
          'qnAnsw': null,
        },
        timeout: const Duration(seconds: 60),
      );

      if (response['success']) {
        final data = response['data'];

        // Handle successful question fetch
        if (data['status'] == '00' ||
            data.containsKey('sw') ||
            data.containsKey('en')) {
          String? questionCode = data['rqCode'] ??
              data['questionCode'] ??
              data['qCode'] ??
              data['code'] ??
              data['question_code'] ??
              data['id'] ??
              '';

          Nidaqns nidaqns = Nidaqns(
            swQuestion: data['sw'] ?? '',
            questionCode: questionCode.toString(),
            enQuestion: data['en'] ?? '',
          );

          up.nidaqns = nidaqns;
          return VerificationResult(
            status: 'success',
            message: 'Questions fetched successfully',
            data: nidaqns,
          );
        } else if (data['status'] == '01') {
          return VerificationResult(
            status: 'no_questions',
            message:
                'No security questions available. Please use biometric verification.',
          );
        }
      }

      return VerificationResult(
        status: 'error',
        message: response['message'] ?? 'Unable to fetch security questions.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Exception during NIDA questions fetch: $e');
      }
      return VerificationResult(
        status: 'error',
        message: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  /// Answer NIDA security question
  static Future<VerificationResult> nidaAnswerQuestion({
    required String nin,
    required String questionCode,
    required String answer,
    required UserProvider up,
    required BuildContext context,
  }) async {
    try {
      final userId =
          base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));

      final response = await HttpClientService.post(
        endpoint: APIEndpoints.nidaAnswerQuestion,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
        body: {
          'nin': nin,
          'idType': 'NIDARQ',
          'rqCode': questionCode,
          'qnAnsw': answer,
        },
        timeout: const Duration(seconds: 60),
      );

      if (response['success']) {
        final data = response['data'];

        if (data['status'] == '00') {
          NIDA nida = NIDA(
              birthCountry: data['birthCountry'] ?? '',
              birthDistrict: data['birthDistrict'] ?? '',
              birthRegion: data['birthRegion'] ?? '',
              dob: data['dateOfBirth'] ?? '',
              fname: data['firstName'] ?? '',
              lname: data['surName'] ?? '',
              mname: data['middleName'] ?? '',
              nin: data['nin'] ?? nin,
              pob:
                  '${data['birthRegion'] ?? ''}, ${data['birthDistrict'] ?? ''}',
              resDistrict: data['residentDistrict'] ?? '',
              resRegion: data['residentRegion'] ?? '',
              resVillage: data['residentVillage'] ?? '',
              resWard: data['residentWard'] ?? '',
              sex: data['sex'] ?? '',
              photo: data['photo'] ?? '');

          await SessionPref.setNIDA(nida, nin);
          return VerificationResult(
            status: 'success',
            message: 'Verification successful',
            data: nida,
          );
        } else if (data.containsKey('sw') || data.containsKey('en')) {
          Nidaqns nidaqns = Nidaqns(
            swQuestion: data['sw'] ?? '',
            questionCode: data['rqCode'] ?? '',
            enQuestion: data['en'] ?? '',
          );

          up.nidaqns = nidaqns;
          return VerificationResult(
            status: 'question',
            message: 'Additional verification required',
            data: nidaqns,
          );
        } else if (data['status'] == '01' || data['status'] == '10') {
          return VerificationResult(
            status: 'wrong_answer',
            message: 'Incorrect answer. Please try again.',
          );
        } else if (data['status'] == '111') {
          return VerificationResult(
            status: 'repeat',
            message: 'Maximum attempts reached. Please try again later.',
          );
        }
      }

      return VerificationResult(
        status: 'failed',
        message: response['message'] ??
            'Verification failed. Please try biometric verification instead.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Exception during NIDA question answer: $e');
      }
      return VerificationResult(
        status: 'error',
        message: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  // ============================================
  // KYC Submission
  // ============================================

  /// Submit KYC information
  static Future<Map<String, dynamic>> submitKYC({
    required USERKYC userkyc,
    required MetadataProvider mp,
    required BuildContext context,
  }) async {
    try {
      // First submit KYC data
      final userId =
          base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));

      final kycResponse = await HttpClientService.post(
        endpoint: APIEndpoints.kyc,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
        body: {
          'mobile': userkyc.investorPhone,
          'dse_account': userkyc.dseAccount ?? '',
          'region': userkyc.region,
          'district': userkyc.district,
          'ward': userkyc.ward,
          'place_birth': userkyc.placeOfBirth,
          'firstname': userkyc.fname,
          'middlename': userkyc.mname,
          'lastname': userkyc.lname,
          'title': userkyc.title,
          'dob': userkyc.dob,
          'gender': userkyc.gender,
          'identity': userkyc.nida,
          'tin': userkyc.tinNumber,
          'address': userkyc.address,
          'nationality': userkyc.nationality,
          'country': userkyc.country,
          'bank_account_number': userkyc.banckAcNo ?? '',
          'bank_account_name': userkyc.bankAcName ?? '',
          'bank_branch': userkyc.bankBranch ?? '',
          'bank': userkyc.bank ?? '',
          'employment_status': userkyc.employmentStatus,
          'other_business': userkyc.other ?? 'NOT PROVIDED',
          'business_sector': userkyc.businessSector ?? '',
          'employer_name': userkyc.employerName ?? '',
          'other_employment': userkyc.other,
          'current_occupation': userkyc.occupation ?? '',
          'source_of_income': userkyc.sourceOfIncome,
          'income_frequency': userkyc.incomeFreq,
          'k_name': userkyc.nextKinName,
          'k_mobile': userkyc.nextKinMobile,
          'k_email': userkyc.kinEmail,
          'k_relationship': userkyc.kinRelationship,
          'nbc_otp': mp.copOTP?.name,
          'copreference': mp.copOTP?.id,
        },
      );

      if (!kycResponse['success']) {
        ErrorHandler.showError(
            context, kycResponse['message'] ?? 'KYC submission failed');
        return kycResponse;
      }

      final kycData = kycResponse['data'];
      if (kycData['code'] != 100) {
        ErrorHandler.showError(
            context, kycData['message'] ?? 'KYC submission failed');
        return {
          'success': false,
          'code': kycData['code'],
          'message': kycData['message'],
          'errors': kycData['errors'],
        };
      }

      // Upload files
      Map<String, File> files = {};
      if (userkyc.passportSizeDoc != null &&
          await userkyc.passportSizeDoc!.exists()) {
        files['passport_file'] = userkyc.passportSizeDoc!;
      }
      if (userkyc.signatureDoc != null &&
          await userkyc.signatureDoc!.exists()) {
        files['signature_file'] = userkyc.signatureDoc!;
      }

      if (files.isNotEmpty) {
        final fileResponse = await HttpClientService.postMultipart(
          endpoint: APIEndpoints.kycFileUpload,
          fields: {},
          files: files,
          requiresAuth: true,
          additionalHeaders: {'id': userId},
        );

        if (!fileResponse['success']) {
          ErrorHandler.showError(context, 'File upload failed');
          return fileResponse;
        }
      }

      await _updateProfileStatus('submitted');
      ErrorHandler.showSuccess(context, 'KYC submitted successfully');

      return {
        'success': true,
        'code': kycData['code'],
        'message': 'KYC submitted successfully',
        'data': kycData['data'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error during KYC submission: $e');
      }
      ErrorHandler.showError(context, 'KYC submission failed', error: e);
      return {
        'success': false,
        'code': 500,
        'message': 'An error occurred while processing your request',
        'errors': {
          'system': [e.toString()]
        },
      };
    }
  }

  // ============================================
  // Metadata Management
  // ============================================

  /// Get sectors or banks metadata
  static Future<String> getSectors(String identifier, dynamic container) async {
    try {
      String endpoint;
      if (identifier == 'bank') {
        endpoint = APIEndpoints.banks;
      } else if (identifier == 'relationships') {
        endpoint = APIEndpoints.relations;
      } else {
        endpoint = APIEndpoints.sectors;
      }

      final response = await HttpClientService.get(
        endpoint: endpoint,
        requiresAuth: true,
      );

      if (response['success']) {
        final data = response['data'];
        List<Metadata> sectors = [];

        for (var each in data['data']) {
          Metadata sector = Metadata(id: each['id'], name: each['name']);
          sectors.add(sector);
        }

        // Add to providers
        if (identifier == 'bank') {
          container.metadatabank = sectors;
        } else if (identifier == 'sector') {
          container.metadatasector = sectors;
        }

        return '1';
      }

      return '0';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sectors: $e');
      }
      return '0';
    }
  }

  /// Get source of income metadata
  static Future<String> getSourceOfIncome(String data, dynamic provider) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.metadata,
        requiresAuth: true,
      );

      if (response['success']) {
        final responseData = response['data'];
        String dataField = '';
        switch (data) {
          case 'kin':
            dataField = 'kins';
            break;
          case 'titles':
            dataField = 'titles';
            break;
          case 'source':
            dataField = 'source_of_income';
            break;
          case 'income_frequency':
            dataField = 'income_frequency';
            break;
        }

        print(
            "===============responsedata $data=========== ${responseData[dataField]}");

        List<Metadata> sourceIncome = [];
        for (var each in responseData[dataField]) {
          Metadata sector =
              Metadata(id: each.toString(), name: each.toString());
          sourceIncome.add(sector);
        }

        switch (data) {
          case 'source':
            provider.metadataincome = sourceIncome;
            break;
          case 'kin':
            provider.metadatarelation = sourceIncome;
            // ADD THIS: Also save titles when loading kin data
            if (responseData['titles'] != null) {
              List<Metadata> titlesList = [];
              for (var each in responseData['titles']) {
                Metadata title =
                    Metadata(id: each.toString(), name: each.toString());
                titlesList.add(title);
              }
              provider.titles = titlesList;
              print(
                  "===============TITLES SAVED TO PROVIDER=========== ${titlesList.length}");
            }
            break;
          case 'titles':
            provider.titles = sourceIncome;
            break;
          case 'income_frequency':
            provider.metadataincomefreq = sourceIncome;
            break;
        }

        return '1';
      }

      return '0';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting source of income: $e');
      }
      return '0';
    }
  }

  static Future<String> getTitles(dynamic provider) async {
    try {
      if (kDebugMode) {
        print("getTitles: Starting API call...");
      }

      final response = await HttpClientService.get(
        endpoint: APIEndpoints.metadata,
        requiresAuth: true,
      );

      if (kDebugMode) {
        print("getTitles: Response received");
        print("getTitles: response['success'] = ${response['success']}");
        print("getTitles: Full response = $response");
      }

      if (response['success']) {
        final responseData = response['data'];

        if (kDebugMode) {
          print("getTitles: responseData = $responseData");
          print(
              "getTitles: responseData['titles'] = ${responseData['titles']}");
          print(
              "getTitles: responseData['titles'] type = ${responseData['titles'].runtimeType}");
        }

        List<Metadata> titlesList = [];

        // Add null check
        if (responseData['titles'] != null) {
          for (var each in responseData['titles']) {
            if (kDebugMode) {
              print("getTitles: Processing title: $each (${each.runtimeType})");
            }
            Metadata title =
                Metadata(id: each.toString(), name: each.toString());
            titlesList.add(title);
          }
        } else {
          if (kDebugMode) {
            print("getTitles: responseData['titles'] is null!");
          }
        }

        if (kDebugMode) {
          print("getTitles: Created ${titlesList.length} titles");
          if (titlesList.isNotEmpty) {
            print("getTitles: First title: ${titlesList.first.name}");
          }
        }

        provider.titles = titlesList;

        if (kDebugMode) {
          print("getTitles: Set titles in provider");
          print(
              "getTitles: Provider titles count after setting: ${provider.titles.length}");
        }

        return '1';
      } else {
        if (kDebugMode) {
          print("getTitles: API response success = false");
          print("getTitles: Response: $response");
        }
      }

      return '0';
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('getTitles: Error getting titles: $e');
        print('getTitles: Stack trace: $stackTrace');
      }
      return '0';
    }
  }

  /// Get regions
  static Future<String> getRegions(MetadataProvider mp) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.regions,
        requiresAuth: false,
      );

      if (response['success']) {
        final data = response['data'];
        List<Metadata> meta = [];

        for (var each in data) {
          Metadata metadata =
              Metadata(id: each['regioncode'], name: each['region']);
          meta.add(metadata);
        }

        mp.regions = meta;
        return 'success';
      }

      return 'fail';
    } catch (e) {
      if (kDebugMode) {
        print('Exception on regions: $e');
      }
      return 'fail';
    }
  }

  /// Get districts by region code
  static Future<List<Metadata>?> getDistricts(String regionCode) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.districts,
        queryParams: {'code': regionCode},
        requiresAuth: false,
      );

      if (response['success']) {
        final data = response['data'];
        List<Metadata> meta = [];

        for (var each in data) {
          Metadata metadata =
              Metadata(id: each['districtcode'], name: each['district']);
          meta.add(metadata);
        }

        return meta;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Exception on districts: $e');
      }
      return null;
    }
  }

  /// Get wards by district code
  static Future<List<Metadata>?> getWards(String districtCode) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.wards,
        queryParams: {'code': districtCode},
        requiresAuth: false,
      );

      if (response['success']) {
        final data = response['data'];
        List<Metadata> meta = [];

        for (var each in data) {
          Metadata metadata =
              Metadata(id: each['wardcode'], name: each['ward']);
          meta.add(metadata);
        }

        return meta;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Exception on wards: $e');
      }
      return null;
    }
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// Update user profile status
  static Future<void> _updateProfileStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? profile = SessionPref.getUserProfile();
      if (profile != null && profile.length > 6) {
        profile[6] = status;
        await prefs.setStringList('user_profile', profile);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile status: $e');
      }
    }
  }
}

/// Verification result class for NIDA operations
class VerificationResult {
  final String status;
  final dynamic success;
  final String message;
  final dynamic data;

  VerificationResult({
    required this.status,
    this.success,
    required this.message,
    this.data,
  });
}
