import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/features/profile/presentation/providers/other_users_provider.dart';

// User Profile Screen

class UserProfileScreen extends ConsumerWidget {
  final dynamic user; // The user object passed from search

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    // Get user's events (events they're hosting)
    final userEventsAsync = ref.watch(userHostedEventsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.getPrimary(isDark),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.getPrimary(isDark),
                          AppColors.getPrimary(isDark).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // Profile Content
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Profile Picture
                        Hero(
                          tag: 'user-${user.id}',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              image: user.profileImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        user.profileImageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user.profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.getPrimary(isDark),
                                  )
                                : null,
                          ),
                        ),

                        SizedBox(height: AppSizes.spacingMedium),

                        // User Name
                        Text(
                          user.name,
                          style: AppTextStyles.headingMedium(isDark: false)
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),

                        SizedBox(height: AppSizes.spacingXs),

                        // User Email
                        Text(
                          user.email,
                          style: AppTextStyles.bodyMedium(
                            isDark: false,
                          ).copyWith(color: Colors.white.withOpacity(0.9)),
                        ),

                        SizedBox(height: AppSizes.spacingLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: AppSizes.spacingLarge),

                // Action Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to messaging screen
                            context.push('/chat', extra: user);
                          },
                          icon: Icon(Icons.message_rounded),
                          label: Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.getPrimary(isDark),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.paddingLarge,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLarge,
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingMedium),
                      ElevatedButton(
                        onPressed: () {
                          // Add follow/unfollow functionality
                          _showComingSoonDialog(context, isDark);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getSurface(isDark),
                          foregroundColor: AppColors.getTextPrimary(isDark),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingXl,
                            vertical: AppSizes.paddingLarge,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLarge,
                            ),
                            side: BorderSide(
                              color: AppColors.getBorder(isDark),
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Icon(Icons.person_add_outlined),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.spacingXl),

                // Stats Section
                _StatsSection(user: user, isDark: isDark),

                SizedBox(height: AppSizes.spacingXl),

                // About Section
                if (user.bio != null && user.bio!.isNotEmpty)
                  _AboutSection(user: user, isDark: isDark),

                // Events Hosted Section
                Padding(
                  padding: EdgeInsets.all(AppSizes.paddingXl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Events Hosted',
                            style: AppTextStyles.titleLarge(
                              isDark: isDark,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                              vertical: AppSizes.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimary(
                                isDark,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusRound,
                              ),
                            ),
                            child: userEventsAsync.when(
                              data: (events) => Text(
                                '${events.length}',
                                style: AppTextStyles.labelMedium(isDark: isDark)
                                    .copyWith(
                                      color: AppColors.getPrimary(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              loading: () => SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.getPrimary(isDark),
                                  ),
                                ),
                              ),
                              error: (_, __) => Text(
                                '0',
                                style: AppTextStyles.labelMedium(isDark: isDark)
                                    .copyWith(
                                      color: AppColors.getPrimary(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.spacingLarge),
                      userEventsAsync.when(
                        data: (events) {
                          if (events.isEmpty) {
                            return _EmptyEventsState(isDark: isDark);
                          }
                          return Column(
                            children: events.map((event) {
                              return _UserEventCard(
                                event: event,
                                isDark: isDark,
                                onTap: () {
                                  context.push('/event-detail', extra: event);
                                },
                              );
                            }).toList(),
                          );
                        },
                        loading: () => Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSizes.paddingXxl),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.getPrimary(isDark),
                              ),
                            ),
                          ),
                        ),
                        error: (_, __) => _EmptyEventsState(isDark: isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCard(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Text(
          'Coming Soon',
          style: AppTextStyles.titleMedium(isDark: isDark),
        ),
        content: Text(
          'Follow feature will be available soon!',
          style: AppTextStyles.bodyMedium(isDark: isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.getPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stats Section Widget

class _StatsSection extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _StatsSection({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
      padding: EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.event_rounded,
            label: 'Events',
            value: '${user.hostedEventsCount ?? 0}',
            isDark: isDark,
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          _StatItem(
            icon: Icons.people_rounded,
            label: 'Followers',
            value: '${user.followersCount ?? 0}',
            isDark: isDark,
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          _StatItem(
            icon: Icons.star_rounded,
            label: 'Rating',
            value: '${user.rating ?? '4.5'}',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.getPrimary(isDark), size: 28),
        SizedBox(height: AppSizes.spacingSmall),
        Text(
          value,
          style: AppTextStyles.titleMedium(
            isDark: isDark,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSizes.spacingXs),
        Text(
          label,
          style: AppTextStyles.bodySmall(
            isDark: isDark,
          ).copyWith(color: AppColors.getTextSecondary(isDark)),
        ),
      ],
    );
  }
}

// About Section Widget

class _AboutSection extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _AboutSection({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
      padding: EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: AppColors.getPrimary(isDark),
                size: 20,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                'About',
                style: AppTextStyles.titleMedium(
                  isDark: isDark,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingMedium),
          Text(
            user.bio ?? 'No bio available',
            style: AppTextStyles.bodyMedium(
              isDark: isDark,
            ).copyWith(height: 1.5),
          ),
          if (user.interests != null && user.interests!.isNotEmpty) ...[
            SizedBox(height: AppSizes.spacingLarge),
            Wrap(
              spacing: AppSizes.spacingSmall,
              runSpacing: AppSizes.spacingSmall,
              children: (user.interests as List).map<Widget>((interest) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimary(isDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                    border: Border.all(
                      color: AppColors.getPrimary(isDark).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    interest.toString(),
                    style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                      color: AppColors.getPrimary(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// User Event Card Widget

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
    final timeFormat = DateFormat('h:mm a');

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getCard(isDark),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: AppColors.getBorder(isDark), width: 1),
          ),
          child: Row(
            children: [
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(AppSizes.radiusLarge),
                ),
                child: event.imageUrl != null
                    ? Image.network(
                        event.imageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),

              // Event Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
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
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          SizedBox(width: 4),
                          Text(
                            dateFormat.format(event.startTime),
                            style: AppTextStyles.bodySmall(isDark: isDark)
                                .copyWith(
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.spacingXs),
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 14,
                            color: AppColors.getPrimary(isDark),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${event.attendees.length} attendees',
                            style: AppTextStyles.bodySmall(isDark: isDark)
                                .copyWith(
                                  color: AppColors.getPrimary(isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow Icon
              Padding(
                padding: EdgeInsets.only(right: AppSizes.paddingMedium),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.getSurface(isDark),
      child: Icon(
        Icons.event_rounded,
        size: 40,
        color: AppColors.getTextSecondary(isDark),
      ),
    );
  }
}

// Empty Events State Widget

class _EmptyEventsState extends StatelessWidget {
  final bool isDark;

  const _EmptyEventsState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingXxl),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingXl),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            'No events hosted yet',
            style: AppTextStyles.titleMedium(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            'This user hasn\'t created any events',
            style: AppTextStyles.bodyMedium(
              isDark: isDark,
            ).copyWith(color: AppColors.getTextSecondary(isDark)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
