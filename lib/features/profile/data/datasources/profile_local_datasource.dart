import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheProfileData(String profileData);
  Future<String?> getCachedProfileData();
  Future<void> clearProfileData();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProfileData(String profileData) async {
    await sharedPreferences.setString('cached_profile_data', profileData);
  }

  @override
  Future<String?> getCachedProfileData() async {
    return sharedPreferences.getString('cached_profile_data');
  }

  @override
  Future<void> clearProfileData() async {
    await sharedPreferences.remove('cached_profile_data');
  }
}
