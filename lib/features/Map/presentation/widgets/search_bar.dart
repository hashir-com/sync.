// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/Map/presentation/provider/map_providers.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onLocateTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onLocateTap,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final query = ref.watch(searchQueryProvider);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: _buildSearchField(isDark, query),
          ),
          SizedBox(width: AppSizes.spacingMedium.w),
          _buildLocateButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark, String query) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusSemiRound.r),
        boxShadow: [
          BoxShadow(
            color: query.isNotEmpty
                ? AppColors.getPrimary(isDark).withOpacity(0.3)
                : AppColors.getShadow(isDark),
            blurRadius: query.isNotEmpty ? 15.r : AppSizes.cardElevationMedium.r,
            offset: const Offset(0, 4),
            spreadRadius: query.isNotEmpty ? 2 : 0,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
          fontSize: AppSizes.fontLarge - 1.sp,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.getPrimary(isDark),
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
            fontSize: AppSizes.fontLarge - 1.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.getTextSecondary(isDark),
          ),
          prefixIcon: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: query.isNotEmpty ? 0.5 : 0,
            child: Icon(
              Icons.search,
              color: AppColors.getTextSecondary(isDark),
              size: AppSizes.iconSmall + 2.sp,
            ),
          ),
          suffixIcon: query.isNotEmpty ? _buildClearButton(isDark) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXl.w,
            vertical: AppSizes.paddingLarge - 1.h,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildClearButton(bool isDark) {
    return IconButton(
      icon: Icon(
        Icons.clear,
        color: AppColors.getTextSecondary(isDark),
        size: AppSizes.iconSmall + 2.sp,
      ),
      onPressed: () {
        widget.controller.clear();
        ref.read(searchQueryProvider.notifier).state = '';
        widget.focusNode.unfocus();
        if (kDebugMode) print('Search cleared');
      },
    );
  }

  Widget _buildLocateButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDark).withOpacity(0.2),
            blurRadius: AppSizes.cardElevationMedium.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          onTap: widget.onLocateTap,
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium.w),
            child: Icon(
              Icons.my_location,
              color: AppColors.getPrimary(isDark),
              size: AppSizes.iconMedium.sp,
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (kDebugMode) print('TextField input: $value');
    ref.read(searchQueryProvider.notifier).state = value;
    
    final allEvents = ref.read(allEventsProvider);
    final searchUseCase = ref.read(searchEventsUseCaseProvider);
    
    ref.read(filteredEventsProvider.notifier).state = 
        searchUseCase.execute(allEvents, value);
  }
}