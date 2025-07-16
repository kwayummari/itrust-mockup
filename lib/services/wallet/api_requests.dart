import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iwealth/models/wallet/payment_request.dart';
import 'package:iwealth/services/api_endpoints.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/utility/device_info_helper.dart';
import 'package:iwealth/widgets/app_snackbar.dart';

class WalletWaiter {
  var userId = base64.encode(utf8.encode(SessionPref.getUserProfile()![5]));

  Future<Map<String, String>> _getHeaders() async {
    String deviceId = await DeviceInfoHelper.getDeviceId();
    String deviceName = await DeviceInfoHelper.getDeviceName();
    return {
      'Authorization': 'Bearer ${SessionPref.getToken()![0]}',
      'Content-Type': 'application/json',
      'id': userId,
      'device_id': deviceId,
      'device_name': deviceName,
    };
  }

  Future<void> processPayment({
    required double amount,
    required String phoneNumber,
    required BuildContext context,
  }) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get headers and extract device_id
      var headers = await _getHeaders();

      // Clean phone number (remove '+')
      String cleanedPhoneNumber = phoneNumber.replaceAll('+', '');

      final paymentRequest = PaymentRequest(
        amount: amount,
        mobile: cleanedPhoneNumber,
      );

      // Convert to JSON
      var requestData = paymentRequest.toJson();
      print('PAYMENT REQUEST: ${jsonEncode(requestData)}');

      var url = Uri.https(API().brokerLinkMainDoor, API().fundWallet);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );

      var decoded = jsonDecode(response.body);

      Navigator.pop(context);

      if (decoded["code"] == 100) {
        AppSnackbar(
          isError: true,
          response: "Payment Pop-up will appear on your screen",
        ).show(context);

        // Wait a bit for the user to see the message, then go back
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // Go back to the previous screen
        });
      } else {
        AppSnackbar(
          isError: true,
          response: "Something Went Wrong, please try again",
        ).show(context);
      }
    } catch (e) {
      // Close loading indicator
      Navigator.pop(context);

      AppSnackbar(
        isError: true,
        response: "Something went wrong while processing mobile payment. Please try again later.",
      ).show(context);
    }
  }
}
