import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/bookings/presentation/states/booking_screen_state.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_event_detail_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_event_image.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_payment_selection.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_price_summary_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_ticket_selection_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_widget.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String eventId;

  const BookingScreen({super.key, required this.eventId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    final eventAsync = ref.watch(approvedEventsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: _buildAppBar(isDark, context),
      body: eventAsync.when(
        data: (events) => _handleEventData(events, isDark),
        loading: () => const BookingLoadingWidget(),
        error: (error, stack) =>
            BookingErrorWidget(error: error, isDark: isDark),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark, BuildContext context) {
    return AppBar(
      title: Text(
        'Book Tickets',
        style: AppTextStyles.headingMedium(isDark: isDark)
            .copyWith(fontWeight: FontWeight.w700),
      ),
      backgroundColor: AppColors.getBackground(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.getPrimary(isDark),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _handleEventData(List<EventEntity> events, bool isDark) {
    try {
      final event = events.firstWhere((e) => e.id == widget.eventId);
      final bookingState = ref.watch(bookingNotifierProvider);
      return _buildBookingContent(event, isDark, bookingState);
    } catch (e) {
      return BookingErrorWidget(error: 'Event not found', isDark: isDark);
    }
  }

  Widget _buildBookingContent(
    EventEntity event,
    bool isDark,
    AsyncValue<BookingEntity?> bookingState,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.spacingMedium.h),
                BookingEventHeaderCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingEventImageCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingEventDetailsCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingTicketSelectionCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingPriceSummaryCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingPaymentSection(
                  event: event,
                  isDark: isDark,
                  bookingState: bookingState,
                ),
                SizedBox(height: AppSizes.paddingXl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}