import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String? imageUrl;
  final String organizerId;
  final String organizerName;
  final List<String> attendees;
  final int maxAttendees;
  final String category;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.imageUrl,
    required this.organizerId,
    required this.organizerName,
    this.attendees = const [],
    required this.maxAttendees,
    required this.category,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    location,
    startTime,
    endTime,
    imageUrl,
    organizerId,
    organizerName,
    attendees,
    maxAttendees,
    category,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
}
