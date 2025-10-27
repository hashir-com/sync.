// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/profile/presentation/providers/auth_state_provider.dart';
import 'package:sync_event/features/profile/presentation/providers/other_users_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final currentUser = ref.watch(currentUserProvider);
    final currentUid = currentUser?.uid;
    final isSelf = userId == null || userId == currentUid;
    final effectiveUid = userId ?? currentUid;

    if (effectiveUid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileAsync = ref.watch(userByIdProvider(effectiveUid));
    final eventsAsync = ref.watch(userHostedEventsProvider(effectiveUid));

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.getBackground(isDark),
        body: CustomScrollView(
          slivers: profileAsync.when(
            data: (user) {
              if (user == null) {
                return [
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'User not found',
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                    ),
                  ),
                ];
              }
              return [
                _buildProfileHeader(context, user, isSelf, isDark),
                _buildSectionTitle(context, 'Hosted Events', isDark),
                _buildEventsSection(context, eventsAsync, isDark),
              ];
            },
            loading: () => [_buildShimmerHeader(context, isDark)],
            error: (_, __) => [
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Failed to load profile',
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildProfileHeader(
    BuildContext context,
    UserModel user,
    bool isSelf,
    bool isDark,
  ) {
    final double avatarSize = ResponsiveUtil.getAvatarSize(context) + 40;

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: ResponsiveUtil.getSpacing(context, baseSpacing: 32),
          bottom: ResponsiveUtil.getSpacing(context, baseSpacing: 28),
          left: ResponsiveUtil.getPadding(context),
          right: ResponsiveUtil.getPadding(context),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.getPrimary(isDark),
              AppColors.getPrimary(isDark).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getPrimary(isDark).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Picture with Enhanced Styling
            Hero(
              tag: 'user-${user.id}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: Colors.white,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: avatarSize / 2,
                          color: AppColors.getPrimary(isDark),
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveUtil.getSpacing(context, baseSpacing: 16),
            ),

            // User Name with Enhanced Typography
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium(isDark: false).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28 * ResponsiveUtil.getFontSizeMultiplier(context),
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(
              height: ResponsiveUtil.getSpacing(context, baseSpacing: 20),
            ),

            // Edit Profile Button (only for self)
            if (isSelf)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/edit-profile'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    'Edit Profile',
                    style: AppTextStyles.bodyMedium(
                      isDark: false,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.getPrimary(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildSectionTitle(
    BuildContext context,
    String title,
    bool isDark,
  ) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtil.getPadding(context),
        ResponsiveUtil.getSpacing(context, baseSpacing: 24),
        ResponsiveUtil.getPadding(context),
        ResponsiveUtil.getSpacing(context, baseSpacing: 16),
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22 * ResponsiveUtil.getFontSizeMultiplier(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection(
    BuildContext context,
    AsyncValue<List<dynamic>> eventsAsync,
    bool isDark,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.getPadding(context),
      ),
      sliver: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No events hosted yet',
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final crossAxisCount = ResponsiveUtil.getColumnCount(
            context,
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
          );

          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(context, event, isDark);
            },
          );
        },
        loading: () => _buildEventsShimmer(context, isDark),
        error: (e, __) {
          debugPrint('Error loading events: $e');
          debugPrintStack(stackTrace: __);
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load events',
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, dynamic event, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/event-detail', extra: event),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCard(isDark),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image with Overlay
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.getPrimary(isDark).withOpacity(0.3),
                            AppColors.getPrimary(isDark).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: event.imageUrl != null
                          ? Image.network(
                              event.imageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.event_rounded,
                                size: 48,
                                color: AppColors.getPrimary(
                                  isDark,
                                ).withOpacity(0.4),
                              ),
                            ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Event Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Event Title
                      Text(
                        event.title ?? 'Untitled Event',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Event Date & Time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimary(
                                isDark,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: AppColors.getPrimary(isDark),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd',
                                  ).format(event.date ?? DateTime.now()),
                                  style: AppTextStyles.bodySmall(isDark: isDark)
                                      .copyWith(
                                        color: AppColors.getPrimary(isDark),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsShimmer(BuildContext context, bool isDark) {
    final crossAxisCount = ResponsiveUtil.getColumnCount(
      context,
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
    );

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        childCount: 4,
      ),
    );
  }

  SliverToBoxAdapter _buildShimmerHeader(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
      ),
    );
  }
}
