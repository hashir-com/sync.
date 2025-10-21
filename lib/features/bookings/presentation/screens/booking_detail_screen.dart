import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_detail_screen_widgets/action_buttons.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_detail_screen_widgets/detail_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_detail_screen_widgets/ticket_card.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// Main screen for displaying booking details
class BookingDetailsScreen extends ConsumerWidget {
  final BookingEntity booking;
  final EventEntity event;

  const BookingDetailsScreen({super.key, required this.booking, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    // Build main scaffold with app bar and body
    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Your Ticket',
          style: AppTextStyles.headingMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.getBackground(isDark),
        elevation: AppSizes.appBarElevation,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.getPrimary(isDark)),
          onPressed: () => context.go('/home'),
        ),
        toolbarHeight: ResponsiveUtil.getAppBarHeight(context),
      ),
      body: Padding(
        padding: ResponsiveUtil.getResponsivePadding(context),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: AppSizes.spacingMedium.h),
                TicketCard(booking: booking, event: event),
                SizedBox(height: AppSizes.spacingXxl.h),
                DetailCard(booking: booking, event: event),
                SizedBox(height: AppSizes.spacingXxl.h),
                ActionButtons(booking: booking, event: event),
                SizedBox(height: AppSizes.paddingLarge.h),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}