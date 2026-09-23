import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _determineInitialBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final customUrl = await SecureStorageService.getBaseUrl();
          if (customUrl != null && customUrl.isNotEmpty) {
            options.baseUrl = customUrl;
          }

          final token = await SecureStorageService.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('[API Error] ${e.requestOptions.uri}: ${e.response?.data ?? e.message}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  static String _determineInitialBaseUrl() {
    return ApiEndpoints.defaultBaseUrl;
  }

  Dio get dio => _dio;

  Future<void> updateBaseUrl(String newUrl) async {
    _dio.options.baseUrl = newUrl;
    await SecureStorageService.saveBaseUrl(newUrl);
  }
}
