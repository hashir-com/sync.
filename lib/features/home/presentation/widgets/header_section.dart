// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/util/responsive_helper.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/home/presentation/screen/filter_bottom_sheet.dart';
import 'package:sync_event/features/profile/presentation/providers/other_users_provider.dart';

// Search Result Model
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SearchResultType type;
  final dynamic data;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.type,
    required this.data,
  });
}

enum SearchResultType { event, user }

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

//Combined Search Results Provider - Simple and stable
final searchResultsProvider = Provider<AsyncValue<List<SearchResult>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  print(' SEARCH QUERY: "$query"');

  if (query.isEmpty || query.length < 2) {
    print(' Query too short or empty, returning empty data');
    return const AsyncValue.data([]);
  }

  final eventsAsync = ref.watch(approvedEventsStreamProvider);
  final usersAsync = ref.watch(allUsersProvider);

  print(
    'Events state: ${eventsAsync.runtimeType}, Users state: ${usersAsync.runtimeType}',
  );

  // If events is loading, show loading
  if (eventsAsync.isLoading) {
    print(' Events provider is loading');
    return const AsyncValue.loading();
  }

  // If events has error, show error
  if (eventsAsync.hasError) {
    final error = eventsAsync.error;
    print(' Events provider error: $error');
    return AsyncValue.error(error!, StackTrace.current);
  }

  // If users is still loading, wait for it
  if (usersAsync.isLoading) {
    print('Users provider is loading, waiting...');
    return const AsyncValue.loading();
  }

  // If users has error, continue with events only
  if (usersAsync.hasError) {
    print(
      'Users provider error (will search events only): ${usersAsync.error}',
    );
    // Continue with events only, ignore user search error
  }

  // Both have data
  return eventsAsync.when(
    data: (events) {
      return usersAsync.when(
        data: (users) {
          print(' Processing: ${events.length} events, ${users.length} users');

          final eventResults = <SearchResult>[];
          final userResults = <SearchResult>[];

          // Search Events
          final matchingEvents = events.where((event) {
            final title = event.title.toLowerCase();
            final category = event.category.toLowerCase();
            final location = event.location.toLowerCase();

            final matches =
                title.contains(query) ||
                category.contains(query) ||
                location.contains(query);

            if (matches) {
              print(' Event match: ${event.title}');
            }

            return matches;
          }).toList();

          print('Matching events: ${matchingEvents.length}');

          eventResults.addAll(
            matchingEvents.map(
              (event) => SearchResult(
                id: event.id,
                title: event.title,
                subtitle: '${event.category} • ${event.location}',
                imageUrl: event.imageUrl,
                type: SearchResultType.event,
                data: event,
              ),
            ),
          );

          // Search Users
          final matchingUsers = users.where((user) {
            final name = user.name.toLowerCase();
            final email = user.email.toLowerCase();

            final matches = name.contains(query) || email.contains(query);

            if (matches) {
              print(' User match: ${user.name}');
            }

            return matches;
          }).toList();

          print('Matching users: ${matchingUsers.length}');

          userResults.addAll(
            matchingUsers.map(
              (user) => SearchResult(
                id: user.id,
                title: user.name,
                subtitle: user.email,
                imageUrl: user.profileImageUrl,
                type: SearchResultType.user,
                data: user,
              ),
            ),
          );

          final totalResults = [...eventResults, ...userResults];
          print('Total results: ${totalResults.length}');
          return AsyncValue.data(totalResults);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Updated Header Section with Search

class HeaderSection extends ConsumerStatefulWidget {
  const HeaderSection({super.key});

  @override
  ConsumerState<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends ConsumerState<HeaderSection> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    print(' HeaderSection initState');
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchResults = _searchFocusNode.hasFocus;
        print(' Search focus changed: $_showSearchResults');
      });
    });
  }

  @override
  void dispose() {
    print(' HeaderSection dispose');
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    print('Clearing search');
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final hasQuery = ref.watch(searchQueryProvider).isNotEmpty;

    print(
      'Building HeaderSection - hasQuery: $hasQuery, showResults: $_showSearchResults',
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackground(isDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDark),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: Column(
                children: [
                  // Search Bar Row
                  Row(
                    children: [
                      // Drawer Icon (only show on mobile)
                      if (ResponsiveHelper.isMobile(context))
                        InkWell(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getBorderRadius(context, baseRadius: 50),
                          ),
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Container(
                            width: ResponsiveHelper.getIconSize(context, baseSize: 40),
                            height: ResponsiveHelper.getIconSize(context, baseSize: 40),
                            decoration: BoxDecoration(
                              color: AppColors.getSurface(isDark),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getShadow(isDark),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.menu,
                              color: AppColors.getTextPrimary(isDark),
                              size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                            ),
                        ),
                      ),

                      SizedBox(
                        width: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),

                      // Search Bar
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.getSurface(isDark),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context, baseRadius: 50),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getShadow(isDark),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (value) {
                              print('Search input changed: "$value"');
                              ref.read(searchQueryProvider.notifier).state =
                                  value;
                            },
                            decoration: InputDecoration(
                              hintText: "Search events or users...",
                              hintStyle: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.getTextPrimary(isDark),
                                size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                              ),
                              suffixIcon: hasQuery
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: AppColors.getTextSecondary(isDark),
                                        size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                                      ),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.getSurface(isDark),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getBorderRadius(context, baseRadius: 50),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  mobile: 16,
                                  tablet: 20,
                                  desktop: 24,
                                ),
                                vertical: ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  mobile: 16,
                                  tablet: 20,
                                  desktop: 24,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getBorderRadius(context, baseRadius: 50),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getBorderRadius(context, baseRadius: 50),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.getPrimary(isDark),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 15,
                                desktop: 16,
                              ),
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),

                      // Filter Button
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusRound,
                        ),
                        onTap: () {
                          showFilterBottomSheet(
                            context,
                            onApplyFilters: () {
                              print("Filters applied");
                            },
                          );
                        },
                        child: Container(
                          width: ResponsiveHelper.getIconSize(context, baseSize: 40),
                          height: ResponsiveHelper.getIconSize(context, baseSize: 40),
                          decoration: BoxDecoration(
                            color: AppColors.getSurface(isDark),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getShadow(isDark),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.tune_outlined,
                                color: AppColors.getTextPrimary(isDark),
                                size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                              ),
                              Consumer(
                                builder: (context, ref, child) {
                                  final filter = ref.watch(eventFilterProvider);
                                  return filter.hasActiveFilters
                                      ? Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: AppColors.getError(isDark),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // if (!_showSearchResults) ...[
                  //   SizedBox(height: AppSizes.spacingXxl.h),

                  //   // Categories Row
                  //   // Row(
                  //   //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   //   children: [
                  //   //     _buildCategoryItem(
                  //   //       context: context,
                  //   //       isDark: isDark,
                  //   //       icon: '🔔',
                  //   //       label: 'Notification',
                  //   //       isSelected: true,
                  //   //     ),
                  //   //     _buildCategoryItem(
                  //   //       context: context,
                  //   //       isDark: isDark,
                  //   //       icon: '🎯',
                  //   //       label: 'Filter',
                  //   //       hasNewBadge: true,
                  //   //     ),
                  //   //     _buildCategoryItem(
                  //   //       context: context,
                  //   //       isDark: isDark,
                  //   //       icon: '⭐',
                  //   //       label: 'Popular',
                  //   //       hasNewBadge: true,
                  //   //     ),
                  //   //   ],
                  //   // ),
                  // ],
                  SizedBox(height: AppSizes.spacingMedium.h),
                ],
              ),
            ),

            // Search Results Dropdown
            if (_showSearchResults && hasQuery)
              searchResultsAsync.when(
                data: (results) {
                  print(' DATA received: ${results.length} results');
                  return SearchResultsDropdown(
                    results: results,
                    onResultTap: (result) {
                      print('Result tapped: ${result.title} (${result.type})');
                      _clearSearch();
                      if (result.type == SearchResultType.event) {
                        context.push('/event-detail', extra: result.data);
                      } else {
                        context.push('/user-profile', extra: result.data);
                      }
                    },
                    isDark: isDark,
                  );
                },
                loading: () {
                  print('⏳ LOADING state');
                  return Container(
                    padding: EdgeInsets.all(AppSizes.paddingXxl),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.getPrimary(isDark),
                        ),
                      ),
                    ),
                  );
                },
                error: (error, stack) {
                  print(' ERROR state: $error');
                  return Container(
                    padding: EdgeInsets.all(AppSizes.paddingXl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.getError(isDark),
                        ),
                        SizedBox(height: AppSizes.spacingMedium),
                        Text(
                          'Error loading results',
                          style: AppTextStyles.bodyMedium(
                            isDark: isDark,
                          ).copyWith(color: AppColors.getError(isDark)),
                        ),
                        SizedBox(height: AppSizes.spacingSmall),
                        Text(
                          error.toString(),
                          style: AppTextStyles.bodySmall(
                            isDark: isDark,
                          ).copyWith(color: AppColors.getTextSecondary(isDark)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

}

// PART 3: Search Results Dropdown

class SearchResultsDropdown extends StatelessWidget {
  final List<SearchResult> results;
  final Function(SearchResult) onResultTap;
  final bool isDark;

  const SearchResultsDropdown({
    super.key,
    required this.results,
    required this.onResultTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    print('Building SearchResultsDropdown with ${results.length} results');

    if (results.isEmpty) {
      print('No results to display');
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              'No results found',
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(color: AppColors.getTextSecondary(isDark)),
            ),
          ],
        ),
      );
    }

    final events = results
        .where((r) => r.type == SearchResultType.event)
        .toList();
    final users = results
        .where((r) => r.type == SearchResultType.user)
        .toList();

    print('Events: ${events.length}, Users: ${users.length}');

    // Calculate available height accounting for keyboard
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;
    final maxDropdownHeight =
        availableHeight * 0.4; // Use 40% of available height

    return Container(
      constraints: BoxConstraints(maxHeight: maxDropdownHeight),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        border: Border(
          top: BorderSide(color: AppColors.getBorder(isDark), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (events.isNotEmpty) ...[
              _SectionHeader(
                title: 'Events',
                count: events.length,
                icon: Icons.event_rounded,
                isDark: isDark,
              ),
              ...events.map(
                (result) => _SearchResultTile(
                  result: result,
                  isDark: isDark,
                  onTap: () => onResultTap(result),
                ),
              ),
              if (users.isNotEmpty)
                Divider(
                  height: 20,
                  thickness: 1,
                  color: AppColors.getBorder(isDark),
                ),
            ],
            if (users.isNotEmpty) ...[
              _SectionHeader(
                title: 'Users',
                count: users.length,
                icon: Icons.people_rounded,
                isDark: isDark,
              ),
              ...users.map(
                (result) => _SearchResultTile(
                  result: result,
                  isDark: isDark,
                  onTap: () => onResultTap(result),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingXl,
        AppSizes.paddingMedium,
        AppSizes.paddingXl,
        AppSizes.paddingSmall,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.getPrimary(isDark)),
          SizedBox(width: AppSizes.spacingSmall),
          Text(
            title,
            style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
              color: AppColors.getPrimary(isDark),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: AppSizes.spacingXs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.getPrimary(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall(isDark: isDark).copyWith(
                color: AppColors.getPrimary(isDark),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final bool isDark;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXxl,
          vertical: AppSizes.paddingMedium,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(isDark),
                    borderRadius: BorderRadius.circular(
                      result.type == SearchResultType.user
                          ? AppSizes.radiusRound
                          : AppSizes.radiusMedium,
                    ),
                    image:
                        result.imageUrl != null && result.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(result.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(
                      color: AppColors.getBorder(isDark),
                      width: 1.5,
                    ),
                  ),
                  child: result.imageUrl == null || result.imageUrl!.isEmpty
                      ? Icon(
                          result.type == SearchResultType.event
                              ? Icons.event_rounded
                              : Icons.person_rounded,
                          color: AppColors.getTextSecondary(isDark),
                          size: 24,
                        )
                      : null,
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: result.type == SearchResultType.event
                          ? AppColors.getPrimary(isDark)
                          : AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.getCard(isDark),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (result.type == SearchResultType.event
                                      ? AppColors.getPrimary(isDark)
                                      : AppColors.success)
                                  .withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      result.type == SearchResultType.event
                          ? Icons.event
                          : Icons.person,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: AppTextStyles.bodyMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        result.type == SearchResultType.event
                            ? Icons.location_on_outlined
                            : Icons.email_outlined,
                        size: 14,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          result.subtitle,
                          style: AppTextStyles.bodySmall(
                            isDark: isDark,
                          ).copyWith(color: AppColors.getTextSecondary(isDark)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.getTextSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}
