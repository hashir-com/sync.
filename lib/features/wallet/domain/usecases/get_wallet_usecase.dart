import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';
import 'package:sync_event/features/wallet/domain/repositories/wallet_repositories.dart';

class GetWalletUseCase implements UseCase<WalletEntity, GetWalletParams> {
  final WalletRepository repository;
  GetWalletUseCase(this.repository);

  @override
  Future<Either<Failure, WalletEntity>> call(GetWalletParams params) {
    return repository.getWallet(params.userId);
  }
}

class GetWalletParams extends Equatable {
  final String userId;
  const GetWalletParams(this.userId);

  @override
  List<Object?> get props => [userId];
}
