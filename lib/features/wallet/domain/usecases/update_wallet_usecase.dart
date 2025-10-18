import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';
import 'package:sync_event/features/wallet/domain/repositories/wallet_repositories.dart';

class UpdateWalletUseCase implements UseCase<Unit, WalletEntity> {
  final WalletRepository repository;

  UpdateWalletUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(WalletEntity wallet) async {
    return await repository.updateWallet(wallet);
  }
}
