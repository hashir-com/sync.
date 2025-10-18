import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;
import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';
import 'package:sync_event/features/wallet/domain/usecases/update_wallet_usecase.dart';

final updateWalletUseCaseProvider = Provider<UpdateWalletUseCase>((ref) {
  return di.sl<UpdateWalletUseCase>();
});

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<WalletEntity>>((ref) {
  final updateWalletUseCase = ref.watch(updateWalletUseCaseProvider);
  return WalletNotifier(updateWalletUseCase);
});

class WalletNotifier extends StateNotifier<AsyncValue<WalletEntity>> {
  final UpdateWalletUseCase updateWalletUseCase;

  WalletNotifier(this.updateWalletUseCase) : super(const AsyncValue.loading());

  Future<void> fetchWallet(String userId) async {
    state = const AsyncValue.loading();
    // Assume getWallet use case exists; implement in repository if needed
    // final result = await getWalletUseCase(NoParams());
    // state = result.fold(
    //   (failure) => AsyncValue.error(failure, StackTrace.current),
    //   (wallet) => AsyncValue.data(wallet),
    // );
    state = AsyncValue.data(WalletEntity(userId: userId, balance: 0.0)); // Mock for now
  }

  Future<void> updateWallet(double amount) async {
    final currentWallet = state.value ?? WalletEntity(userId: '', balance: 0.0);
    final newWallet = WalletEntity(
      userId: currentWallet.userId,
      balance: currentWallet.balance + amount,
    );
    final result = await updateWalletUseCase(newWallet);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => AsyncValue.data(newWallet),
    );
  }
}