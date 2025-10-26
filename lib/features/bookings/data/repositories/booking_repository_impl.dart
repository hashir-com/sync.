import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/exceptions.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/bookings/data/datasources/booking_remote_datasource.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';
import 'package:sync_event/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final WalletRemoteDataSource walletRemoteDataSource;
  final NetworkInfo networkInfo;
  final EventRepository eventRepository;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.walletRemoteDataSource,
    required this.networkInfo,
    required this.eventRepository,
    required this.auth,
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

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
          status: booking.status,
          bookingDate: booking.bookingDate,
          cancellationDate: booking.cancellationDate,
          refundAmount: booking.refundAmount,
          startTime: booking.startTime,
          endTime: booking.endTime,
          userEmail: booking.userEmail,
          paymentMethod: booking.paymentMethod,
        );

        print(
          'BookingRepositoryImpl: Booking ticket with id=${booking.id}, userId=$userId, paymentMethod=${bookingWithUserId.paymentMethod}, totalAmount=${bookingWithUserId.totalAmount}',
        );

        // Atomic transaction for booking + wallet deduction + event update
        final result = await firestore.runTransaction((transaction) async {
          print('   Starting atomic transaction for booking');

          // Step 1: Get and validate event
          final eventRef = firestore
              .collection('events')
              .doc(bookingWithUserId.eventId);
          final eventSnap = await transaction.get(eventRef);
          if (!eventSnap.exists) {
            print('   ✗ Event not found');
            throw Exception('Event not found');
          }
          final eventData = eventSnap.data()!;
          final availableTickets =
              (eventData['availableTickets'] as num?)?.toInt() ?? 0;
          print(
            '   Event availableTickets: $availableTickets, requested: ${bookingWithUserId.ticketQuantity}',
          );
          if (availableTickets < bookingWithUserId.ticketQuantity) {
            print('   ✗ Insufficient tickets');
            throw Exception('Insufficient tickets available');
          }

          // Step 2: Handle wallet deduction if using wallet
          if (bookingWithUserId.paymentMethod == 'wallet') {
            print('   Processing wallet payment');
            final walletRef = firestore.collection('wallets').doc(userId);
            final walletSnap = await transaction.get(walletRef);

            double currentBalance = 0.0;
            List<Map<String, dynamic>> currentTransactions = [];
            Timestamp? createdAt;
            if (walletSnap.exists) {
              final walletData = walletSnap.data()!;
              currentBalance =
                  (walletData['balance'] as num?)?.toDouble() ?? 0.0;
              currentTransactions = List<Map<String, dynamic>>.from(
                walletData['transactionHistory'] ?? [],
              );
              createdAt = walletData['createdAt'] as Timestamp?;
              print('   Current wallet balance: ₹$currentBalance');
            } else {
              print('   Wallet not found, will create with balance 0');
              currentBalance = 0.0;
            }

            if (currentBalance < bookingWithUserId.totalAmount) {
              print(
                '   ✗ Insufficient wallet balance: $currentBalance < ${bookingWithUserId.totalAmount}',
              );
              throw Exception(
                'Insufficient wallet balance: $currentBalance < ${bookingWithUserId.totalAmount}',
              );
            }

            final newBalance = currentBalance - bookingWithUserId.totalAmount;

            // CRITICAL FIX: Use Timestamp.now() instead of FieldValue.serverTimestamp() in transactions
            final now = Timestamp.now();

            final newTransaction = {
              'type': 'debit',
              'amount': bookingWithUserId.totalAmount,
              'bookingId': bookingWithUserId.id,
              'timestamp': now, // Use actual Timestamp, not FieldValue
              'description': 'Payment for Event Booking',
              'reason':
                  'Deducted ${bookingWithUserId.ticketQuantity} ${bookingWithUserId.ticketType} tickets for event ${bookingWithUserId.eventId}',
            };
            final updatedTransactions = [
              ...currentTransactions,
              newTransaction,
            ];

            // Prepare wallet data
            final walletData = <String, dynamic>{
              'userId': userId,
              'balance': newBalance,
              'transactionHistory': updatedTransactions,
              'updatedAt': now, // Use actual Timestamp
            };
            if (createdAt != null) {
              walletData['createdAt'] = createdAt;
            } else {
              walletData['createdAt'] = now; // Use actual Timestamp
            }

            // Set the wallet document (creates if not exists)
            transaction.set(walletRef, walletData);
            print('   Wallet set: New balance ₹$newBalance, transaction added');
          } else {
            print('   Processing razorpay payment - no wallet deduction');
          }

          // Step 3: Save booking
          final bookingRef = firestore
              .collection('bookings')
              .doc(bookingWithUserId.id);
          transaction.set(bookingRef, bookingWithUserId.toJson());
          print('   Booking saved');

          // Step 4: Update event availableTickets
          final newAvailableTickets =
              availableTickets - bookingWithUserId.ticketQuantity;
          transaction.update(eventRef, {
            'availableTickets': newAvailableTickets,
            'updatedAt': Timestamp.now(), // Use actual Timestamp
          });
          print('   Event updated: New availableTickets $newAvailableTickets');

          print('   ✓ All operations successful in transaction');
          return bookingWithUserId;
        });

        print('✓ Booking transaction completed successfully');
        return Right(result);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } on Exception catch (e) {
      print('BookingRepositoryImpl: Transaction failed - ${e.toString()}');
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      print('BookingRepositoryImpl: Unexpected error - $e');
      return Left(ServerFailure(message: e.toString()));
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
            print(
              '✗ BookingRepositoryImpl: Error adding refund to wallet - $e',
            );
            // If wallet refund fails, don't proceed with booking status update
            return Left(
              ServerFailure(message: 'Failed to add refund to wallet: $e'),
            );
          }
        } else if (refundType == 'bank') {
          print(
            'BookingRepositoryImpl: Bank refund marked for processing (5-7 days)',
          );
          // For bank refunds, just log it - actual processing handled by admin
        }

        // ONLY AFTER wallet refund succeeds, update booking status
        print(
          'BookingRepositoryImpl: Now updating booking status to refunded...',
        );
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
