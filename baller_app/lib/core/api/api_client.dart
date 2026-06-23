import 'package:dio/dio.dart';

import 'package:baller_app/core/api/token_storage.dart';
import 'package:baller_app/core/config/app_config.dart';

class ApiClient {
  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (!_shouldRefresh(error)) {
            handler.next(error);
            return;
          }

          try {
            await _refreshAccessToken();
            error.requestOptions.extra[_refreshRetryKey] = true;
            final retryResponse = await _dio.fetch<dynamic>(
              error.requestOptions,
            );
            handler.resolve(retryResponse);
          } catch (_) {
            await _tokenStorage.clear();
            handler.next(error);
          }
        },
      ),
    );
  }

  static const _refreshRetryKey = 'retried_after_refresh';

  final TokenStorage _tokenStorage;
  late final Dio _dio;
  Future<void>? _refreshFuture;

  Dio get dio => _dio;

  bool _shouldRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    final alreadyRetried = error.requestOptions.extra[_refreshRetryKey] == true;
    return statusCode == 401 &&
        !alreadyRetried &&
        !_isAuthEndpoint(error.requestOptions.path);
  }

  bool _isAuthEndpoint(String path) {
    final uri = Uri.tryParse(path);
    final normalizedPath = uri?.path ?? path;
    return normalizedPath.startsWith('/auth/');
  }

  Future<void> _refreshAccessToken() async {
    final inFlight = _refreshFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture = _doRefreshAccessToken();
    _refreshFuture = refreshFuture;
    try {
      await refreshFuture;
    } finally {
      if (identical(_refreshFuture, refreshFuture)) {
        _refreshFuture = null;
      }
    }
  }

  Future<void> _doRefreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('Missing refresh token');
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    final response = await refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty refresh response');
    }
    await _tokenStorage.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      userId: data['user_id'] as String,
    );
  }
}
