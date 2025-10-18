// lib/features/bookings/presentation/screens/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/bookings/presentation/utils/booking_utils.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: AppTextStyles.headingMedium(isDark: isDark),
        ),
        backgroundColor: AppColors.getPrimary(isDark),
        elevation: 0,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildNotAuthenticatedUI(context, isDark);
          }
          return _buildUserBookingsView(context, ref, user.uid, isDark);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stack) =>
            _buildErrorUI(context, isDark, 'Error loading user data', error),
      ),
    );
  }

  Widget _buildNotAuthenticatedUI(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: AppSizes.iconXxl.sp,
            color: AppColors.getTextSecondary(isDark),
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          Text(
            'Please log in',
            style: AppTextStyles.headingSmall(isDark: isDark),
          ),
          Text(
            'You need to be logged in to view your bookings',
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge.h),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
              ),
            ),
            child: Text(
              'Go to Login',
              style: AppTextStyles.labelMedium(
                isDark: isDark,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBookingsView(
    BuildContext context,
    WidgetRef ref,
    String userId,
    bool isDark,
  ) {
    final bookingsAsync = ref.watch(userBookingsProvider(userId));

    return bookingsAsync.when(
      data: (bookings) =>
          _buildBookingsList(context, ref, bookings, isDark, userId),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) =>
          _buildErrorUI(context, isDark, 'Error loading bookings', error),
    );
  }

  Widget _buildBookingsList(
    BuildContext context,
    WidgetRef ref,
    List<BookingEntity> bookings,
    bool isDark,
    String userId,
  ) {
    // Local state for search and filters
    final searchController = TextEditingController();
    String statusFilter = 'all';
    DateTimeRange? dateFilter;

    List<BookingEntity> applyFilters() {
      final query = searchController.text.toLowerCase();
      return bookings.where((b) {
        final matchesStatus = statusFilter == 'all' || b.status == statusFilter;
        final matchesDate = dateFilter == null ||
            (b.startTime.isAfter(dateFilter!.start.subtract(const Duration(days: 1))) &&
                b.startTime.isBefore(dateFilter!.end.add(const Duration(days: 1))));
        final matchesSearch = b.id.toLowerCase().contains(query) ||
            b.ticketType.toLowerCase().contains(query) ||
            b.paymentId.toLowerCase().contains(query);
        return matchesStatus && matchesDate && matchesSearch;
      }).toList();
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: AppSizes.iconXxl.sp,
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(height: AppSizes.spacingMedium.h),
            Text(
              'No bookings yet',
              style: AppTextStyles.headingSmall(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingSmall.h),
            Text(
              'Book your first event now!',
              style: AppTextStyles.bodyMedium(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingLarge.h),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                ),
              ),
              child: Text(
                'Browse Events',
                style: AppTextStyles.labelMedium(
                  isDark: isDark,
                ).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // Header with search and filters
    return StatefulBuilder(
      builder: (context, setState) {
        final filtered = applyFilters();
        return ListView(
          padding: EdgeInsets.all(AppSizes.paddingMedium.w),
          children: [
            Card(
              color: AppColors.getCard(isDark),
              elevation: AppSizes.cardElevationMedium,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search by ID, type, payment ID',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: AppSizes.spacingSmall.h),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: statusFilter,
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All')),
                              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                              DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                            ],
                            onChanged: (v) => setState(() => statusFilter = v ?? 'all'),
                            decoration: const InputDecoration(labelText: 'Status'),
                          ),
                        ),
                        SizedBox(width: AppSizes.spacingSmall.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDateRange: dateFilter,
                              );
                              setState(() => dateFilter = picked);
                            },
                            icon: const Icon(Icons.date_range),
                            label: Text(dateFilter == null
                                ? 'Filter by date'
                                : '${DateFormat('MMM d').format(dateFilter!.start)} - ${DateFormat('MMM d').format(dateFilter!.end)}'),
                          ),
                        ),
                        if (dateFilter != null)
                          IconButton(
                            tooltip: 'Clear date',
                            onPressed: () => setState(() => dateFilter = null),
                            icon: const Icon(Icons.clear),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium.h),
            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                  child: Text(
                    'No bookings match your filters',
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                ),
              )
            else
              ...filtered.map(
                (booking) => _buildBookingCard(
                  context,
                  ref,
                  booking,
                  isDark,
                  userId,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref,
    BookingEntity booking,
    bool isDark,
    String userId,
  ) {
    // Create a placeholder event
    final placeholderEvent = EventEntity(
      id: booking.eventId,
      title: 'Event Not Found',
      description: 'Event details unavailable',
      location: 'Unknown',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      organizerId: 'unknown',
      organizerName: 'Unknown Organizer',
      maxAttendees: 0,
      category: 'unknown',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final eventStream = ref.watch(approvedEventsStreamProvider);

    return eventStream.when(
      data: (events) {
        EventEntity event = placeholderEvent;

        try {
          if (events.isNotEmpty) {
            final foundEvent = events.firstWhere(
              (e) => e.id == booking.eventId,
            );
            // Handle type conversion if needed
            if (foundEvent is EventEntity) {
              event = foundEvent;
            }
          }
        } catch (e) {
          print('Event not found for booking ${booking.id}: $e');
          event = placeholderEvent;
        }

        return Card(
          elevation: AppSizes.cardElevationMedium,
          color: AppColors.getCard(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
          ),
          margin: EdgeInsets.only(bottom: AppSizes.spacingMedium.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
            onTap: () => context.push(
              '/booking-details',
              extra: {'booking': booking, 'event': event},
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image and Basic Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall.r,
                        ),
                        child: event.imageUrl != null
                            ? Image.network(
                                event.imageUrl!,
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(isDark),
                              )
                            : _buildImagePlaceholder(isDark),
                      ),
                      SizedBox(width: AppSizes.spacingMedium.w),
                      // Event Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: AppTextStyles.titleMedium(isDark: isDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizes.spacingXs.h),
                            Text(
                              event.organizerName,
                              style: AppTextStyles.bodySmall(isDark: isDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizes.spacingSmall.h),
                            _buildStatusBadge(booking.status, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingMedium.h),
                  // Event Date and Time
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: DateFormat('MMM d, y').format(booking.startTime),
                    isDark: isDark,
                  ),
                  SizedBox(height: AppSizes.spacingSmall.h),
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: DateFormat('h:mm a').format(booking.startTime),
                    isDark: isDark,
                  ),
                  SizedBox(height: AppSizes.spacingSmall.h),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: event.location,
                    isDark: isDark,
                  ),
                  SizedBox(height: AppSizes.spacingMedium.h),
                  // Ticket and Amount Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket Type',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                          Text(
                            '${booking.ticketType.toUpperCase()} × ${booking.ticketQuantity}',
                            style: AppTextStyles.bodyMedium(
                              isDark: isDark,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                          Text(
                            '₹${booking.totalAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium(isDark: isDark)
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getPrimary(isDark),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (booking.seatNumbers.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spacingMedium.h),
                    Text(
                      'Seats',
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    SizedBox(height: AppSizes.spacingXs.h),
                    Wrap(
                      spacing: AppSizes.spacingSmall.w,
                      children: booking.seatNumbers
                          .map(
                            (seat) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingSmall.w,
                                vertical: AppSizes.paddingXs.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.getPrimary(
                                  isDark,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSmall.r,
                                ),
                              ),
                              child: Text(
                                '$seat',
                                style: AppTextStyles.labelSmall(
                                  isDark: isDark,
                                ).copyWith(color: AppColors.getPrimary(isDark)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (booking.status == 'confirmed') ...[
                    SizedBox(height: AppSizes.spacingMedium.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final eligible = BookingUtils.isEligibleForCancellation(booking.startTime);
                          if (!eligible) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cannot cancel within 48 hours of event start.',
                                    style: AppTextStyles.bodyMedium(isDark: true)
                                        .copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.getError(isDark),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                            return;
                          }
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Cancel Booking?'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Choose your refund method:'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Keep'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Refund to Wallet'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, null),
                                  child: const Text('Refund to Bank'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != null) {
                            try {
                              await ref
                                  .read(bookingNotifierProvider.notifier)
                                  .cancelBooking(
                                    booking.id,
                                    booking.paymentId,
                                    booking.eventId,
                                    refundType: confirmed ? 'wallet' : 'bank',
                                  );
                              ref.invalidate(userBookingsProvider(userId));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Booking cancelled successfully',
                                      style: AppTextStyles.bodyMedium(
                                        isDark: true,
                                      ).copyWith(color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.getSuccess(
                                      isDark,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error cancelling booking: $e',
                                      style: AppTextStyles.bodyMedium(
                                        isDark: true,
                                      ).copyWith(color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.getError(isDark),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getError(
                            isDark,
                          ).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSmall.r,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel Booking',
                          style: AppTextStyles.labelMedium(
                            isDark: isDark,
                          ).copyWith(color: AppColors.getError(isDark)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Card(
        color: AppColors.getCard(isDark),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium.w),
            child: const CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        color: AppColors.getCard(isDark),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium.w),
            child: Text(
              'Error loading event details',
              style: AppTextStyles.bodyMedium(isDark: isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      width: 80.w,
      height: 80.h,
      color: AppColors.getSurface(isDark),
      child: Icon(
        Icons.event,
        size: AppSizes.iconLarge.sp,
        color: AppColors.getTextSecondary(isDark),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    final isConfirmed = status == 'confirmed';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall.w,
        vertical: AppSizes.paddingXs.h,
      ),
      decoration: BoxDecoration(
        color: isConfirmed
            ? AppColors.getSuccess(isDark).withOpacity(0.1)
            : AppColors.getError(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.labelSmall(isDark: isDark).copyWith(
          color: isConfirmed
              ? AppColors.getSuccess(isDark)
              : AppColors.getError(isDark),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.iconSmall.sp,
          color: AppColors.getTextSecondary(isDark),
        ),
        SizedBox(width: AppSizes.spacingSmall.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall(isDark: isDark),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
            Icons.error_outline,
            size: AppSizes.iconXxl.sp,
            color: AppColors.getError(isDark),
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          Text(
            message,
            style: AppTextStyles.headingSmall(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          if (error != null)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSizes.spacingMedium.h,
                horizontal: AppSizes.paddingMedium.w,
              ),
              child: Text(
                error is Failure ? error.message : error.toString(),
                style: AppTextStyles.bodyMedium(isDark: isDark),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: AppSizes.spacingMedium.h),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
              ),
            ),
            child: Text(
              'Go  Back',
              style: AppTextStyles.labelMedium(
                isDark: isDark,
              ).copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
