import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/theme_util.dart';

void showFavoriteSnackbarSafe(
  BuildContext context,
  bool wasFavorite,
  String title,
) {
  if (!context.mounted) return;

  final isDark = ThemeUtils.isDark(context);
  try {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            wasFavorite ? Icons.favorite_border : Icons.favorite,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: AppSizes.spacingMedium),
          Expanded(
            child: Text(
              wasFavorite ? 'Removed from favorites' : 'Added to favorites',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 2000),
      behavior: SnackBarBehavior.floating,
      backgroundColor: wasFavorite ? AppColors.getDisabled(isDark) : AppColors.getFavorite(isDark),
      margin: EdgeInsets.all(AppSizes.spacingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } catch (e) {}
}