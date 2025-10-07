import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_event/core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserData(String userData);
  Future<void> clearUserData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUserData(String userData) async {
    try {
      await sharedPreferences.setString('user_data', userData);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user data');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await sharedPreferences.remove('user_data');
    } catch (e) {
      throw CacheException(message: 'Failed to clear user data');
    }
  }
}