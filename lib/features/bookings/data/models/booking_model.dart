import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.eventId,
    required super.ticketType,
    required super.ticketQuantity,
    required super.totalAmount,
    required super.paymentId,
    required super.seatNumbers,
    super.status,
    required super.bookingDate,
    super.cancellationDate,
    super.refundAmount,
    required super.startTime,
    required super.endTime,
    required super.userEmail,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingModel(
      id: json['id'] ?? id,
      userId: json['userId'] ?? '',
      eventId: json['eventId'] ?? '',
      ticketType: json['ticketType'] ?? '',
      ticketQuantity: (json['ticketQuantity'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentId: json['paymentId'] ?? '',
      seatNumbers: List<String>.from(json['seatNumbers'] ?? []),
      status: json['status'] ?? 'confirmed',
      bookingDate: (json['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancellationDate: json['cancellationDate'] != null
          ? (json['cancellationDate'] as Timestamp).toDate()
          : null,
      refundAmount: json['refundAmount'] != null
          ? (json['refundAmount'] as num).toDouble()
          : null,
      startTime: (json['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (json['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userEmail: json['userEmail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'ticketType': ticketType,
      'ticketQuantity': ticketQuantity,
      'totalAmount': totalAmount,
      'paymentId': paymentId,
      'seatNumbers': seatNumbers,
      'status': status,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'cancellationDate': cancellationDate != null
          ? Timestamp.fromDate(cancellationDate!)
          : null,
      'refundAmount': refundAmount,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'userEmail': userEmail,
    };
  }

  BookingEntity toEntity() => BookingEntity(
        id: id,
        userId: userId,
        eventId: eventId,
        ticketType: ticketType,
        ticketQuantity: ticketQuantity,
        totalAmount: totalAmount,
        paymentId: paymentId,
        seatNumbers: seatNumbers,
        status: status,
        bookingDate: bookingDate,
        cancellationDate: cancellationDate,
        refundAmount: refundAmount,
        startTime: startTime,
        endTime: endTime,
        userEmail: userEmail,
      );

  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      userId: entity.userId,
      eventId: entity.eventId,
      ticketType: entity.ticketType,
      ticketQuantity: entity.ticketQuantity,
      totalAmount: entity.totalAmount,
      paymentId: entity.paymentId,
      seatNumbers: entity.seatNumbers,
      status: entity.status,
      bookingDate: entity.bookingDate,
      cancellationDate: entity.cancellationDate,
      refundAmount: entity.refundAmount,
      startTime: entity.startTime,
      endTime: entity.endTime,
      userEmail: entity.userEmail,
    );
  }
}