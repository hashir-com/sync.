import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';
import 'package:sync_event/features/wallet/domain/repositories/wallet_repositories.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WalletModel>> getWallet(String userId) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final wallet = await remoteDataSource.getWallet(userId);
      return Right(wallet);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWallet(WalletModel wallet) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.updateWallet(wallet);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addRefundToWallet(
    String userId,
    double amount,
    String bookingId,
  ) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.addRefundToWallet(userId, amount, bookingId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}