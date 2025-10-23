// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you cancelling?',
              style: AppTextStyles.headingSmall(isDark: widget.isDark),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            _buildReasonOption('Ordered by mistake', 'ordered_by_mistake'),
            _buildReasonOption("Can't attend the event", 'cant_attend'),
            _buildReasonOption('Event rescheduled', 'event_rescheduled'),
            _buildReasonOption(
              'Found a better alternative',
              'better_alternative',
            ),
            _buildReasonOption('Other', 'other'),
            if (selectedReason == 'other')
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
                child: TextField(
                  controller: _otherReasonController,
                  decoration: InputDecoration(
                    labelText: 'Please specify (optional)',
                    labelStyle: AppTextStyles.bodyMedium(isDark: widget.isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.getBorder(widget.isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.getPrimary(widget.isDark),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.getSurface(widget.isDark),
                  ),
                  style: AppTextStyles.bodyMedium(isDark: widget.isDark),
                  maxLines: 2,
                ),
              ),
            SizedBox(height: AppSizes.spacingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium(isDark: widget.isDark),
                  ),
                ),
                SizedBox(width: AppSizes.spacingMedium),
                ElevatedButton(
                  onPressed: selectedReason != null ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimary(widget.isDark),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.getDisabled(
                      widget.isDark,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusLarge,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLarge,
                      vertical: AppSizes.paddingMedium,
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: AppTextStyles.bodyMedium(
                      isDark: widget.isDark,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(String title, String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedReason,
      onChanged: (newValue) => setState(() => selectedReason = newValue),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium(isDark: widget.isDark),
      ),
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      activeColor: AppColors.getPrimary(widget.isDark),
    );
  }

  void _handleNext() {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reason.'),
          backgroundColor: AppColors.getError(widget.isDark),
        ),
      );
      return;
    }

    // Other reason text is now optional, no validation needed
    final reasonToReturn =
        selectedReason == 'other' && _otherReasonController.text.isNotEmpty
        ? _otherReasonController.text
        : selectedReason;

    Navigator.pop(context, reasonToReturn);
  }
}

// RefundMethodDialog - With proper background
class RefundMethodDialog extends StatelessWidget {
  final bool isDark;

  const RefundMethodDialog({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
                decoration: BoxDecoration(
                  color: AppColors.getTextSecondary(isDark).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.getPrimary(isDark),
                  size: AppSizes.iconLarge,
                ),
                title: Text(
                  'Refund to Wallet (Instant)',
                  style: AppTextStyles.bodyLarge(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Amount credited immediately',
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                onTap: () => Navigator.pop(context, 'wallet'),
              ),
              Divider(
                indent: 50,
                endIndent: 20,
                color: AppColors.getBorder(isDark),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.getPrimary(isDark),
                  size: AppSizes.iconLarge,
                ),
                title: Text(
                  'Refund to Bank (5-7 days)',
                  style: AppTextStyles.bodyLarge(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Via Razorpay',
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                onTap: () => Navigator.pop(context, 'bank'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
