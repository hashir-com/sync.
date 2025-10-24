// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/profile/presentation/providers/other_users_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  final dynamic user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final userEventsAsync = ref.watch(userHostedEventsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(user.name),
        backgroundColor: AppColors.getPrimary(isDark),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade700)
                  : null,
            ),
            SizedBox(height: AppSizes.spacingMedium),

            // Name
            Text(
              user.name,
              style: AppTextStyles.headingMedium(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSizes.spacingXs),

            // Email
            Text(
              user.email,
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(color: Colors.grey),
            ),
            SizedBox(height: AppSizes.spacingLarge),

            // Message Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/chat', extra: user);
                },
                icon: const Icon(Icons.message_rounded),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(isDark),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingLarge),

            // Bio
            if (user.bio != null && user.bio!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: AppTextStyles.titleMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    user.bio!,
                    style: AppTextStyles.bodyMedium(
                      isDark: isDark,
                    ).copyWith(height: 1.5),
                  ),
                  SizedBox(height: AppSizes.spacingLarge),
                ],
              ),

            // Events Hosted
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Events Hosted',
                style: AppTextStyles.titleLarge(
                  isDark: isDark,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium),

            userEventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      'This user hasn\'t hosted any events yet.',
                      style: AppTextStyles.bodyMedium(isDark: isDark),
                    ),
                  );
                }

                return Column(
                  children: events.map((event) {
                    return _UserEventCard(
                      event: event,
                      isDark: isDark,
                      onTap: () => context.push('/event-detail', extra: event),
                    );
                  }).toList(),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.getPrimary(isDark),
                  ),
                ),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Failed to load events.',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserEventCard extends StatelessWidget {
  final dynamic event;
  final bool isDark;
  final VoidCallback onTap;

  const _UserEventCard({
    required this.event,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.getCard(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Row(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              child: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.getSurface(isDark),
                      child: Icon(
                        Icons.event_rounded,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
            ),
            SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title ?? 'Untitled Event',
                    style: AppTextStyles.bodyMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.spacingXs),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        dateFormat.format(event.startTime ?? DateTime.now()),
                        style: AppTextStyles.bodySmall(
                          isDark: isDark,
                        ).copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
