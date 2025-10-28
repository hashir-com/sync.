// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';

// Filter Model
class EventFilter {
  final List<String> selectedCategories;
  final String? selectedLocation;
  final DateRange? dateRange;
  final PriceRange priceRange;
  final String? selectedDatePreset; // 'today', 'tomorrow', 'this_week'

  EventFilter({
    this.selectedCategories = const [],
    this.selectedLocation,
    this.dateRange,
    PriceRange? priceRange,
    this.selectedDatePreset,
  }) : priceRange = priceRange ?? PriceRange(min: 0, max: 100000);

  EventFilter copyWith({
    List<String>? selectedCategories,
    String? selectedLocation,
    DateRange? dateRange,
    PriceRange? priceRange,
    String? selectedDatePreset,
    bool clearLocation = false,
    bool clearDateRange = false,
    bool clearDatePreset = false,
  }) {
    return EventFilter(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedLocation: clearLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      priceRange: priceRange ?? this.priceRange,
      selectedDatePreset: clearDatePreset
          ? null
          : (selectedDatePreset ?? this.selectedDatePreset),
    );
  }

  bool get hasActiveFilters =>
      selectedCategories.isNotEmpty ||
      selectedLocation != null ||
      dateRange != null ||
      selectedDatePreset != null ||
      (priceRange.min > 0 || priceRange.max < 100000);
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

class PriceRange {
  final double min;
  final double max;

  PriceRange({required this.min, required this.max});
}

// Filter Provider
final eventFilterProvider =
    StateNotifierProvider<EventFilterNotifier, EventFilter>((ref) {
      return EventFilterNotifier();
    });

class EventFilterNotifier extends StateNotifier<EventFilter> {
  EventFilterNotifier() : super(EventFilter());

  void updateCategories(List<String> categories) {
    state = state.copyWith(selectedCategories: categories);
  }

  void toggleCategory(String category) {
    final updated = List<String>.from(state.selectedCategories);
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    state = state.copyWith(selectedCategories: updated);
  }

  void updateLocation(String location) {
    state = state.copyWith(selectedLocation: location);
  }

  void clearLocation() {
    state = state.copyWith(clearLocation: true);
  }

  void updateDateRange(DateRange? dateRange) {
    state = state.copyWith(dateRange: dateRange, clearDatePreset: true);
  }

  void updateDatePreset(String preset) {
    DateTime start;
    DateTime end;
    final now = DateTime.now();

    switch (preset) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'tomorrow':
        final tomorrow = now.add(Duration(days: 1));
        start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        end = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);
        break;
      case 'this_week':
        start = now;
        end = now.add(Duration(days: 7));
        break;
      default:
        return;
    }

    state = state.copyWith(
      dateRange: DateRange(start: start, end: end),
      selectedDatePreset: preset,
    );
  }

  void updatePriceRange(double min, double max) {
    state = state.copyWith(
      priceRange: PriceRange(min: min, max: max),
    );
  }

  void reset() {
    state = EventFilter();
  }
}

