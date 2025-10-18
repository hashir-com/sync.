import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/events/data/models/category_model.dart';

import '../providers/category_providers.dart';
import '../providers/event_providers.dart';

class DescriptionDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    final tempController = TextEditingController(text: state.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCard(isDark),
        title: Text(
          'Event Description',
          style: AppTextStyles.titleLarge(isDark: isDark),
        ),
        content: TextFormField(
          controller: tempController,
          decoration: InputDecoration(
            hintText: 'Enter description...',
            hintStyle: AppTextStyles.bodyMedium(isDark: isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
          ),
          style: AppTextStyles.bodyLarge(isDark: isDark),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (tempController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Description cannot be empty')),
                );
                return;
              }
              notifier.setDescription(tempController.text);
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                color: AppColors.getPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MaxAttendeesDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    bool tempIsOpen = state.isOpenCapacity;

    final tempControllers = {
      'vip': TextEditingController(
        text: (state.categoryCapacities['vip'] ?? 0) > 0
            ? state.categoryCapacities['vip'].toString()
            : '',
      ),
      'premium': TextEditingController(
        text: (state.categoryCapacities['premium'] ?? 0) > 0
            ? state.categoryCapacities['premium'].toString()
            : '',
      ),
      'regular': TextEditingController(
        text: (state.categoryCapacities['regular'] ?? 0) > 0
            ? state.categoryCapacities['regular'].toString()
            : '',
      ),
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getCard(isDark),
          title: Text(
            'Max Attendees per Category',
            style: AppTextStyles.titleLarge(isDark: isDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: tempIsOpen,
                      onChanged: (v) {
                        setDialogState(() {
                          tempIsOpen = v ?? false;
                          if (tempIsOpen) {
                            tempControllers.forEach((_, ctrl) => ctrl.clear());
                          }
                        });
                      },
                      activeColor: AppColors.getPrimary(isDark),
                    ),
                    Text(
                      'Open Capacity (Unlimited)',
                      style: AppTextStyles.bodyLarge(isDark: isDark),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.spacingMedium),
                if (!tempIsOpen) ...[
                  _buildCapacityTile(
                    isDark: isDark,
                    title: (state.categoryCapacities['vip'] ?? 0) > 0
                        ? 'VIP: ${state.categoryCapacities['vip']} seats'
                        : 'Set VIP Capacity',
                    controller: tempControllers['vip']!,
                    hint: 'Enter VIP capacity (e.g., 50)',
                  ),
                  SizedBox(height: AppSizes.spacingSmall),
                  _buildCapacityTile(
                    isDark: isDark,
                    title: (state.categoryCapacities['premium'] ?? 0) > 0
                        ? 'Premium: ${state.categoryCapacities['premium']} seats'
                        : 'Set Premium Capacity',
                    controller: tempControllers['premium']!,
                    hint: 'Enter Premium capacity (e.g., 100)',
                  ),
                  SizedBox(height: AppSizes.spacingSmall),
                  _buildCapacityTile(
                    isDark: isDark,
                    title: (state.categoryCapacities['regular'] ?? 0) > 0
                        ? 'Regular: ${state.categoryCapacities['regular']} seats'
                        : 'Set Regular Capacity',
                    controller: tempControllers['regular']!,
                    hint: 'Enter Regular capacity (e.g., 200)',
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (tempIsOpen) {
                  notifier.setCategoryCapacity('vip', 99999);
                  notifier.setCategoryCapacity('premium', 99999);
                  notifier.setCategoryCapacity('regular', 99999);
                } else {
                  final vip = int.tryParse(tempControllers['vip']!.text.trim()) ?? 0;
                  final premium = int.tryParse(tempControllers['premium']!.text.trim()) ?? 0;
                  final regular = int.tryParse(tempControllers['regular']!.text.trim()) ?? 0;
                  if (vip + premium + regular <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Total capacity must be >0 or select open'),
                      ),
                    );
                    return;
                  }
                  notifier.setCategoryCapacity('vip', vip);
                  notifier.setCategoryCapacity('premium', premium);
                  notifier.setCategoryCapacity('regular', regular);
                }
                notifier.setOpenCapacity(tempIsOpen);
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                  color: AppColors.getPrimary(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCapacityTile({
    required bool isDark,
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    return ExpansionTile(
      title: Text(title, style: AppTextStyles.bodyLarge(isDark: isDark)),
      collapsedBackgroundColor: AppColors.getBackground(isDark),
      backgroundColor: AppColors.getBackground(isDark),
      children: [
        Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium(isDark: isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
            ),
            style: AppTextStyles.bodyLarge(isDark: isDark),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}

class PriceDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    bool tempIsFree = state.isFreeEvent;

    final tempIsFreeCategory = {
      'vip': (state.categoryPrices['vip'] ?? 0.0) == 0.0,
      'premium': (state.categoryPrices['premium'] ?? 0.0) == 0.0,
      'regular': (state.categoryPrices['regular'] ?? 0.0) == 0.0,
    };

    final tempControllers = {
      'vip': TextEditingController(
        text: (state.categoryPrices['vip'] ?? 0.0) > 0
            ? state.categoryPrices['vip']!.toStringAsFixed(2)
            : '',
      ),
      'premium': TextEditingController(
        text: (state.categoryPrices['premium'] ?? 0.0) > 0
            ? state.categoryPrices['premium']!.toStringAsFixed(2)
            : '',
      ),
      'regular': TextEditingController(
        text: (state.categoryPrices['regular'] ?? 0.0) > 0
            ? state.categoryPrices['regular']!.toStringAsFixed(2)
            : '',
      ),
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getCard(isDark),
          title: Text(
            'Ticket Price per Category',
            style: AppTextStyles.titleLarge(isDark: isDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: tempIsFree,
                      onChanged: (v) {
                        setDialogState(() {
                          tempIsFree = v ?? false;
                          if (tempIsFree) {
                            tempIsFreeCategory['vip'] = true;
                            tempIsFreeCategory['premium'] = true;
                            tempIsFreeCategory['regular'] = true;
                            tempControllers.forEach((_, ctrl) => ctrl.clear());
                          } else {
                            tempIsFreeCategory['vip'] = false;
                            tempIsFreeCategory['premium'] = false;
                            tempIsFreeCategory['regular'] = false;
                          }
                        });
                      },
                      activeColor: AppColors.getPrimary(isDark),
                    ),
                    Text(
                      'Mark All Categories as Free',
                      style: AppTextStyles.bodyLarge(isDark: isDark),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.spacingMedium),
                _buildPriceTile(
                  isDark: isDark,
                  state: state,
                  category: 'vip',
                  label: 'VIP',
                  tempIsFree: tempIsFree,
                  tempIsFreeCategory: tempIsFreeCategory,
                  controller: tempControllers['vip']!,
                  setDialogState: setDialogState,
                ),
                SizedBox(height: AppSizes.spacingSmall),
                _buildPriceTile(
                  isDark: isDark,
                  state: state,
                  category: 'premium',
                  label: 'Premium',
                  tempIsFree: tempIsFree,
                  tempIsFreeCategory: tempIsFreeCategory,
                  controller: tempControllers['premium']!,
                  setDialogState: setDialogState,
                ),
                SizedBox(height: AppSizes.spacingSmall),
                _buildPriceTile(
                  isDark: isDark,
                  state: state,
                  category: 'regular',
                  label: 'Regular',
                  tempIsFree: tempIsFree,
                  tempIsFreeCategory: tempIsFreeCategory,
                  controller: tempControllers['regular']!,
                  setDialogState: setDialogState,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final vip = tempIsFreeCategory['vip']!
                    ? 0.0
                    : (double.tryParse(
                            tempControllers['vip']!.text.trim().replaceAll('₹', '').replaceAll(',', '')) ??
                        0.0);
                final premium = tempIsFreeCategory['premium']!
                    ? 0.0
                    : (double.tryParse(
                            tempControllers['premium']!.text.trim().replaceAll('₹', '').replaceAll(',', '')) ??
                        0.0);
                final regular = tempIsFreeCategory['regular']!
                    ? 0.0
                    : (double.tryParse(
                            tempControllers['regular']!.text.trim().replaceAll('₹', '').replaceAll(',', '')) ??
                        0.0);

                final hasVipCapacity = (state.categoryCapacities['vip'] ?? 0) > 0;
                final hasPremiumCapacity = (state.categoryCapacities['premium'] ?? 0) > 0;
                final hasRegularCapacity = (state.categoryCapacities['regular'] ?? 0) > 0;

                bool isValid = true;
                String errorMessage = '';

                if (hasVipCapacity && !tempIsFreeCategory['vip']! && vip <= 0) {
                  isValid = false;
                  errorMessage = 'VIP has capacity but no price set. Set price or mark as free.';
                } else if (hasPremiumCapacity && !tempIsFreeCategory['premium']! && premium <= 0) {
                  isValid = false;
                  errorMessage = 'Premium has capacity but no price set. Set price or mark as free.';
                } else if (hasRegularCapacity && !tempIsFreeCategory['regular']! && regular <= 0) {
                  isValid = false;
                  errorMessage = 'Regular has capacity but no price set. Set price or mark as free.';
                }

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                  return;
                }

                notifier.setCategoryPrice('vip', vip);
                notifier.setCategoryPrice('premium', premium);
                notifier.setCategoryPrice('regular', regular);

                final allFree = vip == 0.0 && premium == 0.0 && regular == 0.0;
                notifier.setFree(allFree);

                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                  color: AppColors.getPrimary(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPriceTile({
    required bool isDark,
    required dynamic state,
    required String category,
    required String label,
    required bool tempIsFree,
    required Map<String, bool> tempIsFreeCategory,
    required TextEditingController controller,
    required StateSetter setDialogState,
  }) {
    return ExpansionTile(
      title: Text(
        (state.categoryPrices[category] ?? 0.0) > 0
            ? '$label: ₹${state.categoryPrices[category]!.toStringAsFixed(2)}'
            : 'Set $label Price',
        style: AppTextStyles.bodyLarge(isDark: isDark),
      ),
      collapsedBackgroundColor: AppColors.getBackground(isDark),
      backgroundColor: AppColors.getBackground(isDark),
      children: [
        Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: tempIsFreeCategory[category],
                    onChanged: tempIsFree
                        ? null
                        : (v) {
                            setDialogState(() {
                              tempIsFreeCategory[category] = v ?? false;
                              if (tempIsFreeCategory[category]!) {
                                controller.clear();
                              }
                            });
                          },
                    activeColor: AppColors.getPrimary(isDark),
                  ),
                  Text(
                    'Free $label Tickets',
                    style: AppTextStyles.bodyLarge(isDark: isDark),
                  ),
                ],
              ),
              if (!tempIsFreeCategory[category]!)
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter $label price (e.g., 500)',
                    hintStyle: AppTextStyles.bodyMedium(isDark: isDark),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                  ),
                  style: AppTextStyles.bodyLarge(isDark: isDark),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    final repository = ref.read(categoryRepositoryProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCard(isDark),
        title: Text(
          'Event Type',
          style: AppTextStyles.titleLarge(isDark: isDark),
        ),
        content: StreamBuilder<List<CategoryModel>>(
          stream: repository.getActiveCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: Center(child: CircularProgressIndicator(
                  color: AppColors.getPrimary(isDark),
                )),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.getError(isDark),
                      size: AppSizes.iconXxl,
                    ),
                    SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Failed to load categories',
                      style: AppTextStyles.bodyLarge(isDark: isDark),
                    ),
                  ],
                ),
              );
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: Text(
                  'No categories available',
                  style: AppTextStyles.bodyLarge(isDark: isDark),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: categories.map((category) {
                  return RadioListTile<String>(
                    title: Row(
                      children: [
                        if (category.icon != null && category.icon!.isNotEmpty) ...[
                          Text(
                            category.icon!,
                            style: TextStyle(fontSize: AppSizes.fontXl),
                          ),
                          SizedBox(width: AppSizes.spacingSmall),
                        ],
                        Expanded(
                          child: Text(
                            category.name,
                            style: AppTextStyles.bodyLarge(isDark: isDark),
                          ),
                        ),
                      ],
                    ),
                    value: category.name,
                    groupValue: state.category,
                    activeColor: AppColors.getPrimary(isDark),
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        notifier.setCategory(value);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateTimeDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() pickStart,
    Future<void> Function() pickEnd,
  ) {
    final isDark = ref.watch(themeProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(createEventNotifierProvider);

          return AlertDialog(
            backgroundColor: AppColors.getCard(isDark),
            title: Text(
              'Select Date & Time',
              style: AppTextStyles.titleLarge(isDark: isDark),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await pickStart();
                    if (context.mounted) {
                      DateTimeDialog.show(context, ref, pickStart, pickEnd);
                    }
                  },
                  icon: Icon(Icons.event, size: AppSizes.iconMedium),
                  label: Text(
                    state.startTime == null
                        ? 'Pick Start Time'
                        : DateFormat('dd MMM yyyy, HH:mm').format(state.startTime!),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimary(isDark),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.buttonPaddingHorizontal,
                      vertical: AppSizes.buttonPaddingVertical,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingMedium),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (state.startTime == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select start time first')),
                        );
                      }
                      return;
                    }
                    Navigator.pop(dialogContext);
                    await pickEnd();
                    if (context.mounted) {
                      DateTimeDialog.show(context, ref, pickStart, pickEnd);
                    }
                  },
                  icon: Icon(Icons.event_available, size: AppSizes.iconMedium),
                  label: Text(
                    state.endTime == null
                        ? 'Pick End Time'
                        : DateFormat('dd MMM yyyy, HH:mm').format(state.endTime!),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimary(isDark),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.buttonPaddingHorizontal,
                      vertical: AppSizes.buttonPaddingVertical,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (state.startTime == null || state.endTime == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select both start and end time')),
                      );
                    }
                    return;
                  }
                  if (state.startTime!.isAfter(state.endTime!)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('End time must be after start time')),
                      );
                    }
                    return;
                  }
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'Done',
                  style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                    color: AppColors.getPrimary(isDark),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}