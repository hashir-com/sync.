import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class ProfileLocalDataSource {
  Future<void> cacheProfileData(Map<String, dynamic> profileData);
  Future<Map<String, dynamic>?> getCachedProfileData();
  Future<void> clearProfileData();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProfileData(Map<String, dynamic> profileData) async {
    await sharedPreferences.setString('cached_profile_data', json.encode(profileData));
  }

  @override
  Future<Map<String, dynamic>?> getCachedProfileData() async {
    final String? cachedString = sharedPreferences.getString('cached_profile_data');
    if (cachedString != null) {
      return json.decode(cachedString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> clearProfileData() async {
    await sharedPreferences.remove('cached_profile_data');
  }
}