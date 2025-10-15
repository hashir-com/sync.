// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sync_event/core/constants/app_colors.dart';
// import 'package:sync_event/core/constants/app_sizes.dart';
// import 'package:sync_event/core/constants/app_theme.dart';
// import 'package:sync_event/features/home/screen/drawer.dart';
// import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';
// import 'package:sync_event/features/wallet/presentation/provider/wallet_provider.dart';

// class WalletScreen extends ConsumerWidget {
//   const WalletScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isDark = ref.watch(themeProvider);
//     final userId = ref.watch(authStateProvider).value?.uid ?? ''; // Assume authStateProvider exists
//     final walletState = ref.watch(walletNotifierProvider);

//     ref.read(walletNotifierProvider.notifier).fetchWallet(userId);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Wallet', style: Theme.of(context).textTheme.titleLarge),
//         backgroundColor: AppColors.getPrimary(isDark),
//       ),
//       body: walletState.when(
//         data: (wallet) => _buildWalletDetails(context, wallet, isDark),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }

//   Widget _buildWalletDetails(BuildContext context, WalletEntity wallet, bool isDark) {
//     return Padding(
//       padding: EdgeInsets.all(AppSizes.paddingMedium.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Balance: ₹${wallet.balance.toStringAsFixed(2)}',
//               style: Theme.of(context).textTheme.headlineMedium),
//           SizedBox(height: AppSizes.spacingXxl.h),
//           Text('Transaction History', style: Theme.of(context).textTheme.titleMedium),
//           // Add transaction list if needed
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/home/screen/drawer.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Delay the fetch to avoid build-time modification
    Future.microtask(() {
      final userId =
          ref.read(authStateProvider).value?.uid ??
          ''; // Assume authStateProvider exists
      if (userId.isNotEmpty) {
        ref.read(walletNotifierProvider.notifier).fetchWallet(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletState = ref.watch(walletNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: AppTextStyles.headingMedium(isDark: isDark),
        ),
        backgroundColor: AppColors.getPrimary(isDark),
      ),
      body: walletState.when(
        data: (wallet) => Center(
          child: Text(
            'Balance: ₹${wallet.balance.toStringAsFixed(2)}',
            style: AppTextStyles.bodyLarge(isDark: isDark),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
        ),
      ),
    );
  }
}
