import 'package:dio/dio.dart';

import 'package:baller_app/core/api/token_storage.dart';
import 'package:baller_app/core/config/app_config.dart';

class ApiClient {
  ApiClient({TokenStorage? tokenStorage, Dio? dio, Dio? refreshDio})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    _dio = dio ?? Dio(_baseOptions());
    _refreshDio = refreshDio ?? Dio(_baseOptions());
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
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

          final requestToken = _requestBearerToken(error.requestOptions);
          final currentToken = await _tokenStorage.getAccessToken();
          if (_hasNewerToken(currentToken, requestToken)) {
            await _retryWithToken(error, handler, currentToken!);
            return;
          }

          final refreshedToken = await _refreshAccessToken();
          if (refreshedToken == null) {
            handler.next(error);
            return;
          }

          await _retryWithToken(error, handler, refreshedToken);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;
  late final Dio _refreshDio;

  Dio get dio => _dio;

  static const _retriedAfterRefreshKey = 'retried_after_refresh';

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    );
  }

  bool _shouldRefresh(DioException error) {
    if (error.response?.statusCode != 401) {
      return false;
    }
    if (error.requestOptions.extra[_retriedAfterRefreshKey] == true) {
      return false;
    }
    if (_isAuthEndpoint(error.requestOptions.path)) {
      return false;
    }
    return _requestBearerToken(error.requestOptions) != null;
  }

  bool _isAuthEndpoint(String path) {
    return path == '/auth/login' ||
        path == '/auth/register' ||
        path == '/auth/refresh';
  }

  String? _requestBearerToken(RequestOptions options) {
    final header = options.headers['Authorization'];
    if (header is! String || !header.startsWith('Bearer ')) {
      return null;
    }
    return header.substring('Bearer '.length);
  }

  bool _hasNewerToken(String? currentToken, String? requestToken) {
    return currentToken != null &&
        currentToken.isNotEmpty &&
        currentToken != requestToken;
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data;
      if (data == null) {
        return null;
      }
      final accessToken = data['access_token'] as String;
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: data['refresh_token'] as String,
        userId: data['user_id'] as String,
      );
      return accessToken;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _tokenStorage.clear();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _retryWithToken(
    DioException error,
    ErrorInterceptorHandler handler,
    String accessToken,
  ) async {
    final requestOptions = error.requestOptions;
    requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    requestOptions.extra[_retriedAfterRefreshKey] = true;

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(error);
    }
  }
}
