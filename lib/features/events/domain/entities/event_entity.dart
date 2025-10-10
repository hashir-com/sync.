import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime startTime;
  final DateTime endTime;
  final String? imageUrl;
  final String? documentUrl;
  final String organizerId;
  final String organizerName;
  final List<String> attendees;
  final int maxAttendees;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? ticketPrice;
  final String status;
  


  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.startTime,
    required this.endTime,
    required this.imageUrl,
    this.documentUrl,
    required this.organizerId,
    required this.organizerName,
    this.attendees = const [],
    required this.maxAttendees,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.ticketPrice,
    this.status = "pending",
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    location,
    latitude,
    longitude,
    startTime,
    endTime,
    imageUrl,
    organizerId,
    organizerName,
    attendees,
    maxAttendees,
    category,
    createdAt,
    updatedAt,
    ticketPrice,
    documentUrl,
    status,
  ];
}