// Provider to get unique categories from events
final uniqueCategoriesProvider = Provider<List<String>>((ref) {
  final eventsAsync = ref.watch(approvedEventsStreamProvider);
  return eventsAsync.when(
    data: (events) {
      final categories = events
          .map((event) => event.category as String?)
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      categories.sort();
      return categories;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Filter Bottom Sheet
class FilterBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onApplyFilters;

  const FilterBottomSheet({super.key, required this.onApplyFilters});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    final filter = ref.watch(eventFilterProvider);

    return FadeTransition(
      opacity: _fadeController.drive(Tween(begin: 0.0, end: 1.0)),
      child: SlideTransition(
        position: _slideController.drive(
          Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getCard(isDark),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXxl),
              topRight: Radius.circular(AppSizes.radiusXxl),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMedium,
                    ),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.getTextSecondary(isDark),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingXl,
                          vertical: AppSizes.paddingLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filter',
                                  style: AppTextStyles.headingSmall(
                                    isDark: isDark,
                                  ),
                                ),
                                if (filter.hasActiveFilters)
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(eventFilterProvider.notifier)
                                          .reset();
                                    },
                                    child: Text(
                                      'Clear All',
                                      style:
                                          AppTextStyles.bodyMedium(
                                            isDark: isDark,
                                          ).copyWith(
                                            color: AppColors.getError(isDark),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: AppSizes.spacingXl),

                            // Categories
                            _FilterSection(
                              title: 'Category',
                              isDark: isDark,
                              child: _CategoriesFilter(isDark: isDark),
                            ),

                            SizedBox(height: AppSizes.spacingXxl),

                            // Time & Date
                            _FilterSection(
                              title: 'Time & Date',
                              isDark: isDark,
                              child: _DateFilter(isDark: isDark),
                            ),

                            SizedBox(height: AppSizes.spacingXxl),

                            // Location
                            _FilterSection(
                              title: 'Location',
                              isDark: isDark,
                              child: _LocationFilter(isDark: isDark),
                            ),

                            SizedBox(height: AppSizes.spacingXxl),

                            // Price Range
                            _FilterSection(
                              title: 'Select price range',
                              isDark: isDark,
                              child: _PriceRangeFilter(isDark: isDark),
                            ),

                            SizedBox(height: AppSizes.spacingXxl),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      ref
                                          .read(eventFilterProvider.notifier)
                                          .reset();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSizes.paddingLarge,
                                      ),
                                      side: BorderSide(
                                        color: AppColors.getBorder(isDark),
                                      ),
                                    ),
                                    child: Text(
                                      'RESET',
                                      style: AppTextStyles.labelMedium(
                                        isDark: isDark,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSizes.spacingMedium),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      widget.onApplyFilters();
                                      context.go('/events');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.getPrimary(
                                        isDark,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSizes.paddingLarge,
                                      ),
                                    ),
                                    child: Text(
                                      'APPLY',
                                      style:
                                          AppTextStyles.labelMedium(
                                            isDark: isDark,
                                          ).copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizes.spacingLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Filter Section Component
class _FilterSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium(
            isDark: isDark,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSizes.spacingMedium),
        child,
      ],
    );
  }
}

// Categories Filter - Now pulls from actual events
class _CategoriesFilter extends ConsumerWidget {
  final bool isDark;

  const _CategoriesFilter({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);
    final categories = ref.watch(uniqueCategoriesProvider);

    if (categories.isEmpty) {
      return Text(
        'No categories available',
        style: AppTextStyles.bodySmall(
          isDark: isDark,
        ).copyWith(color: AppColors.getTextSecondary(isDark)),
      );
    }

    return Wrap(
      spacing: AppSizes.spacingSmall,
      runSpacing: AppSizes.spacingSmall,
      children: categories.map((category) {
        final isSelected = filter.selectedCategories.contains(category);
        return FilterChip(
          selected: isSelected,
          label: Text(category),
          onSelected: (_) {
            ref.read(eventFilterProvider.notifier).toggleCategory(category);
          },
          backgroundColor: AppColors.getSurface(isDark),
          selectedColor: AppColors.getPrimary(isDark).withOpacity(0.2),
          labelStyle: AppTextStyles.bodySmall(isDark: isDark).copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.getPrimary(isDark)
                : AppColors.getTextPrimary(isDark),
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.getPrimary(isDark)
                : AppColors.getBorder(isDark),
          ),
        );
      }).toList(),
    );
  }
}

// Date Filter - Now functional
class _DateFilter extends ConsumerWidget {
  final bool isDark;

