import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iwealth/services/auth/token_service.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/utility/device_info_helper.dart';
import 'config.dart';
import 'error_handler.dart';
import 'package:iwealth/main.dart';

class HttpClientService {
  static final AppConfig _config = AppConfig();

  // Rate limiting storage (don't delete this)
  static final Map<String, List<DateTime>> _rateLimitTracker = {};
  static const int _maxCallsPerMinute = 3;

  // Cache storage (handles all endpoints generally)
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _defaultCacheExpiry = Duration(minutes: 5);

  // Token refresh handling
  static bool _isRefreshing = false;
  static final List<Completer<Map<String, String>>> _refreshQueue = [];

  // Excluded endpoints from rate limiting
  static final Set<String> _excludedEndpoints = {
    'nida/inquiry-bio',
    'nida/bio/verify',
    'nida/inquiry',
    'v2/innova/purchases',
    'innova/investor-buy-order',
    'innova/investor-sell-orders',
  };

  /// Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Connectivity check error: $e');
      }
      return false;
    }
  }

  /// Get standard headers for requests
  static Future<Map<String, String>> getBaseHeaders() async {
    try {
      String deviceId = await DeviceInfoHelper.getDeviceId();
      String deviceName = await DeviceInfoHelper.getDeviceName();
      return {
        'Content-Type': 'application/json',
        'Device-Id': deviceId,
        'Device-Name': deviceName,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device info: $e');
      }
      return {
        'Content-Type': 'application/json',
        'Device-Id': 'unknown',
        'Device-Name': 'unknown',
      };
    }
  }

  /// Get headers with authentication token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final headers = await getBaseHeaders();

    // Check if token needs refresh
    if (TokenService.isTokenExpired()) {
      if (kDebugMode) {
        print('Token needs refresh, attempting refresh...');
      }

      final refreshed = await _refreshTokenSafely();
      if (!refreshed) {
        if (kDebugMode) {
          print('Token refresh failed');
        }
        throw Exception('Authentication failed. Please login again.');
      }

      if (kDebugMode) {
        print('Token refreshed successfully');
      }
    }

    final token = SessionPref.getToken()?[0];
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Safely refresh token with queue to prevent multiple simultaneous refreshes
  static Future<bool> _refreshTokenSafely() async {
    if (_isRefreshing) {
      final completer = Completer<Map<String, String>>();
      _refreshQueue.add(completer);

      try {
        await completer.future;
        return true;
      } catch (e) {
        return false;
      }
    }

    _isRefreshing = true;

    try {
      final refreshed = await TokenService.refreshToken();

      if (refreshed) {
        final newHeaders = await getBaseHeaders();
        final token = SessionPref.getToken()?[0];
        if (token != null) {
          newHeaders['Authorization'] = 'Bearer $token';
        }

        for (final completer in _refreshQueue) {
          completer.complete(newHeaders);
        }
      } else {
        for (final completer in _refreshQueue) {
          completer.completeError('Token refresh failed');
        }
      }

      _refreshQueue.clear();
      return refreshed;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Handle authentication failure by redirecting to login
  static void _handleAuthFailure() {
    final context = globalNavigatorKey?.currentContext;
    if (context != null && context.mounted) {
      // Clear session data
      SessionPref.clearSession();

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );

      // Show error message
      ErrorHandler.showError(context, 'Session expired. Please login again.');
    }
  }

  /// Build URI for API calls
  static Uri buildUri(String endpoint, {Map<String, String>? queryParams}) {
    return Uri.https(_config.brokerMainDoor, endpoint, queryParams);
  }

  /// Check if endpoint is excluded from rate limiting
  static bool _isExcludedFromRateLimit(String endpoint) {
    return _excludedEndpoints.any((excluded) => endpoint.contains(excluded));
  }

  /// Check if endpoint should have caching disabled for fresh data
  static bool _shouldDisableCaching(String endpoint) {
    final noCacheEndpoints = [
      'v2/innova/purchases', // Fund purchases
      'innova/investor-unit-trust-holding', // Fund portfolio/holdings
      'innova/investor-buy-order', // Fund buy orders
      'innova/investor-sell-orders', // Fund sell orders
      'trading/equities/orders', // Stock orders
      'trading/equities/buy', // Stock buy orders
      'trading/equities/sell', // Stock sell orders
      'holdings/portfolio-stock', // Stock portfolio summary
      'holdings/equities', // Individual stock holdings
      'trading/bonds/orders', // Bond orders
      'trading/bonds/buy', // Bond buy orders
      'trading/bonds/sell', // Bond sell orders
      'trading/bonds/calculate-buy', // Bond fee calculation
      'holdings/bonds', // Individual bond holdings
      'holdings/portfolio-bond', // Bond portfolio summary
      'customers/onboard/account/request-otp'
    ];

    return noCacheEndpoints.any((noCache) => endpoint.contains(noCache));
  }

  /// Check rate limit for endpoint
  static bool _checkRateLimit(String endpoint) {
    if (_isExcludedFromRateLimit(endpoint)) {
      return true; // Skip rate limiting for excluded endpoints
    }

    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // Clean up old entries
    _rateLimitTracker[endpoint]
        ?.removeWhere((time) => time.isBefore(oneMinuteAgo));

    // Check if we've exceeded the limit
    final calls = _rateLimitTracker[endpoint] ?? [];
    if (calls.length >= _maxCallsPerMinute) {
      return false;
    }

    // Add current call
    _rateLimitTracker[endpoint] = [...calls, now];
    return true;
  }

  /// Generate cache key
  static String _generateCacheKey(
      String endpoint, dynamic body, Map<String, String>? queryParams) {
    final bodyString = body != null ? jsonEncode(body) : '';
    final queryString =
        queryParams?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return '$endpoint|$bodyString|$queryString';
  }

  /// Get cached response
  static Map<String, dynamic>? _getCachedResponse(String cacheKey) {
    final entry = _cache[cacheKey];
    if (entry != null && entry.isValid) {
      if (kDebugMode) {
        print('Cache hit for: $cacheKey');
      }
      return entry.data;
    }

    // Remove expired entry
    if (entry != null && !entry.isValid) {
      _cache.remove(cacheKey);
    }

    return null;
  }

  /// Cache response
  static void _cacheResponse(String cacheKey, Map<String, dynamic> response,
      {Duration? expiry}) {
    Duration cacheExpiry = expiry ?? _defaultCacheExpiry;

    _cache[cacheKey] = _CacheEntry(
      data: response,
      expiry: DateTime.now().add(cacheExpiry),
    );

    if (kDebugMode) {
      print('Cached response for: $cacheKey');
    }
  }

  /// Create rate limit error response
  static Map<String, dynamic> _createRateLimitError(String endpoint) {
    const String maxCallsPerMinute = '3';
    const userMessage =
        'Please wait a moment before trying again. Our system is processing your previous requests.';
    final devMessage =
        'Rate limit exceeded for endpoint: $endpoint. Maximum $maxCallsPerMinute calls per minute allowed.';

    final context = globalNavigatorKey?.currentContext;
    if (context != null && context.mounted) {
      ErrorHandler.showError(context, userMessage,
          error: kDebugMode ? devMessage : null);
    }

    return ErrorHandler.createResponse(
      success: false,
      message: userMessage,
      code: 429,
      errors: kDebugMode ? {'developer_message': devMessage} : null,
    );
  }

  /// Generic POST request with error handling, rate limiting, and caching
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required dynamic body,
    bool requiresAuth = true,
    Map<String, String>? additionalHeaders,
    Duration timeout = const Duration(seconds: 30),
    bool enableCaching = true,
    Duration? cacheExpiry,
    bool isRetry = false,
  }) async {
    if (!_checkRateLimit(endpoint)) {
      return _createRateLimitError(endpoint);
    }

    // Check cache for POST requests if enabled (disable caching for purchases and orders)
    if (enableCaching && !isRetry && !_shouldDisableCaching(endpoint)) {
      final cacheKey = _generateCacheKey(endpoint, body, null);
      final cachedResponse = _getCachedResponse(cacheKey);
      if (cachedResponse != null) {
        return cachedResponse;
      }
    }

    if (!await hasInternetConnection()) {
      return ErrorHandler.createResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        code: 0,
      );
    }

    try {
      final uri = buildUri(endpoint);
      final headers =
          requiresAuth ? await _getAuthHeaders() : await getBaseHeaders();

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final jsonBody = jsonEncode(body);

      ErrorHandler.logApiCall(
        method: 'POST',
        endpoint: endpoint,
        headers: headers,
        body: jsonBody,
      );

      final response = await http
          .post(uri, headers: headers, body: jsonBody)
          .timeout(timeout);

      ErrorHandler.logApiCall(
        method: 'POST',
        endpoint: endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      // Handle 401 response with token refresh and retry
      if (response.statusCode == 401 && requiresAuth && !isRetry) {
        if (kDebugMode) {
          print('Received 401, attempting token refresh and retry...');
        }

        final refreshed = await _refreshTokenSafely();
        if (refreshed) {
          // Retry the request with fresh token
          return await post(
            endpoint: endpoint,
            body: body,
            requiresAuth: requiresAuth,
            additionalHeaders: additionalHeaders,
            timeout: timeout,
            enableCaching: enableCaching,
            cacheExpiry: cacheExpiry,
            isRetry: true, // Mark as retry to prevent infinite loops
          );
        } else {
          // Token refresh failed, redirect to login
          _handleAuthFailure();
          return ErrorHandler.createResponse(
            success: false,
            message: 'Session expired. Please login again.',
            code: 401,
          );
        }
      }

      final result = _handleResponse(response, endpoint);

      // Don't cache purchases and orders endpoint responses
      if (enableCaching &&
          result['success'] == true &&
          !isRetry &&
          !_shouldDisableCaching(endpoint)) {
        final cacheKey = _generateCacheKey(endpoint, body, null);
        _cacheResponse(cacheKey, result, expiry: cacheExpiry);
      }

      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('POST request error: $e');
        print('Stack trace: $stackTrace');
      }

      return ErrorHandler.createResponse(
        success: false,
        message: ErrorHandler.getErrorMessage(e),
        code: e is TimeoutException ? 408 : 500,
      );
    }
  }

  /// Generic GET request with error handling, rate limiting, and caching
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    Map<String, String>? additionalHeaders,
    Duration timeout = const Duration(seconds: 30),
    bool enableCaching = true,
    Duration? cacheExpiry,
    bool isRetry = false,
  }) async {
    //TODO: cache has issue need to be fixed
    // Check rate limit
    if (!_checkRateLimit(endpoint)) {
      return _createRateLimitError(endpoint);
    }

    // Check cache (disable caching for purchases and orders)
    if (enableCaching && !isRetry && !_shouldDisableCaching(endpoint)) {
      final cacheKey = _generateCacheKey(endpoint, null, queryParams);
      final cachedResponse = _getCachedResponse(cacheKey);
      if (cachedResponse != null) {
        return cachedResponse;
      }
    }

    // Check internet connection
    if (!await hasInternetConnection()) {
      return ErrorHandler.createResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        code: 0,
      );
    }

    try {
      final uri = buildUri(endpoint, queryParams: queryParams);
      final headers =
          requiresAuth ? await _getAuthHeaders() : await getBaseHeaders();

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      ErrorHandler.logApiCall(
        method: 'GET',
        endpoint: endpoint,
        headers: headers,
      );

      final response = await http.get(uri, headers: headers).timeout(timeout);

      ErrorHandler.logApiCall(
        method: 'GET',
        endpoint: endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      // Handle 401 response with token refresh and retry
      if (response.statusCode == 401 && requiresAuth && !isRetry) {
        if (kDebugMode) {
          print('Received 401, attempting token refresh and retry...');
        }

        final refreshed = await _refreshTokenSafely();
        if (refreshed) {
          return await get(
            endpoint: endpoint,
            queryParams: queryParams,
            requiresAuth: requiresAuth,
            additionalHeaders: additionalHeaders,
            timeout: timeout,
            enableCaching: enableCaching,
            cacheExpiry: cacheExpiry,
            isRetry: true,
          );
        } else {
          _handleAuthFailure();
          return ErrorHandler.createResponse(
            success: false,
            message: 'Session expired. Please login again.',
            code: 401,
          );
        }
      }

      final result = _handleResponse(response, endpoint);

      // Don't cache purchases and orders endpoint responses
      if (enableCaching &&
          result['success'] == true &&
          !isRetry &&
          !_shouldDisableCaching(endpoint)) {
        final cacheKey = _generateCacheKey(endpoint, null, queryParams);
        _cacheResponse(cacheKey, result, expiry: cacheExpiry);
      }

      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('GET request error: $e');
        print('Stack trace: $stackTrace');
      }

      return ErrorHandler.createResponse(
        success: false,
        message: ErrorHandler.getErrorMessage(e),
        code: e is TimeoutException ? 408 : 500,
      );
    }
  }

  /// Multipart POST request for file uploads with rate limiting and 401 handling
  static Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    Map<String, File>? files,
    bool requiresAuth = true,
    Map<String, String>? additionalHeaders,
    Duration timeout = const Duration(seconds: 60),
    bool isRetry = false,
  }) async {
    // Check rate limit
    if (!_checkRateLimit(endpoint)) {
      return _createRateLimitError(endpoint);
    }

    // Check internet connection
    if (!await hasInternetConnection()) {
      return ErrorHandler.createResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        code: 0,
      );
    }

    try {
      final uri = buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers =
          requiresAuth ? await _getAuthHeaders() : await getBaseHeaders();

      // Remove Content-Type for multipart
      headers.remove('Content-Type');

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          if (await entry.value.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }
      }

      ErrorHandler.logApiCall(
        method: 'POST (Multipart)',
        endpoint: endpoint,
        headers: request.headers,
        body: 'Fields: $fields, Files: ${files?.keys.toList()}',
      );

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      ErrorHandler.logApiCall(
        method: 'POST (Multipart)',
        endpoint: endpoint,
        statusCode: response.statusCode,
        response: response.body,
      );

      // Handle 401 response with token refresh and retry
      if (response.statusCode == 401 && requiresAuth && !isRetry) {
        if (kDebugMode) {
          print('Received 401, attempting token refresh and retry...');
        }

        final refreshed = await _refreshTokenSafely();
        if (refreshed) {
          return await postMultipart(
            endpoint: endpoint,
            fields: fields,
            files: files,
            requiresAuth: requiresAuth,
            additionalHeaders: additionalHeaders,
            timeout: timeout,
            isRetry: true,
          );
        } else {
          // Token refresh failed, redirect to login
          _handleAuthFailure();
          return ErrorHandler.createResponse(
            success: false,
            message: 'Oops! You need to log in to do that.',
            code: 401,
          );
        }
      }

      return _handleResponse(response, endpoint);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Multipart request error: $e');
        print('Stack trace: $stackTrace');
      }

      return ErrorHandler.createResponse(
        success: false,
        message: ErrorHandler.getErrorMessage(e),
        code: e is TimeoutException ? 408 : 500,
      );
    }
  }

  /// Clear cache for specific endpoint or all cache
  static void clearCache({String? endpoint}) {
    if (endpoint != null) {
      _cache.removeWhere((key, value) => key.startsWith(endpoint));
      if (kDebugMode) {
        print('Cache cleared for endpoint: $endpoint');
      }
    } else {
      _cache.clear();
      if (kDebugMode) {
        print('🗑️ All cache cleared');
      }
    }
  }

  /// Clear all portfolio-related cache for fresh data
  static void clearAllPortfolioCache() {
    final portfolioEndpoints = [
      'holdings/portfolio-stock',
      'holdings/equities', 
      'holdings/bonds',
      'holdings/portfolio-bond',
      'innova/investor-unit-trust-holding',
      'innova/investor-buy-order',
      'innova/investor-sell-orders',
    ];
    
    for (String endpoint in portfolioEndpoints) {
      _cache.removeWhere((key, value) => key.contains(endpoint));
    }
    
    if (kDebugMode) {
      print('🗑️ All portfolio cache cleared for fresh data');
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final validEntries = _cache.values.where((entry) => entry.isValid).length;
    final expiredEntries = _cache.length - validEntries;

    return {
      'total_entries': _cache.length,
      'valid_entries': validEntries,
      'expired_entries': expiredEntries,
      'cache_keys': _cache.keys.toList(),
    };
  }

  /// Clean expired cache entries
  static void cleanExpiredCache() {
    final before = _cache.length;
    _cache.removeWhere((key, value) => !value.isValid);
    final after = _cache.length;

    if (kDebugMode && before != after) {
      print('🧹 Cleaned ${before - after} expired cache entries');
    }
  }

  /// Handle HTTP response and convert to standardized format
  static Map<String, dynamic> _handleResponse(
      http.Response response, String endpoint) {
    try {
      // Handle non-JSON responses (like HTML error pages)
      if (response.body.trim().toLowerCase().startsWith('<html')) {
        return ErrorHandler.handleHttpError(
          response.statusCode,
          'Server returned HTML instead of JSON',
          endpoint: endpoint,
        );
      }

      Map<String, dynamic> decodedBody = {};

      // Try to decode JSON response
      if (response.body.isNotEmpty) {
        try {
          decodedBody = jsonDecode(response.body);
        } catch (e) {
          return ErrorHandler.createResponse(
            success: false,
            message: 'Invalid response format received from server.',
            code: response.statusCode,
          );
        }
      }

      // Handle successful responses
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ErrorHandler.createResponse(
          success: true,
          message: decodedBody['message'] ?? 'Request completed successfully',
          data: decodedBody,
          code: response.statusCode,
        );
      }

      // Handle error responses
      final errorResult = ErrorHandler.handleHttpError(
        response.statusCode,
        response.body,
        endpoint: endpoint,
      );

      return ErrorHandler.createResponse(
        success: false,
        message: decodedBody['message'] ?? errorResult['userMessage'],
        code: response.statusCode,
        errors: decodedBody['errors'],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Response handling error: $e');
      }

      return ErrorHandler.createResponse(
        success: false,
        message: 'Error processing server response.',
        code: response.statusCode,
      );
    }
  }
}

/// Cache entry class
class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime expiry;

  _CacheEntry({
    required this.data,
    required this.expiry,
  });

  bool get isValid => DateTime.now().isBefore(expiry);
}
