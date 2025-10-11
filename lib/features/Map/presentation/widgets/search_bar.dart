// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import 'package:sync_event/features/Map/presentation/provider/map_providers.dart' hide searchQueryProvider, allEventsProvider, searchEventsUseCaseProvider, filteredEventsProvider, themeProvider;
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';

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
    final colors = AppColors(isDark);
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
            child: _buildSearchField(colors, query),
          ),
          SizedBox(width: 12.w),
          _buildLocateButton(colors),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppColors colors, String query) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: query.isNotEmpty
                ? colors.primary.withOpacity(0.3)
                : colors.shadow,
            blurRadius: query.isNotEmpty ? 15.r : 10.r,
            offset: const Offset(0, 4),
            spreadRadius: query.isNotEmpty ? 2 : 0,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: colors.primary,
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: query.isNotEmpty ? 0.5 : 0,
            child: Icon(Icons.search, color: colors.textSecondary, size: 22.sp),
          ),
          suffixIcon: query.isNotEmpty ? _buildClearButton(colors) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildClearButton(AppColors colors) {
    return IconButton(
      icon: Icon(Icons.clear, color: colors.textSecondary, size: 22.sp),
      onPressed: () {
        widget.controller.clear();
        ref.read(searchQueryProvider.notifier).state = '';
        widget.focusNode.unfocus();
        if (kDebugMode) print('Search cleared');
      },
    );
  }

  Widget _buildLocateButton(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.2),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: widget.onLocateTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(Icons.my_location, color: colors.primary, size: 24.sp),
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