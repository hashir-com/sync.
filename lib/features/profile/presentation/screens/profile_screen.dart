// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sync_event/features/profile/presentation/providers/auth_state_provider.dart';

// Define a UserModel to match your repository's structure
class UserModel {
  final String? name;
  final String? image;
  final String? uid;

  UserModel({this.name, this.image, this.uid});

  factory UserModel.fromFirebaseUser(firebase_auth.User? user) {
    return UserModel(
      name: user?.displayName,
      image: user?.photoURL,
      uid: user?.uid,
    );
  }
}

final userStatsProvider = Provider<Map<String, String>>((ref) {
  return {'following': '950', 'followers': '550'};
});

final interestsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [
    {'label': 'Games', 'icon': Icons.videogame_asset, 'color': Colors.blue},
    {'label': 'Concerts', 'icon': Icons.music_note, 'color': Colors.red},
    {'label': 'Art', 'icon': Icons.brush, 'color': Colors.purple},
    {'label': 'Music', 'icon': Icons.library_music, 'color': Colors.green},
    {'label': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.orange},
    {'label': 'Theatre', 'icon': Icons.theaters, 'color': Colors.teal},
  ];
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const double _avatarRadius = 50;
  static const double _spacingSmall = 10;
  static const double _spacingMedium = 20;
  static const double _spacingLarge = 25;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);
    final userStats = ref.watch(userStatsProvider);
    final theme = Theme.of(context);

    void navigateToEditProfile() {
      context.push('/edit-profile');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: authStateAsync.when(
          data: (user) => user == null
              ? Center(
                  child: Text(
                    "Please sign in to view your profile",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 16.sp,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileAvatar(user.image, theme),
                      SizedBox(height: _spacingMedium.h),
                      _buildUserDetails(
                        user,
                        userStats,
                        navigateToEditProfile,
                        theme,
                      ),
                      SizedBox(height: _spacingLarge.h),
                      _buildAboutSection(theme),
                      SizedBox(height: _spacingSmall.h),
                      _buildInterestSection(ref, theme),
                    ],
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              "Failed to load profile: $error",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? photoURL, ThemeData theme) {
    return Center(
      child: photoURL != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(photoURL),
              radius: _avatarRadius.r,
              backgroundColor: theme.colorScheme.surface,
              child: Hero(
                tag: 'profile',
                child: CircleAvatar(
                  radius: (_avatarRadius - 2).r,
                  backgroundColor: Colors.transparent,
                ),
              ),
            )
          : CircleAvatar(
              radius: _avatarRadius.r,
              backgroundColor: theme.colorScheme.surfaceContainer,
              child: Icon(
                Icons.person,
                size: 40.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
    );
  }

  Widget _buildUserDetails(
    UserModel user,
    Map<String, String> stats,
    VoidCallback onEditPressed,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        children: [
          Text(
            user.name ?? 'N/A',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: (_spacingLarge + 15).h),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatColumn(stats['following']!, "Following", theme),
                SizedBox(width: 40.w),
                Padding(
                  padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                  child: VerticalDivider(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    thickness: 1,
                    width: 20.w,
                  ),
                ),
                SizedBox(width: 40.w),
                _buildStatColumn(stats['followers']!, "Followers", theme),
              ],
            ),
          ),
          SizedBox(height: (_spacingSmall + 5).h),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size(190.w, 45.h),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: onEditPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, color: theme.colorScheme.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          count,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: _spacingSmall.h),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About Me",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: _spacingSmall.h),
        Text(
          "I am someone who enjoys being around happy people who love hosting and attending parties and events, so I often host lovely events.",
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildInterestSection(WidgetRef ref, ThemeData theme) {
    final interests = ref.watch(interestsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Interest",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(
              width: 100.w,
              height: 30.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
                onPressed: () {
                  ref.read(interestsProvider.notifier).state = [
                    ...interests,
                    {
                      'label': 'Dance',
                      'icon': Icons.directions_run,
                      'color': Colors.pink,
                    },
                  ];
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 12.sp,
                      color: AppColors.backgroundLight,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "CHANGE",
                      style: TextStyle(color: AppColors.backgroundLight),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _spacingLarge.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: interests
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: _buildInterestBox(
                      entry.value['label'],
                      entry.value['icon'],
                      entry.value['color'],
                      theme,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestBox(
    String label,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: color.withOpacity(0.3),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
