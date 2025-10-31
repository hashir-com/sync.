// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/auth/presentation/providers/user_data_provider.dart';
import 'package:sync_event/features/chat/presentation/providers/chat_providers.dart';

class OrganizerTile extends ConsumerWidget {
  final String organizerId;
  final String organizerName;
  final bool isDark;

  const OrganizerTile({
    super.key,
    required this.organizerId,
    required this.organizerName,
    required this.isDark,
  });

  Future<void> _handleChatTap(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.getPrimary(isDark),
            ),
          ),
        ),
      );

      // Create or get chat with organizer
      final chatId = await ref
          .read(createOrGetChatUseCaseProvider)
          .call(organizerId);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to chat screen
      if (context.mounted) {
        context.push('/chat/$chatId');
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: AppColors.getError(isDark),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user ID
    final currentUser = ref.watch(authStateProvider).value;
    final isCurrentUserOrganizer = currentUser?.uid == organizerId;

    // Fetch organizer user data
    final userDataAsync = ref.watch(userDataProvider(organizerId));

    return userDataAsync.when(
      data: (userData) {
        final organizerImageUrl = userData?.image;
        final displayName = userData?.name ?? organizerName;

        return _buildTileContent(
          context,
          ref,
          displayName,
          organizerImageUrl,
          isCurrentUserOrganizer,
        );
      },
      loading: () => _buildTileContent(
        context,
        ref,
        organizerName,
        null,
        isCurrentUserOrganizer,
      ),
      error: (_, __) => _buildTileContent(
        context,
        ref,
        organizerName,
        null,
        isCurrentUserOrganizer,
      ),
    );
  }

  Widget _buildTileContent(
    BuildContext context,
    WidgetRef ref,
    String displayName,
    String? imageUrl,
    bool isCurrentUserOrganizer,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.getBorder(isDark).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDark),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildOrganizerAvatar(displayName, imageUrl),
              SizedBox(width: AppSizes.spacingMedium),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingXs),
                  Text(
                    'Organizer',
                    style: AppTextStyles.bodySmall(
                      isDark: isDark,
                    ).copyWith(color: AppColors.getTextSecondary(isDark)),
                  ),
                ],
              ),
            ],
          ),
          // Show "You are the organizer" badge or Chat button
          if (isCurrentUserOrganizer)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(
                  color: AppColors.getPrimary(isDark).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'You are the organizer',
                style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
                  color: AppColors.getPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _handleChatTap(context, ref),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getPrimary(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                    color: AppColors.getPrimary(isDark).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: AppColors.getPrimary(isDark),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Chat',
                      style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
                        color: AppColors.getPrimary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrganizerAvatar(String displayName, String? imageUrl) {
    // Check if organizer has an image URL
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.getPrimary(isDark).withOpacity(0.2),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildInitialAvatar(displayName),
          ),
        ),
      );
    }

    // Show initial letter avatar if no image
    return _buildInitialAvatar(displayName);
  }

  Widget _buildInitialAvatar(String displayName) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDark),
            AppColors.getPrimary(isDark).withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.fontXl,
          ),
        ),
      ),
    );
  }
}
