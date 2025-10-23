
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;
import 'package:sync_event/features/bookings/domain/usecases/get_booking_usecase.dart';

class BookingDetailsLoaderScreen extends ConsumerWidget {
  final String bookingId;
  const BookingDetailsLoaderScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return FutureBuilder<BookingEntity>(
      future: _fetchBooking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Booking Details',
                style: AppTextStyles.headingMedium(isDark: isDark),
              ),
              backgroundColor: AppColors.getPrimary(isDark),
            ),
            body: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Booking Details',
                style: AppTextStyles.headingMedium(isDark: isDark),
              ),
              backgroundColor: AppColors.getPrimary(isDark),
            ),
            body: _buildError(context, isDark, 'Failed to load booking', snapshot.error),
          );
        }

        final booking = snapshot.data!;
        final eventsAsync = ref.watch(approvedEventsStreamProvider);
        return eventsAsync.when(
          data: (events) {
            EventEntity? event;
            try {
              event = events.firstWhere((e) => e.id == booking.eventId);
            } catch (_) {
              event = EventEntity(
                id: booking.eventId,
                title: 'Event',
                description: '',
                location: 'Unknown',
                startTime: booking.startTime,
                endTime: booking.endTime,
                organizerId: '',
                organizerName: 'Unknown',
                maxAttendees: 0,
                category: '',
                createdAt: booking.bookingDate,
                updatedAt: booking.bookingDate,
                availableTickets: 0, // Added required availableTickets
              );
            }
            return BookingDetailsScreen(booking: booking, event: event);
          },
          loading: () => Scaffold(
            appBar: AppBar(
              title: Text('Booking Details', style: AppTextStyles.headingMedium(isDark: isDark)),
              backgroundColor: AppColors.getPrimary(isDark),
            ),
            body: const Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (error, _) => Scaffold(
            appBar: AppBar(
              title: Text('Booking Details', style: AppTextStyles.headingMedium(isDark: isDark)),
              backgroundColor: AppColors.getPrimary(isDark),
            ),
            body: _buildError(context, isDark, 'Failed to load event', error),
          ),
        );
      },
    );
  }

  Future<BookingEntity> _fetchBooking() async {
    final usecase = di.sl<GetBookingUseCase>();
    final result = await usecase(bookingId);
    return result.fold((l) => throw l, (r) => r);
  }

  Widget _buildError(BuildContext context, bool isDark, String message, Object? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: AppSizes.iconXxl, color: AppColors.getError(isDark)),
            SizedBox(height: AppSizes.spacingMedium),
            Text(message, style: AppTextStyles.headingSmall(isDark: isDark), textAlign: TextAlign.center),
            if (error != null)
              Padding(
                padding: EdgeInsets.only(top: AppSizes.spacingSmall),
                child: Text(
                  error is Failure ? error.message : error.toString(),
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  
}

 