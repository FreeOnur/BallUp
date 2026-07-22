import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/api/token_storage.dart';
import 'package:baller_app/repositories/court_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API court image upload uses presign, B2, then image record', () async {
    final apiAdapter = _RecordingAdapter((request) {
      if (request.path == '/uploads/presign') {
        return _jsonResponse({
          'upload_url': 'https://storage.example/upload',
          'storage_path': 'courts/court-1/image.jpg',
          'public_url': 'https://cdn.example/courts/court-1/image.jpg',
        });
      }
      if (request.path == '/courts/court-1/images') {
        return _jsonResponse({
          'id': 'image-1',
          'file_path': 'https://cdn.example/courts/court-1/image.jpg',
        }, statusCode: 201);
      }
      return ResponseBody.fromString('Not found', 404);
    });
    final uploadAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString('', 200),
    );
    final apiClient = ApiClient(tokenStorage: _FakeTokenStorage());
    apiClient.dio.httpClientAdapter = apiAdapter;
    final uploadClient = Dio()..httpClientAdapter = uploadAdapter;
    final repository = CourtRepository(
      apiClient: apiClient,
      uploadClient: uploadClient,
      useLegacySupabase: false,
    );
    final tempDirectory = await Directory.systemTemp.createTemp(
      'court-upload-test',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final image = File('${tempDirectory.path}/court.jpg');
    await image.writeAsBytes([1, 2, 3, 4]);

    await repository.uploadCourtImage(courtId: 'court-1', file: image);

    expect(
      apiAdapter.requests.map((request) => request.path),
      ['/uploads/presign', '/courts/court-1/images'],
    );
    final presignBody = apiAdapter.requests.first.data as Map<String, dynamic>;
    expect(presignBody['court_id'], 'court-1');
    expect(presignBody['kind'], 'court_image');
    expect(presignBody['filename'], endsWith('_court-1.jpg'));
    expect(uploadAdapter.requests.single.uri.host, 'storage.example');
    expect(
      uploadAdapter.requests.single.headers['Authorization'],
      isNull,
      reason: 'The app JWT must not be forwarded to object storage.',
    );
    final imageBody = apiAdapter.requests.last.data as Map<String, dynamic>;
    expect(
      imageBody['file_path'],
      'https://cdn.example/courts/court-1/image.jpg',
    );
  });
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

class _FakeTokenStorage extends TokenStorage {
  @override
  Future<String?> getAccessToken() async => 'app-token';
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._respond);

  final ResponseBody Function(RequestOptions request) _respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      await requestStream.drain<void>();
    }
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}
