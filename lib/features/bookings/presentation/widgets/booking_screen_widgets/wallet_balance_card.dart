// lib/features/bookings/presentation/widgets/booking_screen_widgets/booking_wallet_balance_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_provider.dart';

class BookingWalletBalanceCard extends ConsumerWidget {
  const BookingWalletBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final walletAsync = ref.watch(walletNotifierProvider);

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDark).withOpacity(0.08),
            AppColors.getPrimary(isDark).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.getPrimary(isDark),
            size: AppSizes.iconLarge,
          ),
          SizedBox(width: AppSizes.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: AppTextStyles.headingSmall(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSizes.spacingSmall),
                walletAsync.when(
                  data: (wallet) => Text(
                    '₹${wallet.balance.toStringAsFixed(0)}',
                    style: AppTextStyles.titleLarge(isDark: isDark).copyWith(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getPrimary(isDark),
                    ),
                  ),
                  loading: () => SizedBox(
                    width: 100,
                    height: AppSizes.fontXl,
                    child: const LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  error: (error, stack) => Text(
                    'Error loading balance',
                    style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                      color: AppColors.getError(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}