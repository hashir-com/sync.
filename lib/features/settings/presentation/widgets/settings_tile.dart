import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_sizes.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDark;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: AppSizes.iconMedium.sp,
      ),
      title: Text(label),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium.w,
        vertical: AppSizes.paddingSmall.h,
      ),
    );
  }
}