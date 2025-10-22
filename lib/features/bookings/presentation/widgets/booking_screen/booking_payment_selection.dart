import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_form_provider.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/bookings/presentation/widgets/razorpay_payment_widget.dart';
import 'package:sync_event/features/email/services/email_services.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class BookingPaymentSection extends ConsumerWidget {
  final EventEntity event;
  final bool isDark;
  final AsyncValue<BookingEntity?> bookingState;

  const BookingPaymentSection({
    super.key,
    required this.event,
    required this.isDark,
    required this.bookingState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(bookingFormProvider);
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.uid ?? '';
    final userEmail = authState.user?.email ?? '';

    final validCategories = event.categoryPrices.entries
        .where(
          (entry) =>
              entry.value > 0 && event.categoryCapacities[entry.key]! > 0,
        )
        .map((entry) => entry.key)
        .toList();

    final selectedCategory =
        validCategories.contains(formState.selectedCategory)
        ? formState.selectedCategory
        : (validCategories.isNotEmpty ? validCategories.first : '');

    final price = event.categoryPrices[selectedCategory];
    final totalAmount = (price != null) ? price * formState.quantity : 0.0;

    return Column(
      children: [
        _buildPaymentButton(
          context,
          ref,
          userId,
          userEmail,
          totalAmount,
          selectedCategory,
          formState,
        ),
        SizedBox(height: AppSizes.spacingLarge.h),
        _buildPaymentStatus(),
      ],
    );
  }

  Widget _buildPaymentButton(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String userEmail,
    double totalAmount,
    String selectedCategory,
    BookingFormState formState,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDark).withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeightLarge.h,
        child: RazorpayPaymentWidget(
          amount: totalAmount,
          onSuccess: (paymentId) => _handlePaymentSuccess(
            context,
            ref,
            userId,
            userEmail,
            selectedCategory,
            formState,
            totalAmount,
            paymentId,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePaymentSuccess(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String userEmail,
    String selectedCategory,
    BookingFormState formState,
    double totalAmount,
    String paymentId,
  ) async {
    if (userId.isEmpty) {
      _showErrorSnackBar(context, 'Please log in to book tickets');
      return;
    }

    try {
      await ref
          .read(bookingNotifierProvider.notifier)
          .bookTicket(
            eventId: event.id,
            userId: userId,
            ticketType: selectedCategory,
            ticketQuantity: formState.quantity,
            totalAmount: totalAmount,
            paymentId: paymentId,
            startTime: event.startTime,
            endTime: event.endTime,
            seatNumbers: const [],
            userEmail: userEmail,
          );

      final bookingResult = ref.read(bookingNotifierProvider);
      bookingResult.whenData((booking) async {
        if (booking != null) {
          try {
            await EmailService.sendInvoice(
              userId,
              booking.id,
              totalAmount,
              userEmail,
            );
          } catch (_) {}

          ref.invalidate(userBookingsProvider(userId));
          context.go(
            '/booking-details',
            extra: {'booking': booking, 'event': event},
          );
        }
      });
    } catch (e) {
      _showErrorSnackBar(context, 'Booking failed: $e');
    }
  }

  Widget _buildPaymentStatus() {
    return bookingState.when(
      data: (booking) =>
          booking != null ? _buildSuccessStatus() : const SizedBox.shrink(),
      loading: () => _buildLoadingStatus(),
      error: (error, stack) => _buildErrorStatus(error),
    );
  }

  Widget _buildSuccessStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: AppColors.getSuccess(isDark),
          size: AppSizes.iconMedium.sp,
        ),
        SizedBox(width: AppSizes.spacingSmall.w),
        Text(
          'Processing booking...',
          style: AppTextStyles.bodyMedium(
            isDark: isDark,
          ).copyWith(color: AppColors.getSuccess(isDark)),
        ),
      ],
    );
  }

  Widget _buildLoadingStatus() {
    return Shimmer.fromColors(
      baseColor: AppColors.getSurface(isDark),
      highlightColor: AppColors.getBorder(isDark).withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: AppSizes.spacingMedium.w),
          Container(
            width: 150.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(dynamic error) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium.w),
      decoration: BoxDecoration(
        color: AppColors.getError(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
        border: Border.all(color: AppColors.getError(isDark).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_rounded, color: AppColors.getError(isDark)),
          SizedBox(width: AppSizes.spacingMedium.w),
          Expanded(
            child: Text(
              'Error: ${error is Failure ? error.message : error.toString()}',
              style: AppTextStyles.bodySmall(
                isDark: isDark,
              ).copyWith(color: AppColors.getError(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium(
            isDark: true,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.getError(isDark),
      ),
    );
  }
}
