import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/bookings/presentation/utils/booking_utils.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;
import 'package:sync_event/features/bookings/domain/usecases/get_booking_usecase.dart';

class CancellationScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const CancellationScreen({super.key, required this.bookingId});

  @override
  ConsumerState<CancellationScreen> createState() => _CancellationScreenState();
}

class _CancellationScreenState extends ConsumerState<CancellationScreen> {
  String? _reason;
  String? _refundType;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    return FutureBuilder(
      future: di.sl<GetBookingUseCase>()(widget.bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Cancel Booking', style: AppTextStyles.headingMedium(isDark: isDark)),
              backgroundColor: AppColors.getPrimary(isDark),
            ),
            body: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        final bookingEither = snapshot.data!;
        return bookingEither.fold(
          (failure) => Scaffold(
            appBar: AppBar(
              title: Text('Cancel Booking', style: AppTextStyles.headingMedium(isDark: isDark)),
              backgroundColor: AppColors.getPrimary(isDark),
            ),
            body: Center(child: Text(failure.message, style: AppTextStyles.bodyMedium(isDark: isDark))),
          ),
          (booking) {
            final eligible = BookingUtils.isEligibleForCancellation(booking.startTime);
            return Scaffold(
              appBar: AppBar(
                title: Text('Cancel Booking', style: AppTextStyles.headingMedium(isDark: isDark)),
                backgroundColor: AppColors.getPrimary(isDark),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cancellation Policy', style: AppTextStyles.headingSmall(isDark: isDark)),
                    SizedBox(height: AppSizes.spacingSmall.h),
                    Text(
                      'Cancellations are allowed only before 48 hours of event start time.',
                      style: AppTextStyles.bodyMedium(isDark: isDark),
                    ),
                    SizedBox(height: AppSizes.spacingLarge.h),
                    if (!eligible) ...[
                      Container(
                        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                        decoration: BoxDecoration(
                          color: AppColors.getError(isDark).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                        ),
                        child: Text(
                          'This booking cannot be cancelled because it is within 48 hours of the event start.',
                          style: AppTextStyles.bodyMedium(isDark: isDark)
                              .copyWith(color: AppColors.getError(isDark)),
                        ),
                      ),
                    ] else ...[
                      Text('Reason for cancellation', style: AppTextStyles.headingSmall(isDark: isDark)),
                      SizedBox(height: AppSizes.spacingSmall.h),
                      ...[
                        'Ordered by mistake',
                        'Can\'t attend the event',
                        'Event rescheduled',
                        'Found a better alternative',
                        'Other',
                      ].map((r) => RadioListTile<String>(
                            value: r,
                            groupValue: _reason,
                            onChanged: (v) => setState(() => _reason = v),
                            title: Text(r),
                          )),
                      if (_reason == 'Other')
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Enter reason',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: AppSizes.spacingLarge.h),
                      Text('Refund Method', style: AppTextStyles.headingSmall(isDark: isDark)),
                      RadioListTile<String>(
                        value: 'wallet',
                        groupValue: _refundType,
                        onChanged: (v) => setState(() => _refundType = v),
                        title: const Text('Refund to Wallet (Instant)'),
                      ),
                      RadioListTile<String>(
                        value: 'bank',
                        groupValue: _refundType,
                        onChanged: (v) => setState(() => _refundType = v),
                        title: const Text('Refund to Bank (5-7 days)'),
                      ),
                      SizedBox(height: AppSizes.spacingLarge.h),
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeightLarge.h,
                        child: ElevatedButton(
                          onPressed: (_reason != null && _refundType != null)
                              ? () async {
                                  final reason = _reason == 'Other'
                                      ? _notesController.text.isNotEmpty
                                          ? _notesController.text
                                          : null
                                      : _reason;
                                  if (reason == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please provide a reason for cancellation.'),
                                        backgroundColor: AppColors.getError(isDark),
                                      ),
                                    );
                                    return;
                                  }
                                  final notifier = ref.read(bookingNotifierProvider.notifier);
                                  await notifier.cancelBooking(
                                    booking.id,
                                    booking.paymentId,
                                    booking.eventId,
                                    refundType: _refundType!,
                                    reason: reason,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Cancellation requested. Refund will be processed to $_refundType.',
                                          style: AppTextStyles.bodyMedium(isDark: true)
                                              .copyWith(color: Colors.white),
                                        ),
                                        backgroundColor: AppColors.getSuccess(isDark),
                                      ),
                                    );
                                    context.pop();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.getPrimary(isDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                            ),
                          ),
                          child: Text(
                            'Confirm Cancellation',
                            style: AppTextStyles.labelMedium(isDark: isDark)
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}