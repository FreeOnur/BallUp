import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  String? _usernameFromProfile(Map<String, dynamic> profile) {
    final username = profile['username'];
    if (username is! String) return null;
    final normalized = username.trim();
    return normalized.isEmpty ? null : normalized;
  }

  bool _isCompleteProfile(Map<String, dynamic> profile) {
    return _usernameFromProfile(profile) != null;
  }

  Future<bool> hasProfile({String? userId}) async {
    if (AppConfig.useLegacySupabase) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return response != null && _isCompleteProfile(response);
    }

    if (userId == null) return false;
    try {
      final response = await _apiClient.dio.get('/profiles/me');
      final profile = response.data as Map<String, dynamic>;
      return _isCompleteProfile(profile);
    } catch (_) {
      return false;
    }
  }

  Future<String> getUserName() async {
    if (AppConfig.useLegacySupabase) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();
      final username = _usernameFromProfile(response);
      if (username == null) {
        throw Exception('Profile username is missing');
      }
      return username;
    }

    final response = await _apiClient.dio.get('/profiles/me');
    final profile = response.data as Map<String, dynamic>;
    final username = _usernameFromProfile(profile);
    if (username == null) {
      throw Exception('Profile username is missing');
    }
    return username;
  }

  Future<void> upsertProfile({
    required String userId,
    required String username,
    int? age,
    int? location,
    int? gender,
    int? skillLevel,
    String? avatarUrl,
  }) async {
    if (AppConfig.useLegacySupabase) {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'username': username,
        'age': age,
        'location': location,
        'gender': gender,
        'skill_level': skillLevel,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });
      return;
    }

    await _apiClient.dio.put(
      '/profiles/me',
      data: {
        'username': username,
        'age': age,
        'location': location,
        'gender': gender,
        'skill_level': skillLevel,
        'avatar_url': avatarUrl,
      },
    );
  }
}
