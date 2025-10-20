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
  @override
  void initState() {
    super.initState();
    //Initialize provider with fresh state
    ref.read(cancellationProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    
    return FutureBuilder(
      future: di.sl<GetBookingUseCase>()(widget.bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingScaffold(isDark);
        }
        
        final bookingEither = snapshot.data!;
        return bookingEither.fold(
          (failure) => _buildErrorScaffold(failure.message, isDark),
          (booking) => _buildMainContent(booking, isDark),
        );
      },
    );
  }

  Widget _buildLoadingScaffold(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cancel Booking', style: AppTextStyles.headingMedium(isDark: isDark)),
        backgroundColor: AppColors.getPrimary(isDark),
      ),
      body: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildErrorScaffold(String message, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cancel Booking', style: AppTextStyles.headingMedium(isDark: isDark)),
        backgroundColor: AppColors.getPrimary(isDark),
      ),
      body: Center(child: Text(message, style: AppTextStyles.bodyMedium(isDark: isDark))),
    );
  }

  Widget _buildMainContent(dynamic booking, bool isDark) {
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
            _buildPolicySection(isDark),
            if (!eligible) 
              _buildIneligibleSection(isDark)
            else 
              _buildCancellationForm(isDark),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cancellation Policy', style: AppTextStyles.headingSmall(isDark: isDark)),
        SizedBox(height: AppSizes.spacingSmall.h),
        Text(
          'Cancellations are allowed only before 48 hours of event start time.',
          style: AppTextStyles.bodyMedium(isDark: isDark),
        ),
        SizedBox(height: AppSizes.spacingLarge.h),
      ],
    );
  }

  Widget _buildIneligibleSection(bool isDark) {
    return Container(
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
    );
  }

  Widget _buildCancellationForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReasonSection(isDark),
        _buildRefundSection(isDark),
        _buildConfirmButton(isDark),
        SizedBox(height: AppSizes.spacingLarge.h),
      ],
    );
  }

  Widget _buildReasonSection(bool isDark) {
    final state = ref.watch(cancellationProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reason for cancellation', style: AppTextStyles.headingSmall(isDark: isDark)),
        SizedBox(height: AppSizes.spacingSmall.h),
        ...[
          'Ordered by mistake',
          'Can\'t attend the event',
          'Event rescheduled',
          'Found a better alternative',
          'Other',
        ].map((reason) => RadioListTile<String>(
              value: reason,
              groupValue: state.reason,
              onChanged: (value) {
                ref.read(cancellationProvider.notifier).setReason(value); //Riverpod
              },
              title: Text(reason, style: AppTextStyles.bodyMedium(isDark: isDark)),
              activeColor: AppColors.getPrimary(isDark),
              contentPadding: EdgeInsets.zero,
            )),
        //Other reason input - Riverpod managed
        if (state.reason == 'Other') ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
            child: TextField(
              controller: TextEditingController(text: state.notes), //Riverpod state
              maxLines: 3,
              onChanged: (value) {
                ref.read(cancellationProvider.notifier).setNotes(value); //Riverpod
              },
              decoration: InputDecoration(
                labelText: 'Enter reason',
                labelStyle: AppTextStyles.bodyMedium(isDark: isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                  borderSide: BorderSide(color: AppColors.getPrimary(isDark), width: 2),
                ),
                contentPadding: EdgeInsets.all(AppSizes.paddingSmall.w),
              ),
              style: AppTextStyles.bodyMedium(isDark: isDark),
            ),
          ),
        ],
        SizedBox(height: AppSizes.spacingLarge.h),
      ],
    );
  }

  Widget _buildRefundSection(bool isDark) {
    final state = ref.watch(cancellationProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Refund Method', style: AppTextStyles.headingSmall(isDark: isDark)),
        RadioListTile<String>(
          value: 'wallet',
          groupValue: state.refundType,
          onChanged: (value) {
            ref.read(cancellationProvider.notifier).setRefundType(value); //Riverpod
          },
          title: Text('Refund to Wallet (Instant)', style: AppTextStyles.bodyMedium(isDark: isDark)),
          activeColor: AppColors.getPrimary(isDark),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          value: 'bank',
          groupValue: state.refundType,
          onChanged: (value) {
            ref.read(cancellationProvider.notifier).setRefundType(value); //Riverpod
          },
          title: Text('Refund to Bank (5-7 days)', style: AppTextStyles.bodyMedium(isDark: isDark)),
          activeColor: AppColors.getPrimary(isDark),
          contentPadding: EdgeInsets.zero,
        ),
        SizedBox(height: AppSizes.spacingLarge.h),
      ],
    );
  }

  Widget _buildConfirmButton(bool isDark) {
    final state = ref.watch(cancellationProvider);
    
    //Riverpod validation logic
    final isFormValid = _isFormValid(state);
    final finalReason = _getFinalReason(state);
    
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeightLarge.h,
      child: ElevatedButton(
        onPressed: isFormValid
            ? () => _handleCancellation(context, state, finalReason, isDark)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimary(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
          ),
          elevation: 2,
        ),
        child: Text(
          'Confirm Cancellation',
          style: AppTextStyles.labelMedium(isDark: isDark)
              .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  bool _isFormValid(CancellationState state) {
    return state.reason != null && state.refundType != null;
  }

  String? _getFinalReason(CancellationState state) {
    if (state.reason == 'Other') {
      return state.notes.trim().isNotEmpty ? state.notes.trim() : null;
    }
    return state.reason;
  }

  void _handleCancellation(BuildContext context, CancellationState state, String? finalReason, bool isDark) {
    if (finalReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a reason for cancellation.'),
          backgroundColor: AppColors.getError(isDark),
        ),
      );
      return;
    }

    //Same cancellation logic
    final notifier = ref.read(bookingNotifierProvider.notifier);
    // await notifier.cancelBooking(
    //   booking.id,
    //   booking.paymentId,
    //   booking.eventId,
    //   refundType: state.refundType!,
    //   reason: finalReason,
    // );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cancellation requested. Refund will be processed to ${state.refundType}.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.getSuccess(isDark),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }
}