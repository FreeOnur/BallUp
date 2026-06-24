import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static bool isCompleteProfile(Map<String, dynamic>? profile) {
    final username = profile?['username'];
    return username is String && username.trim().isNotEmpty;
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
      return isCompleteProfile(response);
    }

    if (userId == null) return false;
    try {
      final response = await _apiClient.dio.get('/profiles/me');
      return isCompleteProfile(Map<String, dynamic>.from(response.data as Map));
    } catch (_) {
      return false;
    }
  }

  Future<String> getUsername({String? userId}) async {
    if (AppConfig.useLegacySupabase) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();
      return _usernameFromProfile(response);
    }

    if (userId == null) throw Exception('No user logged in');
    final response = await _apiClient.dio.get('/profiles/me');
    return _usernameFromProfile(
      Map<String, dynamic>.from(response.data as Map),
    );
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

  String _usernameFromProfile(Map<String, dynamic>? profile) {
    if (!isCompleteProfile(profile)) {
      throw Exception('Profile is incomplete');
    }
    return (profile!['username'] as String).trim();
  }
}
