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
import 'package:sync_event/features/bookings/presentation/utils/booking_utils.dart';
import 'package:sync_event/features/email/services/email_services.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_notifier.dart';

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
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56.h,
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
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
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
              'Please Log In',
              style: AppTextStyles.headingSmall(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingSmall.h),
            Text(
              'You need to be logged in to view your bookings',
              style: AppTextStyles.bodyMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingLarge.h),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(isDark),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge.w,
                  vertical: AppSizes.paddingMedium.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                ),
                elevation: 2,
                textStyle: AppTextStyles.labelMedium(isDark: isDark),
              ),
              child: const Text('Go to Login'),
            ),
          ],
        ),
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
        final matchesDate =
            dateFilter == null ||
            (b.startTime.isAfter(
                  dateFilter!.start.subtract(const Duration(days: 1)),
                ) &&
                b.startTime.isBefore(
                  dateFilter!.end.add(const Duration(days: 1)),
                ));
        final matchesSearch =
            b.id.toLowerCase().contains(query) ||
            b.ticketType.toLowerCase().contains(query) ||
            b.paymentId.toLowerCase().contains(query);
        return matchesStatus && matchesDate && matchesSearch;
      }).toList();
    }

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium.w),
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
                'No Bookings Yet',
                style: AppTextStyles.headingSmall(isDark: isDark),
              ),
              SizedBox(height: AppSizes.spacingSmall.h),
              Text(
                'Book your first event now!',
                style: AppTextStyles.bodyMedium(isDark: isDark),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spacingLarge.h),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(isDark),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge.w,
                    vertical: AppSizes.paddingMedium.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusMedium.r,
                    ),
                  ),
                  elevation: 2,
                  textStyle: AppTextStyles.labelMedium(isDark: isDark),
                ),
                child: const Text('Browse Events'),
              ),
            ],
          ),
        ),
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        final filtered = applyFilters();
        return ListView(
          padding: EdgeInsets.all(AppSizes.paddingMedium.w),
          children: [
            _buildFilterCard(
              context: context,
              searchController: searchController,
              statusFilter: statusFilter,
              dateFilter: dateFilter,
              isDark: isDark,
              onSearchChanged: () => setState(() {}),
              onStatusChanged: (value) =>
                  setState(() => statusFilter = value ?? 'all'),
              onDateChanged: (picked) => setState(() => dateFilter = picked),
              onClearDate: () => setState(() => dateFilter = null),
            ),
            SizedBox(height: AppSizes.spacingMedium.h),
            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                  child: Text(
                    'No bookings match your filters',
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...filtered.map(
                (booking) =>
                    _buildBookingCard(context, ref, booking, isDark, userId),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilterCard({
    required BuildContext context,
    required TextEditingController searchController,
    required String statusFilter,
    required DateTimeRange? dateFilter,
    required bool isDark,
    required VoidCallback onSearchChanged,
    required ValueChanged<String?> onStatusChanged,
    required ValueChanged<DateTimeRange?> onDateChanged,
    required VoidCallback onClearDate,
  }) {
    return Card(
      color: AppColors.getCard(isDark),
      elevation: AppSizes.cardElevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Bookings',
              style: AppTextStyles.titleMedium(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingSmall.h),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: AppSizes.iconMedium.sp,
                  color: AppColors.getTextSecondary(isDark),
                ),
                hintText: 'Search by ID, type, or payment ID',
                hintStyle: AppTextStyles.bodySmall(isDark: isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                filled: true,
                fillColor: AppColors.getSurface(isDark).withOpacity(0.5),
              ),
              style: AppTextStyles.bodyMedium(isDark: isDark),
              onChanged: (_) => onSearchChanged(),
            ),
            SizedBox(height: AppSizes.spacingMedium.h),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: statusFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(
                        value: 'confirmed',
                        child: Text('Confirmed'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                      DropdownMenuItem(
                        value: 'refunded',
                        child: Text('Refunded'),
                      ),
                    ],
                    onChanged: onStatusChanged,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: AppTextStyles.bodySmall(isDark: isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall.r,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.getSurface(isDark).withOpacity(0.5),
                    ),
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                ),
                SizedBox(width: AppSizes.spacingMedium.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange: dateFilter,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: AppColors.getPrimary(isDark),
                                brightness: isDark
                                    ? Brightness.dark
                                    : Brightness.light,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      onDateChanged(picked);
                    },
                    icon: Icon(
                      Icons.date_range,
                      size: AppSizes.iconSmall.sp,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    label: Text(
                      dateFilter == null
                          ? 'Filter by Date'
                          : '${DateFormat('MMM d').format(dateFilter.start)} - ${DateFormat('MMM d').format(dateFilter.end)}',
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.getBorder(isDark)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall.r,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSmall.w,
                        vertical: AppSizes.paddingMedium.h,
                      ),
                    ),
                  ),
                ),
                if (dateFilter != null)
                  IconButton(
                    tooltip: 'Clear date filter',
                    onPressed: onClearDate,
                    icon: Icon(
                      Icons.clear,
                      size: AppSizes.iconSmall.sp,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref,
    BookingEntity booking,
    bool isDark,
    String userId,
  ) {
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
      availableTickets: 0, // Added required availableTickets
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
            event = foundEvent;
          }
        } catch (e) {
          print('Event not found for booking ${booking.id}: $e');
        }

        return Card(
          elevation: AppSizes.cardElevationLow,
          color: AppColors.getCard(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
          ),
          margin: EdgeInsets.only(bottom: AppSizes.spacingMedium.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
            onTap: () => context.push(
              '/booking-details',
              extra: {'booking': booking, 'event': event},
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket Type',
                            style: AppTextStyles.labelSmall(isDark: isDark),
                          ),
                          SizedBox(height: AppSizes.spacingXs.h),
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
                            style: AppTextStyles.labelSmall(isDark: isDark),
                          ),
                          SizedBox(height: AppSizes.spacingXs.h),
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
                      style: AppTextStyles.labelSmall(isDark: isDark),
                    ),
                    SizedBox(height: AppSizes.spacingXs.h),
                    Wrap(
                      spacing: AppSizes.spacingSmall.w,
                      runSpacing: AppSizes.spacingXs.h,
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
                                "$seat",
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
                      child: OutlinedButton(
                        // In my_bookings_screen.dart - ONLY the cancel button section that needs fixing
                        onPressed: () async {
                          final eligible =
                              BookingUtils.isEligibleForCancellation(
                                booking.startTime,
                              );
                          if (!eligible) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cannot cancel within 48 hours of event start.',
                                    style: AppTextStyles.bodyMedium(
                                      isDark: true,
                                    ).copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.getError(isDark),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSmall.r,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          // Step 1: Show cancellation reason dialog
                          String? cancellationReason;
                          String? selectedReason;
                          final otherReasonController = TextEditingController();

                          if (context.mounted) {
                            cancellationReason = await showModalBottomSheet<String>(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setModalState) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          AppSizes.paddingMedium.w,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Why are you cancelling?',
                                              style: AppTextStyles.headingSmall(
                                                isDark: isDark,
                                              ),
                                            ),
                                            SizedBox(
                                              height: AppSizes.spacingMedium.h,
                                            ),
                                            ...[
                                              'Ordered by mistake',
                                              'Can\'t attend the event',
                                              'Event rescheduled',
                                              'Found a better alternative',
                                              'Other',
                                            ].map(
                                              (reason) => RadioListTile<String>(
                                                value: reason,
                                                groupValue: selectedReason,
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    selectedReason = value;
                                                  });
                                                },
                                                title: Text(reason),
                                              ),
                                            ),
                                            if (selectedReason == 'Other')
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      AppSizes.paddingMedium.w,
                                                ),
                                                child: TextField(
                                                  controller:
                                                      otherReasonController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Please specify',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppSizes
                                                                .radiusMedium
                                                                .r,
                                                          ),
                                                    ),
                                                  ),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            SizedBox(
                                              height: AppSizes.spacingLarge.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    'Cancel',
                                                    style:
                                                        AppTextStyles.bodyMedium(
                                                          isDark: isDark,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      AppSizes.spacingMedium.w,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (selectedReason ==
                                                        null) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            'Please select a reason.',
                                                          ),
                                                          backgroundColor:
                                                              AppColors.getError(
                                                                isDark,
                                                              ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    if (selectedReason ==
                                                            'Other' &&
                                                        otherReasonController
                                                            .text
                                                            .isEmpty) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            'Please enter a reason.',
                                                          ),
                                                          backgroundColor:
                                                              AppColors.getError(
                                                                isDark,
                                                              ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    Navigator.pop(
                                                      context,
                                                      selectedReason == 'Other'
                                                          ? otherReasonController
                                                                .text
                                                          : selectedReason,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.getPrimary(
                                                          isDark,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppSizes
                                                                .radiusLarge
                                                                .r,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Next',
                                                    style:
                                                        AppTextStyles.bodyMedium(
                                                          isDark: isDark,
                                                        ).copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }

                          if (cancellationReason == null) return;

                          // Step 2: Show refund method selection
                          String? refundType;
                          if (context.mounted) {
                            refundType = await showModalBottomSheet<String>(
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      AppSizes.paddingMedium.w,
                                    ),
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                          ),
                                          title: const Text(
                                            'Refund to Wallet (Instant)',
                                          ),
                                          subtitle: const Text(
                                            'Amount credited immediately',
                                          ),
                                          onTap: () =>
                                              Navigator.pop(context, 'wallet'),
                                        ),
                                        Divider(indent: 50.w, endIndent: 20.w),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.account_balance_outlined,
                                          ),
                                          title: const Text(
                                            'Refund to Bank (5-7 days)',
                                          ),
                                          subtitle: const Text('Via Razorpay'),
                                          onTap: () =>
                                              Navigator.pop(context, 'bank'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          if (refundType == null) return;

                          // Step 3: Process cancellation with refund
                          try {
                            print('Starting cancellation process...');
                            print('Booking ID: ${booking.id}');
                            print('User ID: $userId');
                            print('Refund Type: $refundType');
                            print('Cancellation Reason: $cancellationReason');

                            // Cancel the booking
                            await ref
                                .read(bookingNotifierProvider.notifier)
                                .cancelBooking(
                                  bookingId: booking.id,
                                  paymentId: booking.paymentId,
                                  eventId: booking.eventId,
                                  userId: userId,
                                  refundType: refundType,
                                  cancellationReason: cancellationReason,
                                );

                            // Send detailed cancellation email
                            await EmailService.sendDetailedCancellationEmail(
                              userId: userId,
                              bookingId: booking.id,
                              eventTitle: event
                                  .title, // Use event title from the event object
                              refundAmount: booking.totalAmount,
                              refundType: refundType,
                              cancellationReason: cancellationReason,
                            );

                            // Invalidate providers to refresh UI
                            ref.invalidate(userBookingsProvider(userId));
                            ref.invalidate(walletNotifierProvider);

                            if (context.mounted) {
                              final message = refundType == 'wallet'
                                  ? '✓ Booking cancelled!\n₹${booking.totalAmount.toStringAsFixed(0)} added to your wallet'
                                  : '✓ Booking cancelled!\nRefund will be processed to your bank account in 5-7 business days';

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    message,
                                    style: AppTextStyles.bodyMedium(
                                      isDark: true,
                                    ).copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.getSuccess(isDark),
                                  duration: const Duration(seconds: 4),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSmall.r,
                                    ),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            print('✗ Error cancelling booking: $e');
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
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSmall.r,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.getError(isDark)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium.r,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMedium.h,
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
        elevation: AppSizes.cardElevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium.w),
          child: const Center(child: CircularProgressIndicator.adaptive()),
        ),
      ),
      error: (error, stack) => Card(
        color: AppColors.getCard(isDark),
        elevation: AppSizes.cardElevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium.w),
          child: Text(
            'Error loading event details',
            style: AppTextStyles.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
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
            ? AppColors.getSuccess(isDark).withOpacity(0.15)
            : AppColors.getError(isDark).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.labelSmall(isDark: isDark).copyWith(
          color: isConfirmed
              ? AppColors.getSuccess(isDark)
              : AppColors.getError(isDark),
          fontWeight: FontWeight.w600,
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
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
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
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge.w,
                  vertical: AppSizes.paddingMedium.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                ),
                elevation: 2,
                textStyle: AppTextStyles.labelMedium(isDark: isDark),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
