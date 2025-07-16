import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:iwealth/services/api_endpoints.dart';
import 'package:iwealth/services/http_client.dart';
import 'package:iwealth/services/keys.dart';
import 'package:iwealth/services/session/app_session.dart';

class TokenService {
  static Timer? _refreshTimer;
  static const _refreshBeforeExpirySeconds =
      60; // Refresh 1 minute before expiry

  static void startAutoRefresh() {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    final token = SessionPref.getToken();
    if (token == null || token.length < 3) return;

    try {
      // Get expiry time from stored token
      final expiryTimestamp = int.parse(token[2]);
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      final now = DateTime.now();

      // Calculate when to trigger refresh
      final refreshAt =
          expiry.subtract(const Duration(seconds: _refreshBeforeExpirySeconds));
      final timeUntilRefresh = refreshAt.difference(now);

      if (timeUntilRefresh.isNegative) {
        // Token is already near expiry, refresh immediately
        refreshToken();
      } else {
        // Set timer for next refresh
        _refreshTimer = Timer(timeUntilRefresh, () {
          refreshToken().then((success) {
            if (success) {
              if (kDebugMode) {
                print('Auto refresh successful, scheduling next refresh');
              }
              startAutoRefresh(); // Schedule next refresh
            }
          });
        });

        if (kDebugMode) {
          print(
              'Next token refresh scheduled in ${timeUntilRefresh.inSeconds} seconds');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up auto refresh: $e');
      }
    }
  }

  static void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (kDebugMode) {
      print('⏹Auto refresh stopped');
    }
  }

  static Future<bool> refreshToken() async {
    if (kDebugMode) {
      print('\n=== Starting Token Refresh ===');
    }

    try {
      final currentToken = SessionPref.getToken();

      if (kDebugMode) {
        print('Current token available: ${currentToken != null}');
        print('Token array length: ${currentToken?.length}');
      }

      if (currentToken == null || currentToken.length < 2) {
        if (kDebugMode) {
          print('Invalid token state - cannot refresh');
        }
        return false;
      }

      final refreshToken = currentToken[1];
      final url = Uri.https(API().brokerLinkMainDoor, API().refreshToken);

      final body = jsonEncode({
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': Keys().clientId,
        'client_secret': Keys().clientSecret,
        'scope': '*',
      });

      if (kDebugMode) {
        print('Attempting token refresh');
        print('URL: $url');
        print('Body: $body');
      }

      var headers = await HttpClientService.getBaseHeaders();

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (kDebugMode) {
        print('\nResponse status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('\n✅ Token refresh successful');
          print('New access token length: ${data['access_token']?.length}');
          print('New refresh token length: ${data['refresh_token']?.length}');
          print('Expires in: ${data['expires_in']}');
        }

        await SessionPref.setToken(
          data['access_token'],
          data['refresh_token'],
          data['expires_in'].toString(),
        );
        return true;
      }

      if (kDebugMode) {
        print('❌ Token refresh failed with status: ${response.statusCode}');
      }
      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ Token refresh error:');
        print('Error: $e');
        print('Stack trace:\n$stackTrace');
      }
      return false;
    }
  }

  static bool isTokenExpired() {
    try {
      final token = SessionPref.getToken()![0];
      final tokenData = SessionPref.getToken();
      if (token.isEmpty || token.length < 3) {
        // Consider missing token as expired
        if (kDebugMode) {
          print('No valid token found - considering as expired');
        }
        return true;
      }

      final expiryTimestamp = int.parse(tokenData![2]);
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      final now = DateTime.now();

      final isExpired = now.isAfter(expiry
          .subtract(const Duration(seconds: _refreshBeforeExpirySeconds)));

      if (kDebugMode) {
        print('Token expiry check: ${isExpired ? 'expired' : 'valid'}');
      }

      return isExpired;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking token expiry: $e');
      }
      return true;
    }
  }
}
