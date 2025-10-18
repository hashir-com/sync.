// lib/features/bookings/data/repositories/booking_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/bookings/data/datasources/booking_remote_datasource.dart';
import 'package:sync_event/features/bookings/data/models/booking_model.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final EventRepository eventRepository;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.eventRepository,
  });

  @override
Future<Either<Failure, Unit>> refundToWallet(
  String userId,
  double amount,
  String bookingId,
) async {
  if (!(await networkInfo.isConnected)) {
    return Left(NetworkFailure(message: 'No internet connection'));
  }
  try {
    // Add refund to wallet
    await remoteDataSource.addRefundToWallet(userId, amount, bookingId);
    
    // Update booking refund status
    await remoteDataSource.updateBookingRefundStatus(
      bookingId,
      'wallet',
      amount,
    );
    
    return const Right(unit);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}

@override
Future<Either<Failure, Unit>> refundToBank(
  String userId,
  String paymentId,
  double amount,
  String bookingId,
) async {
  if (!(await networkInfo.isConnected)) {
    return Left(NetworkFailure(message: 'No internet connection'));
  }
  try {
    // Process Razorpay refund
    await remoteDataSource.refundToRazorpay(paymentId, amount);
    
    // Record refund in database
    await remoteDataSource.recordRefundToBank(
      bookingId,
      paymentId,
      amount,
    );
    
    // Update booking refund status
    await remoteDataSource.updateBookingRefundStatus(
      bookingId,
      'bank',
      amount,
    );
    
    return const Right(unit);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}

  @override
  Future<Either<Failure, BookingEntity>> bookTicket(
    BookingEntity booking,
  ) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final booked = await remoteDataSource.bookTicket(
        BookingModel.fromEntity(booking),
      );
      return Right(booked);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelBooking(
    String bookingId,
    String paymentId,
  ) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.cancelBooking(bookingId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> refundToRazorpay(
    String paymentId,
    double amount,
  ) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.refundToRazorpay(paymentId, amount);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(
    String userId,
  ) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final bookings = await remoteDataSource.getUserBookings(userId);
      return Right(bookings);
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('does not exist')) {
        return Right(
          [],
        ); // Return empty list if collection missing or no permission
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBooking(String bookingId) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final booking = await remoteDataSource.getBooking(bookingId);
      return Right(booking);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEvent(String eventId) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final event = await eventRepository.getEvent(eventId);
      return Right(event);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestRefund(
    String bookingId,
    String refundType,
  ) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.requestRefund(bookingId, refundType);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
