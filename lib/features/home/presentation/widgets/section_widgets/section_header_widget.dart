import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.isDark,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.getResponsiveHorizontalPadding(context).left,
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onViewAll,
            child: Text(
              title,
              style: AppTextStyles.headingxSmall(isDark: isDark),
            ),
          ),
          SizedBox(width: 10.w),
          InkWell(
            onTap: onViewAll,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppSizes.iconSmall,
              color: ThemeUtils.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}