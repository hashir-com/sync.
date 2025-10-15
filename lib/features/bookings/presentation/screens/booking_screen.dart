import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/bookings/presentation/widgets/razorpay_payment_widget.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/core/error/failures.dart'; 

class BookingScreen extends ConsumerWidget {
  final String eventId;

  const BookingScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    // Keep the AsyncValue wrapper - don't unwrap with .value
    final eventAsync = ref.watch(approvedEventsStreamProvider);
    final bookingState = ref.watch(bookingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Tickets', style: AppTextStyles.headingMedium(isDark: isDark)),
        backgroundColor: AppColors.getPrimary(isDark),
      ),
      body: eventAsync.when(
        data: (events) {
          try {
            final event = events.firstWhere(
              (event) => event.id == eventId,
              orElse: () => throw Exception('Event not found'),
            );
            return _buildBookingForm(context, ref, event, isDark, bookingState);
          } catch (e) {
            return Center(
              child: Text(
                'Event not found',
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: ${error is Failure ? error.message : error.toString()}',
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingForm(BuildContext context, WidgetRef ref, EventEntity event, bool isDark,
      AsyncValue<BookingEntity?> bookingState) {
    int quantity = 1;
    String selectedCategory = event.categoryPrices.keys.firstWhere((key) => event.categoryPrices[key]! > 0,
        orElse: () => event.categoryPrices.keys.first);
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.uid ?? '';
    final userEmail = authState.user?.email ?? '';

    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingXl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Tickets', style: AppTextStyles.headingSmall(isDark: isDark)),
          SizedBox(height: AppSizes.spacingLarge.h),
          DropdownButton<String>(
            value: selectedCategory,
            items: event.categoryPrices.entries
                .where((entry) => entry.value > 0)
                .map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.key, style: AppTextStyles.bodyMedium(isDark: isDark)),
                    ))
                .toList(),
            onChanged: (value) => selectedCategory = value!,
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: AppColors.getTextSecondary(isDark)),
                onPressed: quantity > 1 && event.categoryCapacities[selectedCategory]! > 0
                    ? () => quantity--
                    : null,
              ),
              Text('$quantity', style: AppTextStyles.bodyLarge(isDark: isDark)),
              IconButton(
                icon: Icon(Icons.add, color: AppColors.getTextSecondary(isDark)),
                onPressed: quantity < event.categoryCapacities[selectedCategory]!
                    ? () => quantity++
                    : null,
              ),
              Text(
                'Total: ₹${(event.categoryPrices[selectedCategory]! * quantity).toStringAsFixed(2)}',
                style: AppTextStyles.bodyLarge(isDark: isDark),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingXxl.h),
          RazorpayPaymentWidget(
            amount: event.categoryPrices[selectedCategory]! * quantity,
            onSuccess: () {
              if (userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please log in to book tickets',
                        style: AppTextStyles.bodyMedium(isDark: true).copyWith(color: Colors.white)),
                  ),
                );
                return;
              }
              final booking = BookingEntity(
                id: '', // Will be set by Firestore
                userId: userId,
                eventId: event.id,
                ticketType: selectedCategory,
                ticketQuantity: quantity,
                totalAmount: event.categoryPrices[selectedCategory]! * quantity,
                paymentId: '', // Set by Razorpay callback
                bookingDate: DateTime.now(),
                startTime: event.startTime,
                endTime: event.endTime,
              );
              ref.read(bookingNotifierProvider.notifier).bookTicket(booking);
              context.pop(); // Return to event detail
            },
          ),
          if (bookingState.hasValue || bookingState.hasError)
            bookingState.when(
              data: (booking) => booking != null
                  ? Text(
                      'Booking Confirmed: ${booking.id}',
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(color: AppColors.getSuccess(isDark)),
                    )
                  : const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text(
                'Error: ${error is Failure ? error.message : error.toString()}',
                style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(color: AppColors.getError(isDark)),
              ),
            ),
        ],
      ),
    );
  }
}