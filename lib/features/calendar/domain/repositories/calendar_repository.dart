import 'package:sync_event/features/calendar/domain/entities/calendar_event_entity.dart';

abstract class CalendarRepository {
  Stream<List<CalendarEventEntity>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  Future<List<CalendarEventEntity>> getEventsForDay(DateTime day);
  
  Future<Map<DateTime, List<CalendarEventEntity>>> getEventsGroupedByDate(
    DateTime startDate,
    DateTime endDate,
  );
}