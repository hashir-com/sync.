import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/bookings_list_view.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/error_view.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/not_authenticated_view.dart';

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
        elevation: AppSizes.appBarElevation,
        centerTitle: true,
        toolbarHeight: ResponsiveUtil.getAppBarHeight(context),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const NotAuthenticatedView();
          }
          return BookingsListView(userId: user.uid);
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stack) => ErrorView(
          message: 'Error loading user data',
          error: error,
        ),
      ),
    );
  }
}