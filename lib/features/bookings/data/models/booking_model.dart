// lib/features/bookings/data/models/booking_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';

// lib/features/bookings/data/models/booking_model.dart
class BookingModel extends BookingEntity {
  const BookingModel({
    required String id,
    required String userId,
    required String eventId,
    required String ticketType,
    required int ticketQuantity,
    required double totalAmount,
    required String paymentId,
    required List<int> seatNumbers, // NEW: Add seat numbers
    String status = 'confirmed', // Changed default to confirmed
    required DateTime bookingDate,
    DateTime? cancellationDate,
    double? refundAmount,
    required DateTime startTime,
    required DateTime endTime,
  }) : super(
          id: id,
          userId: userId,
          eventId: eventId,
          ticketType: ticketType,
          ticketQuantity: ticketQuantity,
          totalAmount: totalAmount,
          paymentId: paymentId,
          seatNumbers: seatNumbers, // NEW
          status: status,
          bookingDate: bookingDate,
          cancellationDate: cancellationDate,
          refundAmount: refundAmount,
          startTime: startTime,
          endTime: endTime,
        );

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['userId'],
      eventId: json['eventId'],
      ticketType: json['ticketType'],
      ticketQuantity: (json['ticketQuantity'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentId: json['paymentId'],
      seatNumbers: List<int>.from(json['seatNumbers'] ?? []), // NEW
      status: json['status'] ?? 'confirmed',
      bookingDate: (json['bookingDate'] as Timestamp).toDate(),
      cancellationDate: json['cancellationDate'] != null
          ? (json['cancellationDate'] as Timestamp).toDate()
          : null,
      refundAmount: json['refundAmount'] != null
          ? (json['refundAmount'] as num).toDouble()
          : null,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'ticketType': ticketType,
      'ticketQuantity': ticketQuantity,
      'totalAmount': totalAmount,
      'paymentId': paymentId,
      'seatNumbers': seatNumbers, // NEW
      'status': status,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'cancellationDate': cancellationDate != null
          ? Timestamp.fromDate(cancellationDate!)
          : null,
      'refundAmount': refundAmount,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? ticketType,
    int? ticketQuantity,
    double? totalAmount,
    String? paymentId,
    List<int>? seatNumbers, // NEW
    String? status,
    DateTime? bookingDate,
    DateTime? cancellationDate,
    double? refundAmount,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      ticketType: ticketType ?? this.ticketType,
      ticketQuantity: ticketQuantity ?? this.ticketQuantity,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentId: paymentId ?? this.paymentId,
      seatNumbers: seatNumbers ?? this.seatNumbers, // NEW
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      refundAmount: refundAmount ?? this.refundAmount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  static BookingModel fromEntity(BookingEntity entity) => BookingModel(
        id: entity.id,
        userId: entity.userId,
        eventId: entity.eventId,
        ticketType: entity.ticketType,
        ticketQuantity: entity.ticketQuantity,
        totalAmount: entity.totalAmount,
        paymentId: entity.paymentId,
        seatNumbers: entity.seatNumbers, // NEW
        status: entity.status,
        bookingDate: entity.bookingDate,
        cancellationDate: entity.cancellationDate,
        refundAmount: entity.refundAmount,
        startTime: entity.startTime,
        endTime: entity.endTime,
      );
}