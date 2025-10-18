import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';
import 'package:sync_event/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:sync_event/features/wallet/domain/usecases/update_wallet_usecase.dart';

final updateWalletUseCaseProvider = Provider<UpdateWalletUseCase>((ref) {
  return di.sl<UpdateWalletUseCase>();
});

final getWalletUseCaseProvider = Provider<GetWalletUseCase>((ref) {
  return di.sl<GetWalletUseCase>();
});

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<WalletModel>>((ref) {
  final updateWalletUseCase = ref.watch(updateWalletUseCaseProvider);
  final getWalletUseCase = ref.watch(getWalletUseCaseProvider);
  return WalletNotifier(updateWalletUseCase, getWalletUseCase);
});

class WalletNotifier extends StateNotifier<AsyncValue<WalletModel>> {
  final UpdateWalletUseCase updateWalletUseCase;
  final GetWalletUseCase getWalletUseCase;

  WalletNotifier(this.updateWalletUseCase, this.getWalletUseCase)
      : super(const AsyncValue.loading());

  Future<void> fetchWallet(String userId) async {
    if (userId.isEmpty) {
      state = AsyncValue.error('User ID is empty', StackTrace.current);
      return;
    }
    state = const AsyncValue.loading();
    final result = await getWalletUseCase(GetWalletParams(userId));
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (wallet) => AsyncValue.data(wallet),
    );
  }

  Future<void> updateWallet(double amount) async {
    final currentWallet = state.value ??
        WalletModel(userId: '', balance: 0.0, transactionHistory: []);
    final newWallet = WalletModel(
      userId: currentWallet.userId,
      balance: currentWallet.balance + amount,
      transactionHistory: currentWallet.transactionHistory,
    );
    final result = await updateWalletUseCase(newWallet);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => AsyncValue.data(newWallet),
    );
  }
}