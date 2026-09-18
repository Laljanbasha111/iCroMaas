import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  String? _authToken;
  final Map<String, CancelToken> _cancelTokens = {};
  bool _initialized = false;

  // -------------------- Initialization --------------------
  Future<void> initialize({String? baseUrl}) async {
    if (_initialized) return;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'https://api.cropanalyzer.com/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        debugPrint('❌ [ERROR] ${e.message}');
        if (_shouldRetry(e)) {
          final retryResponse = await _retryRequest(e.requestOptions);
          return handler.resolve(retryResponse);
        }
        return handler.next(e);
      },
    ));

    _initialized = true;
  }

  // -------------------- Authentication --------------------
  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // -------------------- GET --------------------
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams, String? requestId}) async {
    final cancelToken = CancelToken();
    if (requestId != null) _cancelTokens[requestId] = cancelToken;
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      if (requestId != null) _cancelTokens.remove(requestId);
    }
  }

  // -------------------- POST --------------------
  Future<Response> post(String endpoint, {Map<String, dynamic>? body, String? requestId}) async {
    final cancelToken = CancelToken();
    if (requestId != null) _cancelTokens[requestId] = cancelToken;
    try {
      final response = await _dio.post(
        endpoint,
        data: jsonEncode(body ?? {}),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      if (requestId != null) _cancelTokens.remove(requestId);
    }
  }

  // -------------------- PUT --------------------
  Future<Response> put(String endpoint, {Map<String, dynamic>? body, String? requestId}) async {
    final cancelToken = CancelToken();
    if (requestId != null) _cancelTokens[requestId] = cancelToken;
    try {
      final response = await _dio.put(
        endpoint,
        data: jsonEncode(body ?? {}),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      if (requestId != null) _cancelTokens.remove(requestId);
    }
  }

  // -------------------- DELETE --------------------
  Future<Response> delete(String endpoint, {String? requestId}) async {
    final cancelToken = CancelToken();
    if (requestId != null) _cancelTokens[requestId] = cancelToken;
    try {
      final response = await _dio.delete(
        endpoint,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      if (requestId != null) _cancelTokens.remove(requestId);
    }
  }

  // -------------------- File Upload --------------------
  Future<Response> uploadFile(String endpoint, File file, {String fieldName = 'file', Map<String, dynamic>? extraData}) async {
    try {
      final fileName = path.basename(file.path);
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType('application', 'octet-stream'),
        ),
        ...?extraData,
      });
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -------------------- File Download --------------------
  Future<void> downloadFile(String endpoint, String savePath, {Function(int, int)? onProgress}) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        onReceiveProgress: onProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -------------------- Request Cancellation --------------------
  void cancelRequest(String requestId) {
    if (_cancelTokens.containsKey(requestId)) {
      _cancelTokens[requestId]?.cancel('Request cancelled');
      _cancelTokens.remove(requestId);
    }
  }

  // -------------------- Retry Logic --------------------
  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions, {int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        await Future.delayed(Duration(milliseconds: 500 * (1 << attempt)));
        final options = Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
        );
        final response = await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: options,
        );
        return response;
      } catch (_) {
        attempt++;
        if (attempt >= retries) rethrow;
      }
    }
    throw Exception('Max retry attempts reached');
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

  // -------------------- Utility --------------------
  Map<String, dynamic> parseResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data;
    } else if (response.data is String) {
      return jsonDecode(response.data);
    } else {
      return {'data': response.data};
    }
  }

  bool isSuccess(Response response) {
    return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
  }

  Future<void> printApiSummary() async {
    debugPrint('API Client Summary:');
    debugPrint('Base URL: ${_dio.options.baseUrl}');
    debugPrint('Auth Token: ${_authToken != null ? 'Set' : 'Not Set'}');
    debugPrint('Active Requests: ${_cancelTokens.length}');
  }
}