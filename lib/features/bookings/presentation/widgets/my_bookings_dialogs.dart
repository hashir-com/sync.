// CancellationReasonDialog - COMPLETE
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

class CancellationReasonDialog extends ConsumerStatefulWidget {
  final bool isDark;
  const CancellationReasonDialog({required this.isDark, super.key});

  @override
  ConsumerState<CancellationReasonDialog> createState() =>
      _CancellationReasonDialogState();
}

class _CancellationReasonDialogState
    extends ConsumerState<CancellationReasonDialog> {
  String? selectedReason;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(widget.isDark),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.getTextSecondary(widget.isDark),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why are you cancelling?',
                        style: AppTextStyles.headingSmall(
                          isDark: widget.isDark,
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingMedium.h),

                      _buildReasonOption('Change of plans', 'change_of_plans'),
                      _buildReasonOption('Event rescheduled', 'rescheduled'),
                      _buildReasonOption(
                        'Event cancelled by organizer',
                        'organizer_cancelled',
                      ),
                      _buildReasonOption('Better event found', 'better_event'),
                      _buildReasonOption('Personal emergency', 'emergency'),
                      _buildReasonOption('Other', 'other'),

                      SizedBox(height: AppSizes.spacingLarge.h),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.getBorder(widget.isDark),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.labelMedium(
                                  isDark: widget.isDark,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingMedium.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedReason != null
                                  ? () => Navigator.pop(context, selectedReason)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.getPrimary(
                                  widget.isDark,
                                ),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                'Confirm',
                                style: AppTextStyles.labelMedium(isDark: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonOption(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingSmall.h),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: AppTextStyles.bodyMedium(isDark: widget.isDark),
        ),
        value: value,
        groupValue: selectedReason,
        onChanged: (newValue) => setState(() => selectedReason = newValue),
        dense: true,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
        ),
        tileColor: AppColors.getCard(widget.isDark),
      ),
    );
  }
}

// RefundMethodDialog - COMPLETE
// Updated RefundMethodDialog - COMPLETE
class RefundMethodDialog extends StatelessWidget {
  final bool isDark; //  Add required parameter

  const RefundMethodDialog({super.key, required this.isDark}); //  Required

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark), //  Use isDark
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.getTextSecondary(isDark), //  Use isDark
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                  children: [
                    _buildRefundOption(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Refund to Wallet',
                      subtitle: 'Instant credit to your wallet balance',
                      value: 'wallet',
                      color: AppColors.getSuccess(isDark), //  Use isDark
                    ),
                    SizedBox(height: AppSizes.spacingMedium.h),
                    _buildRefundOption(
                      context,
                      icon: Icons.account_balance,
                      title: 'Bank Transfer',
                      subtitle: 'Transfer to bank account (2-5 business days)',
                      value: 'bank',
                      color: AppColors.getPrimary(isDark), //  Use isDark
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefundOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    return Card(
      color: AppColors.getCard(isDark), //  Use isDark
      elevation: AppSizes.cardElevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
      ),
      child: InkWell(
        //  Better UX
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
        onTap: () => Navigator.pop(context, value),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: AppSizes.spacingMedium.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge(
                        isDark: isDark,
                      ), //  Use isDark
                    ),
                    SizedBox(height: AppSizes.spacingXs.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall(
                        isDark: isDark,
                      ), //  Use isDark
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.getTextSecondary(isDark), //  Use isDark
              ),
            ],
          ),
        ),
      ),
    );
  }
}
