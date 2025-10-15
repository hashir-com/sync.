import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final int maxAttendees; // Legacy total; use sum of categoryCapacities in code.
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? ticketPrice; // Legacy single price; use categoryPrices in code.
  final String status;
  final String? approvalReason;
  final String? rejectionReason;
  final Map<String, int> categoryCapacities;
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

  // Updated fromJson method
  factory EventEntity.fromJson(Map<String, dynamic> json) {
    return EventEntity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'],
      documentUrl: json['documentUrl'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      attendees: List<String>.from(json['attendees'] ?? []),
      maxAttendees: (json['maxAttendees'] as num?)?.toInt() ?? 0, // Cast num to int
      category: json['category'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      ticketPrice: json['ticketPrice'],
      status: json['status'],
      approvalReason: json['approvalReason'],
      rejectionReason: json['rejectionReason'],
      categoryCapacities: Map<String, int>.from(
        (json['categoryCapacities'] ?? {'vip': 0, 'premium': 0, 'regular': 0})
            .map((key, value) => MapEntry(key, (value as num).toInt())), // Cast num to int
      ),
      categoryPrices: Map<String, double>.from(
        json['categoryPrices'] ?? {'vip': 0.0, 'premium': 0.0, 'regular': 0.0},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'attendees': attendees,
      'maxAttendees': maxAttendees,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'ticketPrice': ticketPrice,
      'status': status,
      'approvalReason': approvalReason,
      'rejectionReason': rejectionReason,
      'categoryCapacities': categoryCapacities,
      'categoryPrices': categoryPrices,
    };
  }
}