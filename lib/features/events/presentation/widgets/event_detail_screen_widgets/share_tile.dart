// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

// Widget for share event tile
class ShareTile extends StatelessWidget {
  final bool isDark;
  final String eventTitle;
  final String? eventDescription;
  final String? shareUrl; // Deep link or web URL to the event

  const ShareTile({
    super.key,
    required this.isDark,
    required this.eventTitle,
    this.eventDescription,
    this.shareUrl,
  });

  Future<void> _handleShare(BuildContext context) async {
    if (shareUrl == null || shareUrl!.isNotEmpty) {
      // Show dialog with link to copy
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.getSurface(isDark),
            title: Text(
              'Share With Your Friends',
              style: AppTextStyles.titleMedium(
                isDark: isDark,
              ).copyWith(color: AppColors.getTextPrimary(isDark)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Copy this link to share the App:',
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                  ).copyWith(color: AppColors.getTextSecondary(isDark)),
                ),
                SizedBox(height: AppSizes.spacingSmall),
                SelectableText(
                  shareUrl!,
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Close',
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                  ).copyWith(color: AppColors.getTextSecondary(isDark)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: shareUrl!));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Link copied to clipboard!',
                          style: AppTextStyles.bodyMedium(
                            isDark: isDark,
                          ).copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.getSuccess(isDark),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(isDark),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Copy Link',
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Fallback if no URL
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No share link available',
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.getError(isDark),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build share tile with icon and text
    return GestureDetector(
      onTap: () => _handleShare(context),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark).withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.getPrimary(isDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.share_rounded,
                      color: AppColors.getPrimary(isDark),
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Text(
                  'Share with your friends',
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            Text(
              'Share',
              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                color: AppColors.getPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
