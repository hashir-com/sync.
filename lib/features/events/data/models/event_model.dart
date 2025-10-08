import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.location,
    required super.startTime,
    required super.endTime,
    super.imageUrl,
    super.documentUrl,
    required super.organizerId,
    required super.organizerName,
    super.attendees = const [],
    required super.maxAttendees,
    required super.category,
    super.latitude,
    super.longitude,
    required super.createdAt,
    required super.updatedAt,
    super.ticketPrice,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      documentUrl: map['documentUrl'],
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      attendees: List<String>.from(map['attendees'] ?? []),
      maxAttendees: map['maxAttendees'] ?? 0,
      category: map['category'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      ticketPrice: (map['ticketPrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    String? imageUrl,
    String? documentUrl,
    String? organizerId,
    String? organizerName,
    List<String>? attendees,
    int? maxAttendees,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? ticketPrice,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      attendees: attendees ?? this.attendees,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ticketPrice: ticketPrice ?? this.ticketPrice,
    );
  }
}
