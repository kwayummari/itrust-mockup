import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/main.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/widgets/app_snackbar.dart';

/// Centralized error handling for the application
class ErrorHandler {
  /// This will show user-friendly error message via SnackBar
  static void showError(BuildContext context, String userMessage,
      {dynamic error, StackTrace? stackTrace}) {
    // Log detailed error for developers add more if you want
    if (kDebugMode && error != null) {
      print('\nERROR DETAILS:');
      print('User Message: $userMessage');
      print('Technical Error: $error');
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
      print('===================\n');
    }

    // user-friendly message
    if (context.mounted) {
      if (error == "You are not authenticated") {
        SessionPref.clearSession();

        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingPage()),
          (route) => false,
        );
        AppSnackbar(
          isError: true,
          response: 'Oops! You need to log in to do that.',
        ).show(context);
      } else {
        AppSnackbar(
          isError: true,
          response: userMessage,
        ).show(context);
      }
      
    }
  }

  /// Show success message via SnackBar
  static void showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      AppSnackbar(
        isError: false,
        response: message,
      ).show(context);
    }
  }

  /// Show info message via SnackBar
  static void showInfo(BuildContext context, String message) {
    if (context.mounted) {
      AppSnackbar(
        isError: true,
        response: message,
      ).show(context);
    }
  }

  /// Converting technical errors to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return "You're offline. Please check your internet and try again.";
    } else if (error is TimeoutException) {
      return 'That took too long. Please try again in a moment.';
    } else if (error is FormatException) {
      return 'Something went wrong while loading. Please try again.';
    } else if (error.toString().contains('certificate')) {
      return 'Your connection isn’t secure. Please check your internet or try a different network.';
    } else if (error.toString().contains('connection')) {
      return "We couldn’t connect. Please check your internet and try again.";
    } else {
      return 'Oops! Something went wrong. Please try again.';
    }
  }

  /// Handling HTTP response errors
  static Map<String, dynamic> handleHttpError(
      int statusCode, String responseBody,
      {String? endpoint}) {
    String userMessage;
    String technicalMessage = 'HTTP $statusCode - $responseBody';

    if (kDebugMode && endpoint != null) {
      print('HTTP Error on endpoint: $endpoint');
      print('Status Code: $statusCode');
      print('Response: $responseBody');
    }

    switch (statusCode) {
      case 400:
        userMessage = 'Invalid request. Please check your input and try again.';
        break;
      case 401:
        userMessage = 'Session expired. Please login again.';
        break;
      case 403:
        userMessage =
            'Access denied. You don\'t have permission for this action.';
        break;
      case 404:
        userMessage = 'Service not found. Please try again later.';
        break;
      case 408:
        userMessage = 'Request timeout. Please try again.';
        break;
      case 422:
        userMessage = 'Invalid data provided. Please check your input.';
        break;
      case 429:
        userMessage = 'Too many requests. Please wait a moment and try again.';
        break;
      case 500:
        userMessage = 'Server error. Please try again later.';
        break;
      case 502:
      case 503:
      case 504:
        userMessage =
            'Service temporarily unavailable. Please try again later.';
        break;
      default:
        userMessage = 'Network error occurred. Please try again.';
    }

    return {
      'success': false,
      'userMessage': userMessage,
      'technicalMessage': technicalMessage,
      'statusCode': statusCode,
    };
  }

  /// Validate required fields
  static Map<String, dynamic> validateFields(Map<String, dynamic> fields) {
    List<String> missingFields = [];

    fields.forEach((key, value) {
      if (value == null || (value is String && value.trim().isEmpty)) {
        missingFields.add(key);
      }
    });

    if (missingFields.isNotEmpty) {
      return {
        'isValid': false,
        'message':
            'Please fill in all required fields: ${missingFields.join(', ')}',
        'missingFields': missingFields,
      };
    }

    return {
      'isValid': true,
      'message': 'All fields are valid',
    };
  }

  /// Standardized API response format
  static Map<String, dynamic> createResponse({
    required bool success,
    String? message,
    dynamic data,
    int? code,
    Map<String, dynamic>? errors,
  }) {
    return {
      'success': success,
      'message': message,
      'data': data,
      'code': code,
      'errors': errors,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Log API calls for debugging
  static void logApiCall({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    int? statusCode,
    String? response,
  }) {
    if (kDebugMode) {
      print('\nAPI CALL LOG:');
      print('Method: $method');
      print('Endpoint: $endpoint');
      if (headers != null) {
        print('Headers: $headers');
      }
      if (body != null) {
        print('Body: $body');
      }
      if (statusCode != null) {
        print('Status Code: $statusCode');
      }
      if (response != null) {
        print(
            'Response: ${response.length > 500 ? '${response.substring(0, 500)}...' : response}');
      }
      print('==================\n');
    }
  }
}
