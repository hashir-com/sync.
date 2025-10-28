// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class BookingEventHeaderCard extends StatelessWidget {
  final EventEntity event;
  final bool isDark;

  const BookingEventHeaderCard({
    super.key,
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isOrganizer = event.organizerId.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDark),
            AppColors.getPrimary(isDark).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDark).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
              fontSize: AppSizes.fontDisplay2,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.spacingMedium),
          _buildOrganizerRow(),
          if (isOrganizer) _buildOrganizerBadge(),
        ],
      ),
    );
  }

  Widget _buildOrganizerRow() {
    return Row(
      children: [
        Icon(
          Icons.person_rounded,
          color: Colors.white.withOpacity(0.8),
          size: AppSizes.iconMedium,
        ),
        SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: Text(
            'Organized by ${event.organizerName}',
            style: AppTextStyles.bodyMedium(
              isDark: isDark,
            ).copyWith(color: Colors.white.withOpacity(0.9)),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerBadge() {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.spacingMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Text(
          'You are the organizer',
          style: AppTextStyles.labelSmall(
            isDark: isDark,
          ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
