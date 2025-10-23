import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/calendar/domain/entities/calendar_event_entity.dart';

class CalendarEventModel extends CalendarEventEntity {
  const CalendarEventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startDate,
    required super.endDate,
    required super.location,
    required super.category,
    required super.imageUrl,
    required super.availableTickets,
    required super.price,
  });

  factory CalendarEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle timestamps
    final startTime = data['startTime'] as Timestamp?;
    final endTime = data['endTime'] as Timestamp?;
    
    // Calculate available tickets
    final maxAttendees = (data['maxAttendees'] ?? 0) as int;
    final takenSeats = (data['takenSeats'] as List?)?.length ?? 0;
    final availableTickets = maxAttendees - takenSeats;
    
    return CalendarEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: startTime?.toDate() ?? DateTime.now(),
      endDate: endTime?.toDate() ?? startTime?.toDate() ?? DateTime.now(),
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? data['image'] ?? '',
      availableTickets: availableTickets,
      price: ((data['ticketPrice'] ?? 0) as num).toDouble(),
    );
  }

  factory CalendarEventModel.fromEntity(CalendarEventEntity entity) {
    return CalendarEventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startDate: entity.startDate,
      endDate: entity.endDate,
      location: entity.location,
      category: entity.category,
      imageUrl: entity.imageUrl,
      availableTickets: entity.availableTickets,
      price: entity.price,
    );
  }
}