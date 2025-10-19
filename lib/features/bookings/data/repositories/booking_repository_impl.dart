import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/exceptions.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/bookings/data/datasources/booking_remote_datasource.dart';
import 'package:sync_event/features/bookings/data/models/booking_model.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';
import 'package:sync_event/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final WalletRemoteDataSource walletRemoteDataSource;
  final NetworkInfo networkInfo;
  final EventRepository eventRepository;
  final FirebaseAuth auth;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.walletRemoteDataSource,
    required this.networkInfo,
    required this.eventRepository,
    required this.auth,
  });

  @override
  Future<Either<Failure, BookingEntity>> bookTicket(
    BookingEntity booking,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final userId = auth.currentUser?.uid;
        if (userId == null) {
          return Left(ServerFailure(message: 'User not authenticated'));
        }

        final bookingWithUserId = BookingEntity(
          id: booking.id,
          userId: userId,
          eventId: booking.eventId,
          ticketType: booking.ticketType,
          ticketQuantity: booking.ticketQuantity,
          totalAmount: booking.totalAmount,
          paymentId: booking.paymentId,
          seatNumbers: booking.seatNumbers,
          status: booking.status ?? 'confirmed',
          bookingDate: booking.bookingDate,
          cancellationDate: booking.cancellationDate,
          refundAmount: booking.refundAmount,
          startTime: booking.startTime,
          endTime: booking.endTime,
          userEmail: booking.userEmail,
        );

        print(
          'BookingRepositoryImpl: Booking ticket with id=${booking.id}, userId=$userId',
        );
        final booked = await remoteDataSource.bookTicket(bookingWithUserId);
        return Right(booked.toEntity());
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      print('BookingRepositoryImpl: ServerException - ${e.message}');
      return Left(
        ServerFailure(message: 'Failed to book ticket: ${e.message}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(
    String bookingId,
    String paymentId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final booking = await remoteDataSource.getBooking(bookingId);
        print(
          'BookingRepositoryImpl: Cancelling bookingId=$bookingId, ticketQuantity=${booking.ticketQuantity}',
        );
        await remoteDataSource.cancelBooking(
          bookingId,
          paymentId,
          booking.eventId,
          booking.ticketQuantity,
        );
        return const Right(null);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      print('BookingRepositoryImpl: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBooking(String bookingId) async {
    try {
      if (await networkInfo.isConnected) {
        final booking = await remoteDataSource.getBooking(bookingId);
        return Right(booking.toEntity());
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      print('BookingRepositoryImpl: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(
    String userId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final bookings = await remoteDataSource.getUserBookings(userId);
        return Right(bookings.map((model) => model.toEntity()).toList());
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      print('BookingRepositoryImpl: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }

 @override
  Future<Either<Failure, void>> processRefund(
    String userId,
    String bookingId,
    String paymentId,
    double amount,
    String refundType,
    String? reason,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        print(
          'BookingRepositoryImpl: Processing refund for bookingId=$bookingId, refundType=$refundType, amount=$amount',
        );

        // CRITICAL: Process wallet refund FIRST (before updating booking status)
        if (refundType == 'wallet') {
          print('BookingRepositoryImpl: Adding refund to wallet first...');
          try {
            await walletRemoteDataSource.addRefundToWallet(
              userId,
              amount,
              bookingId,
              reason ?? 'Booking cancelled',
            );
            print('✓ Refund added to wallet successfully');
          } catch (e) {
            print('❌ BookingRepositoryImpl: Error adding refund to wallet - $e');
            // If wallet refund fails, don't proceed with booking status update
            return Left(ServerFailure(message: 'Failed to add refund to wallet: $e'));
          }
        } else if (refundType == 'bank') {
          print('BookingRepositoryImpl: Bank refund marked for processing (5-7 days)');
          // For bank refunds, just log it - actual processing handled by admin
        }

        // ONLY AFTER wallet refund succeeds, update booking status
        print('BookingRepositoryImpl: Now updating booking status to refunded...');
        await remoteDataSource.updateBookingStatus(
          bookingId,
          'refunded',
          amount,
        );
        print('✓ Booking status updated to refunded');

        return const Right(null);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      print('BookingRepositoryImpl: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('BookingRepositoryImpl: Error - $e');
      return Left(ServerFailure(message: 'Failed to process refund: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> requestRefund(
    String bookingId,
    String refundType,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.requestRefund(bookingId, refundType);
        return const Right(null);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      print('BookingRepositoryImpl: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> refundToRazorpay(
    String paymentId,
    double amount,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.refundToRazorpay(paymentId, amount);
        return const Right(null);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      print('BookingRepositoryImpl: ServerException - ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }
}