import 'dart:io';

import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourtRepository {
  CourtRepository({
    ApiClient? apiClient,
    Dio? uploadClient,
    bool? useLegacySupabase,
  }) : _apiClient = apiClient ?? ApiClient(),
       _uploadClient = uploadClient ?? Dio(),
       _useLegacySupabase =
           useLegacySupabase ?? AppConfig.useLegacySupabase;

  final ApiClient _apiClient;
  final Dio _uploadClient;
  final bool _useLegacySupabase;

  Future<List<Map<String, dynamic>>> fetchApprovedCourts() async {
    if (_useLegacySupabase) {
      final res = await Supabase.instance.client
          .from('courts')
          .select()
          .eq('status', 'approved');
      return List<Map<String, dynamic>>.from(res as List);
    }

    final res = await _apiClient.dio.get('/courts');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  Future<String> createCourt({
    required String name,
    required double latitude,
    required double longitude,
    required bool indoor,
    required bool hasLights,
    required bool hasCourtMarkings,
    required String groundType,
    required int hoops,
    required String address,
  }) async {
    if (_useLegacySupabase) {
      final res = await Supabase.instance.client
          .from('courts')
          .insert({
            'source': 'community',
            'name': name,
            'lat': latitude,
            'lng': longitude,
            'indoor': indoor,
            'lights': hasLights,
            'has_markings': hasCourtMarkings,
            'surface': groundType,
            'hoops': hoops,
            'address': address,
          })
          .select('id')
          .single();
      return res['id'] as String;
    }

    final res = await _apiClient.dio.post(
      '/courts',
      data: {
        'name': name,
        'lat': latitude,
        'lng': longitude,
        'indoor': indoor,
        'lights': hasLights,
        'has_markings': hasCourtMarkings,
        'surface': groundType,
        'hoops': hoops,
        'address': address,
      },
    );
    final data = res.data as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<void> uploadCourtImage({
    required String courtId,
    required File file,
  }) async {
    final filename = _storageFilename(courtId: courtId, file: file);
    if (_useLegacySupabase) {
      await _uploadLegacyCourtImage(
        courtId: courtId,
        filename: filename,
        file: file,
      );
      return;
    }

    final presignResponse = await _apiClient.dio.post(
      '/uploads/presign',
      data: {
        'filename': filename,
        'court_id': courtId,
        'kind': 'court_image',
      },
    );
    final presign = presignResponse.data as Map<String, dynamic>;
    final uploadUrl = presign['upload_url'] as String;
    final publicUrl = presign['public_url'] as String;

    await _uploadClient.put(
      uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: await file.length(),
          Headers.contentTypeHeader: 'application/octet-stream',
        },
      ),
    );
    await _apiClient.dio.post(
      '/courts/$courtId/images',
      data: {'file_path': publicUrl},
    );
  }

  Future<void> _uploadLegacyCourtImage({
    required String courtId,
    required String filename,
    required File file,
  }) async {
    final supabase = Supabase.instance.client;
    final storagePath = 'courts/$courtId/$filename';
    await supabase.storage.from('court_images').upload(storagePath, file);
    final publicUrl = supabase.storage
        .from('court_images')
        .getPublicUrl(storagePath);
    await supabase.from('court_images').insert({
      'court_id': courtId,
      'file_path': publicUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String _storageFilename({required String courtId, required File file}) {
    final pathSegments = file.path.replaceAll(r'\', '/').split('/');
    final originalName = pathSegments.last;
    final extensionIndex = originalName.lastIndexOf('.');
    final extension = extensionIndex == -1
        ? ''
        : originalName.substring(extensionIndex).toLowerCase();
    return '${DateTime.now().microsecondsSinceEpoch}_$courtId$extension';
  }
}
