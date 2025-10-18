import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';
import 'package:sync_event/features/wallet/domain/repositories/wallet_repositories.dart';

class UpdateWalletUseCase implements UseCase<Unit, WalletModel> {
  final WalletRepository repository;

  UpdateWalletUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(WalletModel wallet) async {
    return await repository.updateWallet(wallet);
  }
}