import 'dart:convert';
import 'dart:typed_data';

import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/api/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiClient token refresh', () {
    test('refreshes an expired access token and retries the request', () async {
      final storage = _InMemoryTokenStorage(
        accessToken: 'access-old',
        refreshToken: 'refresh-old',
        userId: 'user-1',
      );
      var profileAttempts = 0;
      var refreshAttempts = 0;

      final adapter = _RecordingAdapter((options) async {
        if (options.path == '/profiles/me') {
          profileAttempts += 1;
          if (profileAttempts == 1) {
            expect(options.headers['Authorization'], 'Bearer access-old');
            return _jsonResponse({'detail': 'expired'}, statusCode: 401);
          }

          expect(options.headers['Authorization'], 'Bearer access-new');
          return _jsonResponse({'id': 'user-1'});
        }

        if (options.path == '/auth/refresh') {
          refreshAttempts += 1;
          expect(options.data, {'refresh_token': 'refresh-old'});
          return _jsonResponse({
            'access_token': 'access-new',
            'refresh_token': 'refresh-new',
            'user_id': 'user-1',
          });
        }

        fail('Unexpected request to ${options.path}');
      });

      final client = ApiClient(
        tokenStorage: storage,
        dio: _dioWith(adapter),
        refreshDio: _dioWith(adapter),
      );

      final response = await client.dio.get<Map<String, dynamic>>('/profiles/me');

      expect(response.statusCode, 200);
      expect(profileAttempts, 2);
      expect(refreshAttempts, 1);
      expect(storage.accessToken, 'access-new');
      expect(storage.refreshToken, 'refresh-new');
      expect(storage.userId, 'user-1');
    });

    test('clears local tokens when the refresh token is rejected', () async {
      final storage = _InMemoryTokenStorage(
        accessToken: 'access-old',
        refreshToken: 'refresh-old',
        userId: 'user-1',
      );

      final adapter = _RecordingAdapter((options) async {
        if (options.path == '/profiles/me') {
          return _jsonResponse({'detail': 'expired'}, statusCode: 401);
        }

        if (options.path == '/auth/refresh') {
          return _jsonResponse({'detail': 'invalid'}, statusCode: 401);
        }

        fail('Unexpected request to ${options.path}');
      });

      final client = ApiClient(
        tokenStorage: storage,
        dio: _dioWith(adapter),
        refreshDio: _dioWith(adapter),
      );

      await expectLater(
        client.dio.get<Map<String, dynamic>>('/profiles/me'),
        throwsA(isA<DioException>()),
      );

      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.userId, isNull);
      expect(storage.clearCount, 1);
    });
  });
}

Dio _dioWith(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.example.test'));
  dio.httpClientAdapter = adapter;
  return dio;
}

ResponseBody _jsonResponse(
  Map<String, dynamic> body, {
  int statusCode = 200,
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.onFetch);

  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

class _InMemoryTokenStorage extends TokenStorage {
  _InMemoryTokenStorage({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  String? accessToken;
  String? refreshToken;
  String? userId;
  int clearCount = 0;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.userId = userId;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<String?> getUserId() async => userId;

  @override
  Future<bool> hasSession() async {
    return accessToken != null && accessToken!.isNotEmpty;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    clearCount += 1;
  }
}
