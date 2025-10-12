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
  final int maxAttendees;  // Human: Legacy total; use sum of categoryCapacities in code.
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? ticketPrice;  // Human: Legacy single price; use categoryPrices in code.
  final String status;
  final String? approvalReason;
  final String? rejectionReason;

  // ADD: Per-category seats
  // Human: Map for capacities, e.g., {'vip': 50, 'premium': 100, 'regular': 200}. Defaults to 0. Stored in Firestore as nested map.
  final Map<String, int> categoryCapacities;

  // ADD: Per-category prices
  // Human: Map for prices, e.g., {'vip': 100.0, 'premium': 50.0, 'regular': 20.0}. Defaults to 0.0 (free).
  final Map<String, double> categoryPrices;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.startTime,
    required this.endTime,
    this.imageUrl,
    this.documentUrl,
    required this.organizerId,
    required this.organizerName,
    this.attendees = const [],
    required this.maxAttendees,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.ticketPrice,
    this.status = 'pending',
    this.approvalReason,
    this.rejectionReason,
    this.categoryCapacities = const {'vip': 0, 'premium': 0, 'regular': 0},
    this.categoryPrices = const {'vip': 0.0, 'premium': 0.0, 'regular': 0.0},
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
        documentUrl,
        organizerId,
        organizerName,
        attendees,
        maxAttendees,
        category,
        createdAt,
        updatedAt,
        ticketPrice,
        status,
        approvalReason,
        rejectionReason,
        categoryCapacities,
        categoryPrices,
      ];
}