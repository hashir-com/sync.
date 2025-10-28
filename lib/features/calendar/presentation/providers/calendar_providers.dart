import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:sync_event/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:sync_event/features/calendar/domain/entities/calendar_event_entity.dart';
import 'package:sync_event/features/calendar/domain/repositories/calendar_repository.dart';

// Firebase instance
final calendarFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data source
final calendarRemoteDataSourceProvider = Provider<CalendarRemoteDataSource>((
  ref,
) {
  return CalendarRemoteDataSourceImpl(
    firestore: ref.watch(calendarFirestoreProvider),
  );
});

// Repository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl(
    remoteDataSource: ref.watch(calendarRemoteDataSourceProvider),
  );
});

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Events for date range stream
final eventsForDateRangeProvider = StreamProvider.autoDispose
    .family<List<CalendarEventEntity>, DateTimeRange>((ref, dateRange) {
      final repository = ref.watch(calendarRepositoryProvider);
      return repository.getEventsForDateRange(dateRange.start, dateRange.end);
    });

// Events for specific day
final eventsForDayProvider = FutureProvider.autoDispose
    .family<List<CalendarEventEntity>, DateTime>((ref, day) {
      final repository = ref.watch(calendarRepositoryProvider);
      return repository.getEventsForDay(day);
    });
