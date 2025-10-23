import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

// Widget for Buy Ticket/View Event button
class BookingButton extends StatelessWidget {
  final String eventId;
  final bool isOrganizer;

  const BookingButton({
    super.key,
    required this.eventId,
    required this.isOrganizer,
  });

  @override
  Widget build(BuildContext context) {
    // Build booking button with gradient
    return Container(
      width: double.infinity,
      height: ResponsiveUtil.getButtonHeight(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryVariant, AppColors.primaryVariant],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          onTap: () => context.push('/book/$eventId'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isOrganizer ? 'VIEW EVENT' : 'BUY TICKET',
                style: AppTextStyles.labelLarge(isDark: false),
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
