
import 'package:sync_event/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:sync_event/features/calendar/domain/entities/calendar_event_entity.dart';
import 'package:sync_event/features/calendar/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource remoteDataSource;

  CalendarRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<CalendarEventEntity>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return remoteDataSource.getEventsForDateRange(startDate, endDate);
  }

  @override
  Future<List<CalendarEventEntity>> getEventsForDay(DateTime day) {
    return remoteDataSource.getEventsForDay(day);
  }

  @override
  Future<Map<DateTime, List<CalendarEventEntity>>> getEventsGroupedByDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final events = await remoteDataSource
        .getEventsForDateRange(startDate, endDate)
        .first;

    final groupedEvents = <DateTime, List<CalendarEventEntity>>{};

    for (var event in events) {
      final dateKey = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );

      if (groupedEvents.containsKey(dateKey)) {
        groupedEvents[dateKey]!.add(event);
      } else {
        groupedEvents[dateKey] = [event];
      }
    }

    return groupedEvents;
  }
}