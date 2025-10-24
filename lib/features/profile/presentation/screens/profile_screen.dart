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
    final double avatarSize = ResponsiveUtil.getAvatarSize(context) + 20;

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtil.getSpacing(context, baseSpacing: 20),
          horizontal: ResponsiveUtil.getPadding(context),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.getPrimary(isDark),
              AppColors.getPrimary(isDark).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Hero(
              tag: 'user-${user.id}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: Colors.grey[200],
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
              height: ResponsiveUtil.getSpacing(context, baseSpacing: 12),
            ),
            Text(
              user.name,
              style: AppTextStyles.headingMedium(isDark: false).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26 * ResponsiveUtil.getFontSizeMultiplier(context),
              ),
            ),
            SizedBox(
              height: ResponsiveUtil.getSpacing(context, baseSpacing: 12),
            ),
            if (isSelf)
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => context.push('/edit-profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.getPrimary(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: AppTextStyles.bodyMedium(
                      isDark: false,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            SizedBox(
              height: ResponsiveUtil.getSpacing(context, baseSpacing: 16),
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
                child: Text(
                  'No events hosted yet',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
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
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () => context.push('/event-detail', extra: event),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.getCard(isDark),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: event.imageUrl != null
                              ? Image.network(
                                  event.imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.grey[300]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title ?? 'Untitled',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium(
                                isDark: isDark,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().format(
                                event.date ?? DateTime.now(),
                              ),
                              style: AppTextStyles.bodySmall(isDark: isDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtil.getSpacing(context)),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(height: 150, color: Colors.white),
            ),
          ),
        ),
        error: (e, __) {
          debugPrint('Error loading events: $e');
          debugPrintStack(stackTrace: __);
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'Failed to load events $e ',
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildShimmerHeader(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 260, color: Colors.white),
      ),
    );
  }
}
