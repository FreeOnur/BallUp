import 'dart:io';

import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:dio/dio.dart';
// `Headers` is defined by both dio and postgrest (via supabase_flutter); we
// use dio's, so hide the supabase one.
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;

/// Image uploads.
///
/// API mode: two-step presigned upload to Backblaze B2 (S3-compatible).
///   1. POST /uploads/presign  -> { upload_url, storage_path, public_url }
///   2. PUT the bytes straight to `upload_url` (no auth header, no base URL).
/// The B2 keys never leave the server. The caller persists `public_url`
/// (e.g. as `avatar_url` via ProfileRepository, or a court image).
///
/// Legacy mode: Supabase Storage upload, returning the public URL.
class UploadRepository {
  UploadRepository({ApiClient? apiClient, Dio? rawDio})
      : _apiClient = apiClient ?? ApiClient(),
        // Bare Dio for the presigned PUT: the ApiClient interceptor would
        // otherwise attach a Bearer header and the API base URL.
        _rawDio = rawDio ?? Dio();

  final ApiClient _apiClient;
  final Dio _rawDio;

  Future<String> uploadAvatar(File file) => _upload(file: file, kind: 'avatar');

  Future<String> uploadCourtImage(File file, String courtId) =>
      _upload(file: file, kind: 'court_image', courtId: courtId);

  Future<String> _upload({
    required File file,
    required String kind,
    String? courtId,
  }) async {
    final filename = file.path.split(RegExp(r'[\\/]')).last;

    if (AppConfig.useLegacySupabase) {
      return _legacyUpload(file: file, kind: kind, courtId: courtId);
    }

    final presign = await _apiClient.dio.post(
      '/uploads/presign',
      data: {
        'filename': filename,
        'kind': kind,
        if (courtId != null) 'court_id': courtId,
      },
    );
    final data = presign.data as Map<String, dynamic>;
    final uploadUrl = data['upload_url'] as String;
    final publicUrl = data['public_url'] as String;

    final bytes = await file.readAsBytes();
    await _rawDio.put(
      uploadUrl,
      data: Stream.fromIterable(bytes.map((b) => [b])),
      options: Options(
        headers: {Headers.contentLengthHeader: bytes.length},
        contentType: _contentType(filename),
      ),
    );

    return publicUrl;
  }

  Future<String> _legacyUpload({
    required File file,
    required String kind,
    String? courtId,
  }) async {
    final supabase = Supabase.instance.client;
    final filename = file.path.split(RegExp(r'[\\/]')).last;
    if (kind == 'avatar') {
      final userId = supabase.auth.currentUser!.id;
      final path = '$userId/$filename';
      await supabase.storage.from('images').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
      return supabase.storage.from('images').getPublicUrl(path);
    }
    final path = 'courts/$courtId/$filename';
    await supabase.storage.from('court_images').upload(path, file);
    return supabase.storage.from('court_images').getPublicUrl(path);
  }

  String _contentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
