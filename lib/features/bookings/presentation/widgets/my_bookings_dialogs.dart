// CancellationReasonDialog Widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

class CancellationReasonDialog extends ConsumerStatefulWidget {
  final bool isDark;
  const CancellationReasonDialog({required this.isDark, super.key});

  @override
  ConsumerState<CancellationReasonDialog> createState() => _CancellationReasonDialogState();
}

class _CancellationReasonDialogState extends ConsumerState<CancellationReasonDialog> {
  String? selectedReason;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why are you cancelling?', style: AppTextStyles.headingSmall(isDark: widget.isDark)),
            SizedBox(height: AppSizes.spacingMedium.h),
            // ... RadioListTiles using local state (small dialog = OK)
            // ... validation and buttons
          ],
        ),
      ),
    );
  }
}

// RefundMethodDialog Widget  
class RefundMethodDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Refund to Wallet (Instant)'),
              subtitle: const Text('Amount credited immediately'),
              onTap: () => Navigator.pop(context, 'wallet'),
            ),
            // ... bank option
          ],
        ),
      ),
    );
  }
}