  const _DateFilter({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DatePresetButton(
                label: 'Today',
                isSelected: filter.selectedDatePreset == 'today',
                isDark: isDark,
                onPressed: () {
                  ref
                      .read(eventFilterProvider.notifier)
                      .updateDatePreset('today');
                },
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: _DatePresetButton(
                label: 'Tomorrow',
                isSelected: filter.selectedDatePreset == 'tomorrow',
                isDark: isDark,
                onPressed: () {
                  ref
                      .read(eventFilterProvider.notifier)
                      .updateDatePreset('tomorrow');
                },
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: _DatePresetButton(
                label: 'This week',
                isSelected: filter.selectedDatePreset == 'this_week',
                isDark: isDark,
                onPressed: () {
                  ref
                      .read(eventFilterProvider.notifier)
                      .updateDatePreset('this_week');
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingMedium),
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.getPrimary(isDark),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              ref
                  .read(eventFilterProvider.notifier)
                  .updateDateRange(
                    DateRange(start: picked.start, end: picked.end),
                  );
            }
          },
          child: Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.getBorder(isDark)),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.getPrimary(isDark),
                  size: AppSizes.iconSmall,
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    filter.dateRange != null &&
                            filter.selectedDatePreset == null
                        ? '${_formatDate(filter.dateRange!.start)} - ${_formatDate(filter.dateRange!.end)}'
                        : 'Choose from calendar',
                    style: AppTextStyles.bodySmall(isDark: isDark),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSmall,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DatePresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onPressed;

  const _DatePresetButton({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        backgroundColor: isSelected
            ? AppColors.getPrimary(isDark)
            : Colors.transparent,
        side: BorderSide(
          color: isSelected
              ? AppColors.getPrimary(isDark)
              : AppColors.getBorder(isDark),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.getTextPrimary(isDark),
        ),
      ),
    );
  }
}

// Location Filter - Now opens map
class _LocationFilter extends ConsumerWidget {
  final bool isDark;

  const _LocationFilter({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);

    return InkWell(
      onTap: () async {
        final result = await context.push('/location-picker');
        if (result != null) {
          // Handle both Map (from location picker) and String formats
          String? address;
          if (result is Map) {
            address = result['address'] as String?;
          } else if (result is String) {
            address = result;
          }

          if (address != null && address.isNotEmpty) {
            ref.read(eventFilterProvider.notifier).updateLocation(address);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.getBorder(isDark)),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          color: AppColors.getSurface(isDark),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: AppColors.getPrimary(isDark),
              size: AppSizes.iconSmall,
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: Text(
                filter.selectedLocation ?? 'Select location',
                style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                  color: filter.selectedLocation != null
                      ? AppColors.getTextPrimary(isDark)
                      : AppColors.getTextSecondary(isDark),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filter.selectedLocation != null)
              InkWell(
                onTap: () {
                  ref.read(eventFilterProvider.notifier).clearLocation();
                },
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppSizes.iconSmall,
                color: AppColors.getTextSecondary(isDark),
              ),
          ],
        ),
      ),
    );
  }
}

// Price Range Filter - Using Riverpod
class _PriceRangeFilter extends ConsumerWidget {
  final bool isDark;

  const _PriceRangeFilter({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${filter.priceRange.min.toInt()} - ₹${filter.priceRange.max.toInt()}',
              style: AppTextStyles.titleSmall(isDark: isDark).copyWith(
                color: AppColors.getPrimary(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingMedium),
        RangeSlider(
          values: RangeValues(filter.priceRange.min, filter.priceRange.max),
          min: 0,
          max: 100000,
          divisions: 20,
          activeColor: AppColors.getPrimary(isDark),
          inactiveColor: AppColors.getBorder(isDark),
          onChanged: (RangeValues values) {
            ref
                .read(eventFilterProvider.notifier)
                .updatePriceRange(values.start, values.end);
          },
        ),
      ],
    );
  }
}

// Helper function to show filter sheet
void showFilterBottomSheet(
  BuildContext context, {
  required VoidCallback onApplyFilters,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) => FilterBottomSheet(onApplyFilters: onApplyFilters),
  );
}
