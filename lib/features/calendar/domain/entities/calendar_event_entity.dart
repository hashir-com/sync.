import 'package:equatable/equatable.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class CalendarEventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String category;
  final String imageUrl;
  final int availableTickets;
  final double price;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.availableTickets,
    required this.price,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        location,
        category,
        imageUrl,
        availableTickets,
        price,
      ];
}

extension CalendarEventMapper on CalendarEventEntity {
  EventEntity toEventEntity() {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      location: location,
      startTime: startDate,
      endTime: endDate,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      documentUrl: null,
      organizerId: '', // Unknown in calendar context
      organizerName: '',
      attendees: const [],
      maxAttendees: availableTickets, // Temporary assumption
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ticketPrice: price,
      status: 'approved',
      approvalReason: null,
      rejectionReason: null,
      takenSeats: const [],
      categoryCapacities: const {'vip': 0, 'premium': 0, 'regular': 0},
      categoryPrices: const {'vip': 0.0, 'premium': 0.0, 'regular': 0.0},
      availableTickets: availableTickets,
    );
  }
}
