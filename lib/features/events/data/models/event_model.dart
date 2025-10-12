import 'dart:math';

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
    super.status,
    super.approvalReason,
    super.rejectionReason,
    super.categoryCapacities,
    super.categoryPrices,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    //  Parse capacities with migration from legacy maxAttendees.
    Map<String, int> capacities = {'vip': 0, 'premium': 0, 'regular': 0};
    if (map['categoryCapacities'] is Map<String, dynamic>) {
      (map['categoryCapacities'] as Map<String, dynamic>).forEach((k, v) {
        capacities[k] = (v as num).toInt();
      });
    } else if (map['maxAttendees'] != null &&
        capacities.values.fold(0, (a, b) => a + b) == 0) {
      // Migration: If no map but legacy exists, replicate across categories or set to regular.
      final legacyMax = (map['maxAttendees'] as num).toInt();
      capacities = {
        'vip': legacyMax ~/ 3,
        'premium': legacyMax ~/ 3,
        'regular': legacyMax ~/ 3,
      }; // Or custom split
    }

    //  Parse prices with migration from legacy ticketPrice.
    Map<String, double> prices = {'vip': 0.0, 'premium': 0.0, 'regular': 0.0};
    if (map['categoryPrices'] is Map<String, dynamic>) {
      (map['categoryPrices'] as Map<String, dynamic>).forEach((k, v) {
        prices[k] = (v as num).toDouble();
      });
    } else if (map['ticketPrice'] != null &&
        prices.values.every((p) => p == 0.0)) {
      // Migration: Replicate legacy price or set to regular.
      final legacyPrice = (map['ticketPrice'] as num).toDouble();
      prices = {
        'vip': legacyPrice * 1.5,
        'premium': legacyPrice,
        'regular': legacyPrice * 0.5,
      }; // Example tiering; adjust or uniform
    }

    //  Compute legacy from maps if missing (for old code paths).
    int maxAttendees =
        map['maxAttendees'] ?? capacities.values.fold(0, (a, b) => a + b);
    double ticketPrice =
        map['ticketPrice'] ??
        (prices.values.reduce(min) > 0 ? prices.values.reduce(min) : 0.0);

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
      maxAttendees: maxAttendees,
      category: map['category'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      ticketPrice: ticketPrice,
      status: map['status'] ?? "pending",
      approvalReason: map['approvalReason'],
      rejectionReason: map['rejectionReason'],
      categoryCapacities: capacities,
      categoryPrices: prices,
    );
  }

  Map<String, dynamic> toMap() {
  // Always compute and save legacy from maps for consistency.
  final totalMax = categoryCapacities.values.fold(0, (a, b) => a + b);
  
  // FIX: Handle case where all prices are 0 (free event)
  final positivePrices = categoryPrices.values.where((p) => p > 0).toList();
  final minPrice = positivePrices.isNotEmpty 
      ? positivePrices.reduce(min) 
      : 0.0; // Default to 0.0 if all are free

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
    'maxAttendees': totalMax, // Synced
    'category': category,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'ticketPrice': minPrice, // Synced to min (or 0 if all free)
    'status': status,
    'categoryCapacities': categoryCapacities,
    'categoryPrices': categoryPrices,
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
    String? status,
    Map<String, int>? categoryCapacities,
    Map<String, double>? categoryPrices,
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
      status: status ?? this.status,
      categoryCapacities: categoryCapacities ?? this.categoryCapacities,
      categoryPrices: categoryPrices ?? this.categoryPrices,
    );
  }
}
