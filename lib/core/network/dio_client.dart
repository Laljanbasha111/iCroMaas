import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// ✅ REMOVED: import 'package:path/path.dart' as path; (unused)

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;
  String _baseUrl = 'https://api.cropanalyzer.com/v1';
  String? _authToken;
  final Map<String, CancelToken> _cancelTokens = {};
  bool _initialized = false;

  // -------------------- Initialization --------------------
  Future<void> initialize({String? baseUrl}) async {
    if (_initialized) return;
    _baseUrl = baseUrl ?? _baseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(this),
      LoggingInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(_dio),
      CacheInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    ]);

    _initialized = true;
  }

  // -------------------- Base URL & Headers --------------------
  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  void setHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  String? get authToken => _authToken;  // ✅ Added getter for auth token

  // -------------------- HTTP Methods --------------------
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -------------------- File Upload --------------------
  Future<Response> uploadFile(
      String path,
      File file, {
        String fieldName = 'file',
        Map<String, dynamic>? additionalData,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      final fileName = file.path.split('/').last;  // ✅ Fixed: use file.path instead of path parameter
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -------------------- Multiple File Upload --------------------
  Future<Response> uploadMultipleFiles(
      String path,
      List<File> files, {
        String fieldName = 'files',
        Map<String, dynamic>? additionalData,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: [
          for (var file in files)
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
        ],
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -------------------- File Download --------------------
  Future<void> downloadFile(
      String url,
      String savePath, {
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -------------------- Interceptor Management --------------------
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  void clearInterceptors() {
    _dio.interceptors.clear();
  }

  // -------------------- Error Handling --------------------
  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return TimeoutException('Request timed out. Please try again.');
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode ?? 0;
      final message = e.response?.data?['message'] ?? 'Server error';
      if (statusCode == 401) {
        return Exception('Unauthorized. Please log in again.');
      } else if (statusCode == 403) {
        return Exception('Access denied.');
      } else if (statusCode == 404) {
        return Exception('Resource not found.');
      } else if (statusCode >= 500) {
        return Exception('Server error. Please try later.');
      } else {
        return Exception('Error: $message');
      }
    } else if (e.type == DioExceptionType.cancel) {
      return Exception('Request cancelled.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection.');
    } else {
      return Exception('Unexpected error: ${e.message}');
    }
  }

  // -------------------- Request Cancellation --------------------
  CancelToken createCancelToken(String requestId) {
    final token = CancelToken();
    _cancelTokens[requestId] = token;
    return token;
  }

  void cancelRequest(String requestId) {
    if (_cancelTokens.containsKey(requestId)) {
      _cancelTokens[requestId]?.cancel('Request cancelled');
      _cancelTokens.remove(requestId);
    }
  }

  void cancelAllRequests() {
    for (final token in _cancelTokens.values) {
      token.cancel('All requests cancelled');
    }
    _cancelTokens.clear();
  }

  // -------------------- Utility --------------------
  bool isSuccess(Response response) {
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }

  Map<String, dynamic> parseResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data;
    } else if (response.data is String) {
      return jsonDecode(response.data);
    } else {
      return {'data': response.data};
    }
  }

  Future<void> printSummary() async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('DioClient Summary');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Base URL: $_baseUrl');
    debugPrint('Auth Token: ${_authToken != null ? 'Set' : 'Not Set'}');
    debugPrint('Active Requests: ${_cancelTokens.length}');
    debugPrint('Interceptors: ${_dio.interceptors.length}');
    debugPrint('═══════════════════════════════════════');
  }

  // -------------------- Cleanup --------------------
  void dispose() {
    cancelAllRequests();
    _dio.close();
    _initialized = false;
  }
}

// -------------------- Logging Interceptor --------------------
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('Response: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ [ERROR] ${err.message}');
    if (err.response != null) {
      debugPrint('Status Code: ${err.response?.statusCode}');
      debugPrint('Response Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

// -------------------- Auth Interceptor --------------------
class AuthInterceptor extends Interceptor {
  final DioClient client;
  AuthInterceptor(this.client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (client._authToken != null) {
      options.headers['Authorization'] = 'Bearer ${client._authToken}';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      debugPrint('🔒 [AUTH] Token expired or invalid');
      // You can trigger token refresh here
    }
    super.onError(err, handler);
  }
}

// -------------------- Error Interceptor --------------------
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('⚠️ [ERROR INTERCEPTOR] ${err.message}');
    if (err.response != null) {
      debugPrint('Response Data: ${err.response?.data}');
      debugPrint('Status Code: ${err.response?.statusCode}');
    }
    super.onError(err, handler);
  }
}

// -------------------- Retry Interceptor --------------------
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor(
      this.dio, {
        this.maxRetries = 3,
        this.retryDelay = const Duration(seconds: 2),
      });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      int retryCount = 0;
      while (retryCount < maxRetries) {
        try {
          debugPrint('🔄 [RETRY] Attempt ${retryCount + 1}/$maxRetries');
          await Future.delayed(retryDelay);
          final response = await _retryRequest(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            debugPrint('❌ [RETRY] Max retries reached');
            return handler.next(err);
          }
        }
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
    );
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

// -------------------- Cache Interceptor --------------------
class CacheInterceptor extends Interceptor {
  final Map<String, CachedResponse> _cache = {};
  final Duration cacheDuration = const Duration(minutes: 10);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      return super.onRequest(options, handler);
    }

    final key = _generateCacheKey(options);
    if (_cache.containsKey(key)) {
      final cachedResponse = _cache[key]!;
      final age = DateTime.now().difference(cachedResponse.timestamp);

      if (age < cacheDuration) {
        debugPrint('📦 [CACHE HIT] ${options.uri}');
        return handler.resolve(cachedResponse.response);
      } else {
        _cache.remove(key);
        debugPrint('🗑️ [CACHE EXPIRED] ${options.uri}');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET requests
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final key = _generateCacheKey(response.requestOptions);
      _cache[key] = CachedResponse(
        response: response,
        timestamp: DateTime.now(),
      );
      debugPrint('💾 [CACHE SAVED] ${response.requestOptions.uri}');
    }
    super.onResponse(response, handler);
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
}

// -------------------- Cached Response Model --------------------
class CachedResponse {
  final Response response;
  final DateTime timestamp;

  CachedResponse({
    required this.response,
    required this.timestamp,
  });
}

