import 'package:shared_preferences/shared_preferences.dart';

abstract class EventLocalDataSource {
  Future<void> cacheEvents(String eventsData);
  Future<String?> getCachedEvents();
  Future<void> clearEventsCache();
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final SharedPreferences sharedPreferences;

  EventLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheEvents(String eventsData) async {
    await sharedPreferences.setString('cached_events_data', eventsData);
  }

  @override
  Future<String?> getCachedEvents() async {
    return sharedPreferences.getString('cached_events_data');
  }

  @override
  Future<void> clearEventsCache() async {
    await sharedPreferences.remove('cached_events_data');
  }
}
