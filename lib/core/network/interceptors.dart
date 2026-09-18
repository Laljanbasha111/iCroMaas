import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:collection';  // ✅ ADDED: Import Queue from dart:collection
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// -------------------- Request Interceptor --------------------
class RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'Accept': 'application/json',
      'X-App-Name': 'Crop Analyzer',
      'X-Request-Timestamp': DateTime.now().toIso8601String(),
    });
    options.queryParameters['ts'] = DateTime.now().millisecondsSinceEpoch;
    if (options.data is Map<String, dynamic>) {
      (options.data as Map<String, dynamic>)['client'] = 'CropAnalyzerApp';
    }
    debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
    handler.next(options);
  }
}

// -------------------- Response Interceptor --------------------
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final metadata = {
      'timestamp': DateTime.now().toIso8601String(),
      'status_code': response.statusCode,
      'url': response.requestOptions.uri.toString(),
    };
    if (response.data is Map<String, dynamic>) {
      response.data['metadata'] = metadata;
    }
    debugPrint('✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }
}

// -------------------- Error Interceptor --------------------
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = parseErrorMessage(err);
    debugPrint('❌ [ERROR] ${err.requestOptions.uri} → $message');
    handler.next(err);
  }

  String parseErrorMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond.';
    } else if (error.type == DioExceptionType.sendTimeout) {
      return 'Request timed out.';
    } else if (error.type == DioExceptionType.badResponse) {
      final status = error.response?.statusCode ?? 0;
      final msg = error.response?.data?['message'] ?? 'Server error';
      return 'HTTP $status: $msg';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    } else if (error.type == DioExceptionType.cancel) {
      return 'Request cancelled.';
    } else {
      return 'Unexpected error: ${error.message}';
    }
  }
}

// -------------------- Auth Interceptor --------------------
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final Future<String?> Function()? refreshToken;

  AuthInterceptor({required this.getToken, this.refreshToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && refreshToken != null) {
      try {
        final newToken = await refreshToken!();
        if (newToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final dio = Dio();
          final retryResponse = await dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        debugPrint('Token refresh failed: $e');
      }
    }
    handler.next(err);
  }
}

// -------------------- Logging Interceptor --------------------
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('📤 [REQUEST] ${options.method} ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('Body: ${_prettyJson(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('Data: ${_prettyJson(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('⚠️ [ERROR] ${err.message}');
    if (err.response != null) {
      debugPrint('Response: ${_prettyJson(err.response?.data)}');
    }
    handler.next(err);
  }

  String _prettyJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

// -------------------- Connectivity Interceptor --------------------
class ConnectivityInterceptor extends Interceptor {
  final Connectivity _connectivity = Connectivity();
  final List<QueuedRequest> _queuedRequests = [];
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityInterceptor() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _isOnline = !results.contains(ConnectivityResult.none);
      debugPrint('📶 [CONNECTIVITY] Online: $_isOnline');
      if (_isOnline) _processQueue();
    });
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final isOffline = connectivityResults.contains(ConnectivityResult.none);

    if (isOffline) {
      debugPrint('📴 [OFFLINE] Queuing request: ${options.uri}');
      _queuedRequests.add(QueuedRequest(options, handler));
    } else {
      handler.next(options);
    }
  }

  void _processQueue() {
    if (_queuedRequests.isEmpty) return;

    debugPrint('🔁 [PROCESSING QUEUE] ${_queuedRequests.length} requests');
    for (final queued in _queuedRequests) {
      debugPrint('🔁 [RETRY] ${queued.options.uri}');
      queued.handler.next(queued.options);
    }
    _queuedRequests.clear();
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class QueuedRequest {
  final RequestOptions options;
  final RequestInterceptorHandler handler;
  QueuedRequest(this.options, this.handler);
}

// -------------------- Rate Limit Interceptor --------------------
class RateLimitInterceptor extends Interceptor {
  final int maxRequestsPerSecond;
  final Queue<DateTime> _requestTimestamps = Queue<DateTime>();  // ✅ Now Queue is available

  RateLimitInterceptor({this.maxRequestsPerSecond = 5});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final now = DateTime.now();
    _requestTimestamps.addLast(now);

    // Remove timestamps older than 1 second
    _requestTimestamps.removeWhere((t) => now.difference(t).inSeconds >= 1);

    if (_requestTimestamps.length > maxRequestsPerSecond) {
      final delay = 1000 ~/ maxRequestsPerSecond;
      debugPrint('⏳ [RATE LIMIT] Delaying request by ${delay}ms');
      await Future.delayed(Duration(milliseconds: delay));
    }

    handler.next(options);
  }

  void clearTimestamps() {
    _requestTimestamps.clear();
  }
}

// -------------------- Retry Interceptor --------------------
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final int baseDelayMs;

  RetryInterceptor({this.maxRetries = 3, this.baseDelayMs = 500});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (shouldRetry(err)) {
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        final delay = getRetryDelay(attempt);
        debugPrint('🔁 [RETRY] Attempt $attempt/$maxRetries after ${delay}ms');
        await Future.delayed(Duration(milliseconds: delay));

        try {
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          debugPrint('✅ [RETRY SUCCESS] Attempt $attempt');
          return handler.resolve(response);
        } catch (e) {
          if (attempt == maxRetries) {
            debugPrint('❌ [RETRY FAILED] Max attempts reached');
            rethrow;
          }
        }
      }
    }
    handler.next(err);
  }

  bool shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  int getRetryDelay(int attempt) => baseDelayMs * (1 << (attempt - 1));
}

