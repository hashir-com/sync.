import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String eventId;
  final String ticketType;
  final int ticketQuantity;
  final double totalAmount;
  final String paymentId;
  final List<String> seatNumbers;  // Changed from List<int>
  final String status;
  final DateTime bookingDate;
  final DateTime? cancellationDate;
  final double? refundAmount;
  final DateTime startTime;
  final DateTime endTime;
  final String userEmail;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.ticketType,
    required this.ticketQuantity,
    required this.totalAmount,
    required this.paymentId,
    required this.seatNumbers,
    this.status = 'confirmed',
    required this.bookingDate,
    this.cancellationDate,
    this.refundAmount,
    required this.startTime,
    required this.endTime,
    required this.userEmail,
  });
  
  BookingEntity copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? ticketType,
    int? ticketQuantity,
    double? totalAmount,
    String? paymentId,
    List<String>? seatNumbers,
    String? status,
    DateTime? bookingDate,
    DateTime? cancellationDate,
    double? refundAmount,
    DateTime? startTime,
    DateTime? endTime,
    String? userEmail,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      ticketType: ticketType ?? this.ticketType,
      ticketQuantity: ticketQuantity ?? this.ticketQuantity,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentId: paymentId ?? this.paymentId,
      seatNumbers: seatNumbers ?? this.seatNumbers,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      refundAmount: refundAmount ?? this.refundAmount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, eventId, ticketType, ticketQuantity, totalAmount,
    paymentId, seatNumbers, status, bookingDate, cancellationDate,
    refundAmount, startTime, endTime, userEmail,
  ];
}