import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/calendar/data/models/calendar_event_model.dart';

abstract class CalendarRemoteDataSource {
  Stream<List<CalendarEventModel>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<CalendarEventModel>> getEventsForDay(DateTime day);
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final FirebaseFirestore firestore;

  CalendarRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<CalendarEventModel>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => CalendarEventModel.fromFirestore(doc))
              .toList();
          // Sort by startDate
          events.sort((a, b) => a.startDate.compareTo(b.startDate));
          return events;
        });
  }

  @override
  Future<List<CalendarEventModel>> getEventsForDay(DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    final snapshot = await firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    final events = snapshot.docs
        .map((doc) => CalendarEventModel.fromFirestore(doc))
        .toList();
    
    // Sort by startDate
    events.sort((a, b) => a.startDate.compareTo(b.startDate));
    
    return events;
  }
}