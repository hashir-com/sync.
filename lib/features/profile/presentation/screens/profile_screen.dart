import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// StreamProvider for listening to Firebase user changes
final userChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

// Provider for user stats (following and followers)
final userStatsProvider = Provider<Map<String, String>>((ref) {
  return {'following': '950', 'followers': '550'};
});

// Provider for user interests
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
    final userAsync = ref.watch(userChangesProvider);
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
        child: userAsync.when(
          data: (user) => user == null
              ? Center(
                  child: Text(
                    "No user logged in",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileAvatar(user.photoURL, theme),
                      SizedBox(height: _spacingMedium),
                      _buildUserDetails(
                        user,
                        userStats,
                        navigateToEditProfile,
                        theme,
                      ),
                      SizedBox(height: _spacingLarge),
                      _buildAboutSection(theme),
                      SizedBox(height: _spacingSmall),
                      _buildInterestSection(ref, theme),
                    ],
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              "Error loading user data: $error",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
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
              radius: _avatarRadius,
              backgroundColor: theme.colorScheme.surface,
              child: CircleAvatar(
                radius: _avatarRadius - 2,
                backgroundColor: Colors.transparent,
              ),
            )
          : CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: theme.colorScheme.surfaceContainer,
              child: Icon(
                Icons.person,
                size: 40,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
    );
  }

  Widget _buildUserDetails(
    User user,
    Map<String, String> stats,
    VoidCallback onEditPressed,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        children: [
          Text(
            user.displayName ?? 'N/A',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: _spacingLarge + 15),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatColumn(stats['following']!, "Following", theme),
                const SizedBox(width: 40),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: VerticalDivider(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    thickness: 1,
                    width: 20,
                  ),
                ),
                const SizedBox(width: 40),
                _buildStatColumn(stats['followers']!, "Followers", theme),
              ],
            ),
          ),
          SizedBox(height: _spacingSmall + 5),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(190, 45),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onEditPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w400,
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
          ),
        ),
        SizedBox(height: _spacingSmall),
        Text(label, style: theme.textTheme.bodyMedium),
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
          ),
        ),
        SizedBox(height: _spacingSmall),
        Text(
          "I am someone who enjoys being around happy people who love hosting and attending parties and events, so I often host lovely events.",
          style: theme.textTheme.bodyMedium,
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
              ),
            ),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  // Example: Add a new interest
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
                    Icon(Icons.edit, size: 12),
                    const SizedBox(width: 8),
                    Text("CHANGE", style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _spacingLarge),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: interests
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 20),
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
          radius: 28,
          backgroundColor: color.withOpacity(0.3),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
