import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';


class CreateEventAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CreateEventAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return AppBar(
      title: Text(
        'CREATE NEW EVENT',
        style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
          letterSpacing: AppSizes.letterSpacingLabel,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.getBackground(isDark),
      elevation: AppSizes.appBarElevation,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.getTextPrimary(isDark),
          size: AppSizes.iconMedium,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.getTextPrimary(isDark),
            size: AppSizes.iconMedium,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}