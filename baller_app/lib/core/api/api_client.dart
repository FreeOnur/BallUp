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

          final refreshed = await _refreshSession();
          if (!refreshed) {
            await _tokenStorage.clear();
            handler.next(error);
            return;
          }

          final retryRequest = error.requestOptions;
          retryRequest.extra[_retryKey] = true;
          final token = await _tokenStorage.getAccessToken();
          retryRequest.headers['Authorization'] = 'Bearer $token';

          try {
            final response = await _dio.fetch<dynamic>(retryRequest);
            handler.resolve(response);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );
  }

  static const _retryKey = 'auth_retry';
  static Future<bool>? _refreshFuture;

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  Dio get dio => _dio;

  bool _shouldRefresh(DioException error) {
    if (error.response?.statusCode != 401) return false;
    if (error.requestOptions.extra[_retryKey] == true) return false;
    return !error.requestOptions.path.startsWith('/auth/');
  }

  Future<bool> _refreshSession() {
    _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshClient = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final res = await refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = res.data;
      if (data == null) return false;

      await _tokenStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        userId: data['user_id'] as String,
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
