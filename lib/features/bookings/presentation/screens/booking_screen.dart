import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/bookings/presentation/widgets/razorpay_payment_widget.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/email/services/email_services.dart';

final bookingFormProvider =
    StateNotifierProvider.autoDispose<BookingFormNotifier, BookingFormState>(
      (ref) => BookingFormNotifier(),
    );

class BookingFormState {
  final String selectedCategory;
  final int quantity;

  BookingFormState({required this.selectedCategory, this.quantity = 1});

  BookingFormState copyWith({String? selectedCategory, int? quantity}) {
    return BookingFormState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      quantity: quantity ?? this.quantity,
    );
  }
}

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(BookingFormState(selectedCategory: ''));

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category, quantity: 1);
  }

  void setQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }
}

class BookingScreen extends ConsumerWidget {
  final String eventId;

  const BookingScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final eventAsync = ref.watch(approvedEventsStreamProvider);
    final bookingState = ref.watch(bookingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Tickets',
          style: AppTextStyles.headingMedium(isDark: isDark),
        ),
        backgroundColor: AppColors.getPrimary(isDark),
        elevation: 0,
      ),
      body: eventAsync.when(
        data: (events) {
          EventEntity? event;
          try {
            event = events.firstWhere((event) => event.id == eventId);
          } catch (e) {
            return _buildErrorUI(context, isDark, 'Event not found');
          }

          return _buildBookingContent(
            context,
            ref,
            event,
            isDark,
            bookingState,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _buildErrorUI(context, isDark, 'Error loading event', error),
      ),
    );
  }

  Widget _buildErrorUI(
    BuildContext context,
    bool isDark,
    String message, [
    dynamic error,
  ]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_rounded,
            size: AppSizes.iconXxl * 2,
            color: AppColors.getError(isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge.h),
          Text(message, style: AppTextStyles.headingSmall(isDark: isDark)),
          if (error != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium.h),
              child: Text(
                error is Failure ? error.message : error.toString(),
                style: AppTextStyles.bodyMedium(isDark: isDark),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
              ),
            ),
            child: Text(
              'Go Back',
              style: AppTextStyles.labelMedium(
                isDark: isDark,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingContent(
    BuildContext context,
    WidgetRef ref,
    EventEntity event,
    bool isDark,
    AsyncValue<BookingEntity?> bookingState,
  ) {
    final formState = ref.watch(bookingFormProvider);
    final formNotifier = ref.read(bookingFormProvider.notifier);
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.uid ?? '';
    final isOrganizer = userId == event.organizerId;

    // Initialize booking form state
    final validCategories = event.categoryPrices.entries
        .where(
          (entry) =>
              entry.value > 0 && event.categoryCapacities[entry.key]! > 0,
        )
        .map((entry) => entry.key)
        .toList();

    if (validCategories.isEmpty) {
      return _buildErrorUI(context, isDark, 'No ticket categories available');
    }

    if (!validCategories.contains(formState.selectedCategory)) {
      Future.microtask(() => formNotifier.setCategory(validCategories.first));
    }

    final selectedCategory =
        validCategories.contains(formState.selectedCategory)
        ? formState.selectedCategory
        : validCategories.first;
    final totalAmount =
        event.categoryPrices[selectedCategory]! * formState.quantity;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Event Header
          Container(
            color: AppColors.getPrimary(isDark).withOpacity(0.1),
            padding: EdgeInsets.all(AppSizes.paddingMedium.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.headingMedium(
                    isDark: isDark,
                  ).copyWith(fontSize: AppSizes.fontDisplay3.sp),
                ),
                SizedBox(height: AppSizes.spacingSmall.h),
                Text(
                  'Organized by: ${event.organizerName}',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
                if (isOrganizer)
                  Padding(
                    padding: EdgeInsets.only(top: AppSizes.spacingSmall.h),
                    child: Text(
                      'You are the organizer of this event',
                      style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                        color: AppColors.getPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Event Card
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium.w),
            child: Card(
              color: AppColors.getCard(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
              ),
              elevation: AppSizes.cardElevationMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusMedium.r),
                    ),
                    child: event.imageUrl != null
                        ? Image.network(
                            event.imageUrl!,
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 180.h,
                                  color: AppColors.getSurface(isDark),
                                  child: Icon(
                                    Icons.event,
                                    size: AppSizes.iconXxl,
                                    color: AppColors.getTextSecondary(isDark),
                                  ),
                                ),
                          )
                        : Container(
                            height: 180.h,
                            color: AppColors.getSurface(isDark),
                            child: Icon(
                              Icons.event,
                              size: AppSizes.iconXxl,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Details',
                          style: AppTextStyles.headingSmall(isDark: isDark),
                        ),
                        SizedBox(height: AppSizes.spacingSmall.h),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: DateFormat(
                            'EEEE, MMMM d, y',
                          ).format(event.startTime),
                          isDark: isDark,
                        ),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Time',
                          value:
                              '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                          isDark: isDark,
                        ),
                        _buildDetailRow(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: event.location,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ticket Selection Card
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium.w,
              vertical: AppSizes.spacingMedium.h,
            ),
            child: Card(
              color: AppColors.getCard(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
              ),
              elevation: AppSizes.cardElevationMedium,
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Tickets',
                      style: AppTextStyles.headingSmall(isDark: isDark),
                    ),
                    SizedBox(height: AppSizes.spacingMedium.h),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Ticket Type',
                        labelStyle: AppTextStyles.bodyMedium(isDark: isDark),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall.r,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.getSurface(isDark),
                      ),
                      items: validCategories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                '${category.toUpperCase()} - ₹${event.categoryPrices[category]!.toStringAsFixed(2)} (Available: ${event.categoryCapacities[category]})',
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          formNotifier.setCategory(value);
                        }
                      },
                    ),
                    SizedBox(height: AppSizes.spacingMedium.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity',
                          style: AppTextStyles.bodyMedium(isDark: isDark),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              onPressed: formState.quantity > 1
                                  ? () => formNotifier.setQuantity(
                                      formState.quantity - 1,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingSmall.w,
                                vertical: AppSizes.paddingXs.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.getBorder(isDark),
                                  width: AppSizes.borderWidthThin,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSmall.r,
                                ),
                              ),
                              child: Text(
                                '${formState.quantity}',
                                style: AppTextStyles.bodyLarge(isDark: isDark),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              onPressed:
                                  formState.quantity <
                                      event
                                          .categoryCapacities[selectedCategory]!
                                  ? () => formNotifier.setQuantity(
                                      formState.quantity + 1,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacingMedium.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: AppTextStyles.bodyLarge(
                            isDark: isDark,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyLarge(
                            isDark: isDark,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Payment Button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium.w,
              vertical: AppSizes.spacingLarge.h,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightLarge.h,
              child: RazorpayPaymentWidget(
                amount: totalAmount,
                onSuccess: (paymentId) async {
                  final user = FirebaseAuth.instance.currentUser;
                  print('Current user: ${user?.uid}');
                  print('User authenticated: ${user != null}');
                  print('Booking userId: $userId');
                  print('Match: ${user?.uid == userId}');
                  if (userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please log in to book tickets',
                          style: AppTextStyles.bodyMedium(
                            isDark: true,
                          ).copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.getError(isDark),
                      ),
                    );
                    return;
                  }

                  final booking = BookingEntity(
                    id: '',
                    userId: userId,
                    eventId: event.id,
                    ticketType: selectedCategory,
                    ticketQuantity: formState.quantity,
                    totalAmount: totalAmount,
                    paymentId: paymentId,
                    seatNumbers: [],
                    bookingDate: DateTime.now(),
                    startTime: event.startTime,
                    endTime: event.endTime,
                    status: 'confirmed',
                    userEmail: user?.email ?? '',
                  );

                  try {
                    await ref
                        .read(bookingNotifierProvider.notifier)
                        .bookTicket(booking, paymentId);


                    final bookingState = ref.read(bookingNotifierProvider);
                    bookingState.when(
                      data: (bookingResult) {
                        if (bookingResult != null) {
                          // Send invoice email with confirmed booking id
                          () async {
                            try {
                              await EmailService.sendInvoice(
                                userId,
                                bookingResult.id,
                                totalAmount,
                                user?.email ?? '',
                              );
                            } catch (_) {}
                          }();
                          ref.invalidate(userBookingsProvider(userId));
                          context.go(
                            '/booking-details',
                            extra: {'booking': bookingResult, 'event': event},
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Booking failed: No booking data returned',
                                style: AppTextStyles.bodyMedium(
                                  isDark: true,
                                ).copyWith(color: Colors.white),
                              ),
                              backgroundColor: AppColors.getError(isDark),
                            ),
                          );
                        }
                      },
                      error: (error, stack) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Booking failed: ${error is Failure ? error.message : error.toString()}',
                              style: AppTextStyles.bodyMedium(
                                isDark: true,
                              ).copyWith(color: Colors.white),
                            ),
                            backgroundColor: AppColors.getError(isDark),
                          ),
                        );
                      },
                      loading: () {},
                    );
                  } catch (e, stackTrace) {
                    print('Booking error in UI: $e\n$stackTrace');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Booking failed: $e',
                          style: AppTextStyles.bodyMedium(
                            isDark: true,
                          ).copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.getError(isDark),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          // Booking State Feedback
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
            child: bookingState.when(
              data: (booking) => booking != null
                  ? Text(
                      'Processing booking...',
                      style: AppTextStyles.bodyMedium(
                        isDark: isDark,
                      ).copyWith(color: AppColors.getSuccess(isDark)),
                    )
                  : const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error: ${error is Failure ? error.message : error.toString()}',
                style: AppTextStyles.bodyMedium(
                  isDark: isDark,
                ).copyWith(color: AppColors.getError(isDark)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingSmall.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconMedium.sp,
            color: AppColors.getPrimary(isDark),
          ),
          SizedBox(width: AppSizes.spacingMedium.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall(isDark: isDark)),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