// -------------------- Cache Interceptor --------------------
class CacheInterceptor extends Interceptor {
  final Map<String, CachedResponse> _cache = {};
  final Duration cacheDuration;

  CacheInterceptor({this.cacheDuration = const Duration(minutes: 10)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'GET') {
      final key = _generateCacheKey(options);
      final cached = _cache[key];

      if (cached != null && DateTime.now().isBefore(cached.expiry)) {
        debugPrint('📦 [CACHE HIT] ${options.uri}');
        return handler.resolve(cached.response);
      } else if (cached != null) {
        _cache.remove(key);
        debugPrint('🗑️ [CACHE EXPIRED] ${options.uri}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final key = _generateCacheKey(response.requestOptions);
      _cache[key] = CachedResponse(
        response,
        DateTime.now().add(cacheDuration),
      );
      debugPrint('💾 [CACHE STORE] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  String _generateCacheKey(RequestOptions options) {
    final queryString = options.queryParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '${options.method}_${options.path}${queryString.isNotEmpty ? '?$queryString' : ''}';
  }

  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ [CACHE CLEARED]');
  }

  int getCacheSize() => _cache.length;
}

class CachedResponse {
  final Response response;
  final DateTime expiry;
  CachedResponse(this.response, this.expiry);
}

// -------------------- Analytics Interceptor --------------------
class AnalyticsInterceptor extends Interceptor {
  final Map<String, int> _apiCallCount = {};
  final Map<String, int> _errorCount = {};
  final Map<String, List<int>> _responseTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _apiCallCount.update(options.path, (v) => v + 1, ifAbsent: () => 1);
    options.extra['start_time'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['start_time'] as DateTime?;
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      final path = response.requestOptions.path;

      _responseTimes.putIfAbsent(path, () => []).add(duration);
      debugPrint('📊 [ANALYTICS] $path → ${duration}ms');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _errorCount.update(err.requestOptions.path, (v) => v + 1, ifAbsent: () => 1);
    debugPrint('📉 [ANALYTICS ERROR] ${err.requestOptions.path}');
    handler.next(err);
  }

  void printAnalyticsSummary() {
    debugPrint('═══════════════════════════════════════');
    debugPrint('📈 API Analytics Summary');
    debugPrint('═══════════════════════════════════════');

    for (final entry in _apiCallCount.entries) {
      final errors = _errorCount[entry.key] ?? 0;
      final times = _responseTimes[entry.key] ?? [];
      final avgTime = times.isEmpty ? 0 : times.reduce((a, b) => a + b) ~/ times.length;

      debugPrint('Endpoint: ${entry.key}');
      debugPrint('  Calls: ${entry.value} | Errors: $errors | Avg Time: ${avgTime}ms');
    }
    debugPrint('═══════════════════════════════════════');
  }

  Map<String, dynamic> getAnalytics() {
    return {
      'total_calls': _apiCallCount.values.fold(0, (a, b) => a + b),
      'total_errors': _errorCount.values.fold(0, (a, b) => a + b),
      'endpoints': _apiCallCount.keys.toList(),
      'call_count': _apiCallCount,
      'error_count': _errorCount,
    };
  }

  void reset() {
    _apiCallCount.clear();
    _errorCount.clear();
    _responseTimes.clear();
    debugPrint('🔄 [ANALYTICS RESET]');
  }
}

