import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletModel>> getWallet(String userId);
  Future<Either<Failure, Unit>> updateWallet(WalletModel wallet);
  Future<Either<Failure, Unit>> addRefundToWallet(
    String userId,
    double amount,
    String bookingId,
    String? reason,
  );
}
