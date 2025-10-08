// Local data source: simple caching in SharedPreferences (json string).
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

abstract class EventLocalDataSource {
  Future<void> cacheEvents(List<EventModel> events);
  Future<List<EventModel>> getCachedEvents();
}

const String CACHED_EVENTS_KEY = 'CACHED_EVENTS';

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final SharedPreferences sharedPreferences;
  EventLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheEvents(List<EventModel> events) {
    final jsonList = events.map((e) => e.toMap()).toList();
    return sharedPreferences.setString(CACHED_EVENTS_KEY, jsonEncode(jsonList));
  }

  @override
  Future<List<EventModel>> getCachedEvents() async {
    final jsonString = sharedPreferences.getString(CACHED_EVENTS_KEY);
    if (jsonString == null) return [];
    final List data = jsonDecode(jsonString) as List;
    return data.map((e) => EventModel.fromMap(Map<String, dynamic>.from(e), e['id'] ?? '')).toList();
  }
}
