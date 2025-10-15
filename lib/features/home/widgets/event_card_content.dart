import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';

class EventCardContent extends StatelessWidget {
  final String title;
  final String location;
  final String attendees;
  final List<String>? attendeeAvatars; // Optional: for future avatar URLs

  const EventCardContent({
    super.key,
    required this.title,
    required this.location,
    required this.attendees,
    this.attendeeAvatars,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Title
        Text(
          title,
          style: AppTextStyles.titleMedium(
            isDark: isDark,
          ).copyWith(fontWeight: FontWeight.w700, height: 1.3),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: AppSizes.spacingMedium),

        // Location
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: AppSizes.iconSmall,
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(width: AppSizes.spacingXs),
            Expanded(
              child: Text(
                location,
                style: AppTextStyles.bodySmall(
                  isDark: isDark,
                ).copyWith(height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSizes.spacingMedium),

        // Attendees Section
        Row(
          children: [
            _AttendeeAvatarStack(isDark: isDark, avatarUrls: attendeeAvatars),
            SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: Text(
                attendees,
                style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
                  color: AppColors.getPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================
// Attendee Avatar Stack Widget
// ============================================
class _AttendeeAvatarStack extends StatelessWidget {
  final bool isDark;
  final List<String>? avatarUrls;

  const _AttendeeAvatarStack({required this.isDark, this.avatarUrls});

  @override
  Widget build(BuildContext context) {
    // Professional color palette for avatar placeholders
    final avatarColors = [
      AppColors.primary, // Deep blue (0xFF04007C)
      AppColors.primaryVariant, // Lighter blue (0xFF4E42F5)
      AppColors.secondary, // Sky blue (0xFF64B5F6)
      AppColors.favorite, // Pink (0xFFE91E63)
      AppColors.success, // Green (0xFF388E3C)
      AppColors.info, // Blue (0xFF1976D2)
    ];

    return SizedBox(
      width: AppSizes.avatarSmall * 2.4,
      height: AppSizes.avatarSmall,
      child: Stack(
        children: List.generate(
          3,
          (index) => Positioned(
            left: index * (AppSizes.avatarSmall * 0.6),
            child: _AvatarCircle(
              color: avatarColors[index % avatarColors.length],
              isDark: isDark,
              imageUrl: avatarUrls != null && index < avatarUrls!.length
                  ? avatarUrls![index]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// Individual Avatar Circle
// ============================================
class _AvatarCircle extends StatelessWidget {
  final Color color;
  final bool isDark;
  final String? imageUrl;

  const _AvatarCircle({
    required this.color,
    required this.isDark,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.avatarSmall,
      height: AppSizes.avatarSmall,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.getCard(isDark), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _GradientAvatar(color: color);
                },
              )
            : _GradientAvatar(color: color),
      ),
    );
  }
}

// ============================================
// Gradient Avatar Placeholder
// ============================================
class _GradientAvatar extends StatelessWidget {
  final Color color;

  const _GradientAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: AppSizes.iconSmall,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}
