import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String eventId;
  final String ticketType;
  final int ticketQuantity;
  final double totalAmount;
  final String paymentId; // Razorpay payment ID
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime bookingDate;
  final DateTime? cancellationDate;
  final double? refundAmount;
  final DateTime startTime; // Event start time
  final DateTime endTime;   // Event end time

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.ticketType,
    required this.ticketQuantity,
    required this.totalAmount,
    required this.paymentId,
    this.status = 'pending',
    required this.bookingDate,
    this.cancellationDate,
    this.refundAmount,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        eventId,
        ticketType,
        ticketQuantity,
        totalAmount,
        paymentId,
        status,
        bookingDate,
        cancellationDate,
        refundAmount,
        startTime,
        endTime,
      ];
}