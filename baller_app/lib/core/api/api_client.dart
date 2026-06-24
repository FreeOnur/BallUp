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
          final response = error.response;
          final request = error.requestOptions;
          final alreadyRetried = request.extra['retried'] == true;
          if (response?.statusCode != 401 ||
              alreadyRetried ||
              request.path.startsWith('/auth/')) {
            handler.next(error);
            return;
          }

          final refreshed = await _refreshSession();
          if (!refreshed) {
            handler.next(error);
            return;
          }

          try {
            final retryResponse = await _dio.request<dynamic>(
              request.path,
              data: request.data,
              queryParameters: request.queryParameters,
              options: Options(
                method: request.method,
                headers: request.headers,
                responseType: request.responseType,
                contentType: request.contentType,
                extra: {...request.extra, 'retried': true},
                followRedirects: request.followRedirects,
                receiveDataWhenStatusError: request.receiveDataWhenStatusError,
                validateStatus: request.validateStatus,
              ),
              cancelToken: request.cancelToken,
              onReceiveProgress: request.onReceiveProgress,
              onSendProgress: request.onSendProgress,
            );
            handler.resolve(retryResponse);
          } on DioException catch (retryError) {
            handler.next(retryError);
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;
  static Future<bool>? _refreshFuture;

  Dio get dio => _dio;

  Future<bool> _refreshSession() async {
    final pendingRefresh = _refreshFuture;
    if (pendingRefresh != null) {
      return pendingRefresh;
    }

    _refreshFuture = _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      return false;
    }

    final refreshClient = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      final response = await refreshClient.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        userId: data['user_id'] as String,
      );
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }
}
