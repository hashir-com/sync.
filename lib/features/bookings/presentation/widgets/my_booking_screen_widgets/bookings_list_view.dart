import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/booking_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/empty_state.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/error_view.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/filter_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/no_result_view.dart';
import 'package:sync_event/core/util/theme_util.dart';

class BookingsListView extends ConsumerWidget {
  final String userId;

  const BookingsListView({super.key, required this.userId});

  List<BookingEntity> _applyFilters(List<BookingEntity> bookings, BookingsFilterState filterState) {
    final query = filterState.searchQuery.toLowerCase();
    return bookings.where((b) {
      final matchesStatus = filterState.statusFilter == 'all' || b.status == filterState.statusFilter;
      final matchesDate = filterState.dateFilter == null ||
          (b.startTime.isAfter(filterState.dateFilter!.start.subtract(const Duration(days: 1))) &&
              b.startTime.isBefore(filterState.dateFilter!.end.add(const Duration(days: 1))));
      final matchesSearch = b.id.toLowerCase().contains(query) ||
          b.ticketType.toLowerCase().contains(query) ||
          b.paymentId.toLowerCase().contains(query);
      return matchesStatus && matchesDate && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeUtils.isDark(context);
    final bookingsAsync = ref.watch(userBookingsProvider(userId));
    final filterState = ref.watch(bookingsFilterProvider);

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return const EmptyState();
        }
        final filteredBookings = _applyFilters(bookings, filterState);
        return ListView(
          padding: EdgeInsets.all(AppSizes.paddingMedium.w),
          children: [
            FilterCard(userId: userId, filterState: filterState),
            SizedBox(height: AppSizes.spacingMedium.h),
            if (filteredBookings.isEmpty)
              NoResultsView(filterState: filterState)
            else
              ...filteredBookings.map((booking) => BookingCard(booking: booking, userId: userId)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => ErrorView(message: 'Error loading bookings', error: error),
    );
  }
}