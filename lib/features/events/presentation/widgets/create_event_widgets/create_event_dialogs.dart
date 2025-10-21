// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/events/data/models/category_model.dart';

import '../../providers/category_providers.dart';
import '../../providers/event_providers.dart';

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
              style: AppTextStyles.labelLarge(
                isDark: isDark,
              ).copyWith(color: AppColors.getTextSecondary(isDark)),
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
              style: AppTextStyles.labelLarge(
                isDark: isDark,
              ).copyWith(color: AppColors.getPrimary(isDark)),
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

    // Temp state for dialog
    bool tempIsOpenCommon = state.isOpenCapacity;
    bool tempIsOpenVip = false;
    bool tempIsOpenPremium = false;
    bool tempIsOpenRegular = false;

    // Determine individual open status based on capacity values
    tempIsOpenVip = (state.categoryCapacities['vip'] ?? 0) == 99999;
    tempIsOpenPremium = (state.categoryCapacities['premium'] ?? 0) == 99999;
    tempIsOpenRegular = (state.categoryCapacities['regular'] ?? 0) == 99999;

    //AUTO-TICK COMMON if all 3 were already unlimited
    if (tempIsOpenVip && tempIsOpenPremium && tempIsOpenRegular) {
      tempIsOpenCommon = true;
    }

    final tempControllers = {
      'vip': TextEditingController(
        text: (state.categoryCapacities['vip'] ?? 0) != 99999
            ? (state.categoryCapacities['vip'] ?? 0).toString()
            : '',
      ),
      'premium': TextEditingController(
        text: (state.categoryCapacities['premium'] ?? 0) != 99999
            ? (state.categoryCapacities['premium'] ?? 0).toString()
            : '',
      ),
      'regular': TextEditingController(
        text: (state.categoryCapacities['regular'] ?? 0) != 99999
            ? (state.categoryCapacities['regular'] ?? 0).toString()
            : '',
      ),
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getCard(isDark),
          title: Text(
            'Capacity Settings',
            style: AppTextStyles.titleLarge(isDark: isDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //COMMON OPEN CAPACITY OPTION (TOP)
                _buildCommonCapacityTile(
                  isDark: isDark,
                  isOpenCommon: tempIsOpenCommon,
                  setDialogState: setDialogState,
                  onCommonChanged: (bool value) {
                    setDialogState(() {
                      tempIsOpenCommon = value;
                      if (value) {
                        //Clear all individual when common is selected
                        tempIsOpenVip = false;
                        tempIsOpenPremium = false;
                        tempIsOpenRegular = false;
                        tempControllers.forEach((_, ctrl) => ctrl.clear());
                      }
                    });
                  },
                ),
                SizedBox(height: AppSizes.spacingMedium.h),

                //INDIVIDUAL CAPACITY SETTINGS
                if (!tempIsOpenCommon) ...[
                  Text(
                    'Individual Limits',
                    style: AppTextStyles.titleMedium(isDark: isDark)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSizes.spacingSmall.h),

                  _buildCapacityTile(
                    isDark: isDark,
                    title: 'VIP Tickets',
                    icon: Icons.star,
                    iconColor: AppColors.warning,
                    isOpen: tempIsOpenVip,
                    controller: tempControllers['vip']!,
                    hint: 'VIP capacity',
                    setDialogState: setDialogState,
                    onOpenChanged: (bool? isOpen) {
                      setDialogState(() {
                        tempIsOpenVip = isOpen ?? false;
                        if (tempIsOpenVip) {
                          tempControllers['vip']!.clear();
                        }
                        //AUTO-TICK COMMON IF ALL 3 ARE UNLIMITED
                        _checkAutoCommonTick(setDialogState, tempIsOpenVip, tempIsOpenPremium, tempIsOpenRegular);
                      });
                    },
                  ),
                  SizedBox(height: AppSizes.spacingSmall.h),

                  _buildCapacityTile(
                    isDark: isDark,
                    title: 'Premium Tickets',
                    icon: Icons.diamond,
                    iconColor: AppColors.primary,
                    isOpen: tempIsOpenPremium,
                    controller: tempControllers['premium']!,
                    hint: 'Premium capacity',
                    setDialogState: setDialogState,
                    onOpenChanged: (bool? isOpen) {
                      setDialogState(() {
                        tempIsOpenPremium = isOpen ?? false;
                        if (tempIsOpenPremium) {
                          tempControllers['premium']!.clear();
                        }
                        //AUTO-TICK COMMON IF ALL 3 ARE UNLIMITED
                        _checkAutoCommonTick(setDialogState, tempIsOpenVip, tempIsOpenPremium, tempIsOpenRegular);
                      });
                    },
                  ),
                  SizedBox(height: AppSizes.spacingSmall.h),

                  _buildCapacityTile(
                    isDark: isDark,
                    title: 'Regular Tickets',
                    icon: Icons.person_outline,
                    iconColor: AppColors.secondary,
                    isOpen: tempIsOpenRegular,
                    controller: tempControllers['regular']!,
                    hint: 'Regular capacity',
                    setDialogState: setDialogState,
                    onOpenChanged: (bool? isOpen) {
                      setDialogState(() {
                        tempIsOpenRegular = isOpen ?? false;
                        if (tempIsOpenRegular) {
                          tempControllers['regular']!.clear();
                        }
                        //AUTO-TICK COMMON IF ALL 3 ARE UNLIMITED
                        _checkAutoCommonTick(setDialogState, tempIsOpenVip, tempIsOpenPremium, tempIsOpenRegular);
                      });
                    },
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
                style: AppTextStyles.labelLarge(isDark: isDark)
                    .copyWith(color: AppColors.getTextSecondary(isDark)),
              ),
            ),
            TextButton(
              onPressed: () {
                _saveCapacities(
                  context,
                  notifier,
                  tempIsOpenCommon,
                  tempIsOpenVip,
                  tempIsOpenPremium,
                  tempIsOpenRegular,
                  tempControllers,
                  state,
                );
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: AppTextStyles.labelLarge(isDark: isDark)
                    .copyWith(color: AppColors.getPrimary(isDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //HELPER: Auto-tick common if all 3 individual are unlimited
  static void _checkAutoCommonTick(
    StateSetter setDialogState,
    bool vipOpen,
    bool premiumOpen,
    bool regularOpen,
  ) {
    if (vipOpen && premiumOpen && regularOpen) {
      setDialogState(() {
        // Auto-enable common when all 3 are unlimited
        // This will be handled in save logic
      });
    }
  }

  //NEW: Common capacity tile
  static Widget _buildCommonCapacityTile({
    required bool isDark,
    required bool isOpenCommon,
    required StateSetter setDialogState,
    required void Function(bool) onCommonChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMedium.w),
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onCommonChanged(!isOpenCommon),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall.w),
          child: Row(
            children: [
              Checkbox(
                value: isOpenCommon,
                onChanged: (v) => onCommonChanged(v ?? false),
                activeColor: AppColors.getPrimary(isDark),
                checkColor: Colors.white,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open Capacity (All Unlimited)',
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Unlimited attendees for VIP, Premium & Regular',
                      style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOpenCommon)
                Icon(
                  Icons.loop,
                  color: AppColors.getPrimary(isDark),
                  size: AppSizes.iconMedium.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  //UPDATED: Capacity tile (same as before but cleaner)
  static Widget _buildCapacityTile({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isOpen,
    required TextEditingController controller,
    required String hint,
    required StateSetter setDialogState,
    required void Function(bool?) onOpenChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMedium.w),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXs.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound.r),
                ),
                child: Icon(icon, color: iconColor, size: AppSizes.iconSmall.sp),
              ),
              SizedBox(width: AppSizes.spacingSmall.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium(isDark: isDark)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall.h),
          InkWell(
            onTap: () => onOpenChanged(!isOpen),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXs.h),
              child: Row(
                children: [
                  Checkbox(
                    value: isOpen,
                    onChanged: onOpenChanged,
                    activeColor: AppColors.getPrimary(isDark),
                    checkColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Unlimited ($title)',
                      style: AppTextStyles.bodyMedium(isDark: isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isOpen) ...[
            SizedBox(height: AppSizes.spacingSmall.h),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall(isDark: isDark)
                    .copyWith(color: AppColors.getTextSecondary(isDark)),
                prefixIcon: Icon(
                  Icons.people_outline,
                  size: AppSizes.iconSmall.sp,
                  color: AppColors.getTextSecondary(isDark),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                  borderSide: BorderSide(
                    color: AppColors.getPrimary(isDark),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium.w,
                  vertical: AppSizes.paddingSmall.h,
                ),
                filled: true,
                fillColor: AppColors.getSurface(isDark),
                counterText: '',
              ),
              style: AppTextStyles.bodyLarge(isDark: isDark),
              keyboardType: TextInputType.number,
              inputFormatters: [],
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final num = int.tryParse(value.trim());
                if (num != null && num <= 0) {
                  return 'Capacity must be greater than 0';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  //IMPROVED SAVE LOGIC
  static void _saveCapacities(
    BuildContext context,
    dynamic notifier,
    bool isOpenCommon,
    bool isOpenVip,
    bool isOpenPremium,
    bool isOpenRegular,
    Map<String, TextEditingController> controllers,
    dynamic state,
  ) {
    if (isOpenCommon || (isOpenVip && isOpenPremium && isOpenRegular)) {
      //ALL UNLIMITED - Use common open capacity
      notifier.setCategoryCapacity('vip', 99999);
      notifier.setCategoryCapacity('premium', 99999);
      notifier.setCategoryCapacity('regular', 99999);
      notifier.setOpenCapacity(true);
      return;
    }

    // Individual capacities
    final vipCapacity = isOpenVip ? 99999 : (int.tryParse(controllers['vip']!.text.trim()) ?? 0);
    final premiumCapacity = isOpenPremium ? 99999 : (int.tryParse(controllers['premium']!.text.trim()) ?? 0);
    final regularCapacity = isOpenRegular ? 99999 : (int.tryParse(controllers['regular']!.text.trim()) ?? 0);

    final totalFiniteCapacity = (vipCapacity != 99999 ? vipCapacity : 0) +
        (premiumCapacity != 99999 ? premiumCapacity : 0) +
        (regularCapacity != 99999 ? regularCapacity : 0);

    // Validation
    if (totalFiniteCapacity <= 0 && !isOpenVip && !isOpenPremium && !isOpenRegular) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set at least one capacity limit')),
      );
      return;
    }

    notifier.setCategoryCapacity('vip', vipCapacity);
    notifier.setCategoryCapacity('premium', premiumCapacity);
    notifier.setCategoryCapacity('regular', regularCapacity);
    notifier.setOpenCapacity(false);
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
                style: AppTextStyles.labelLarge(
                  isDark: isDark,
                ).copyWith(color: AppColors.getTextSecondary(isDark)),
              ),
            ),
            TextButton(
              onPressed: () {
                final vip = tempIsFreeCategory['vip']!
                    ? 0.0
                    : (double.tryParse(
                            tempControllers['vip']!.text
                                .trim()
                                .replaceAll('₹', '')
                                .replaceAll(',', ''),
                          ) ??
                          0.0);
                final premium = tempIsFreeCategory['premium']!
                    ? 0.0
                    : (double.tryParse(
                            tempControllers['premium']!.text
                                .trim()
                                .replaceAll('₹', '')
                                .replaceAll(',', ''),
                          ) ??
                          0.0);
                final regular = tempIsFreeCategory['regular']!
                    ? 0.0
                    : (double.tryParse(
                            tempControllers['regular']!.text
                                .trim()
                                .replaceAll('₹', '')
                                .replaceAll(',', ''),
                          ) ??
                          0.0);

                final hasVipCapacity =
                    (state.categoryCapacities['vip'] ?? 0) > 0;
                final hasPremiumCapacity =
                    (state.categoryCapacities['premium'] ?? 0) > 0;
                final hasRegularCapacity =
                    (state.categoryCapacities['regular'] ?? 0) > 0;

                bool isValid = true;
                String errorMessage = '';

                if (hasVipCapacity && !tempIsFreeCategory['vip']! && vip <= 0) {
                  isValid = false;
                  errorMessage =
                      'VIP has capacity but no price set. Set price or mark as free.';
                } else if (hasPremiumCapacity &&
                    !tempIsFreeCategory['premium']! &&
                    premium <= 0) {
                  isValid = false;
                  errorMessage =
                      'Premium has capacity but no price set. Set price or mark as free.';
                } else if (hasRegularCapacity &&
                    !tempIsFreeCategory['regular']! &&
                    regular <= 0) {
                  isValid = false;
                  errorMessage =
                      'Regular has capacity but no price set. Set price or mark as free.';
                }

                if (!isValid) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(errorMessage)));
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
                style: AppTextStyles.labelLarge(
                  isDark: isDark,
                ).copyWith(color: AppColors.getPrimary(isDark)),
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
                      borderSide: BorderSide(
                        color: AppColors.getBorder(isDark),
                      ),
                    ),
                  ),
                  style: AppTextStyles.bodyLarge(isDark: isDark),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    final repository = ref.read(categoryRepositoryProvider);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Consumer(
        builder: (context, ref, child) {
          // Move theme watch INSIDE Consumer
          final isDark = ref.watch(themeProvider);

          return AlertDialog(
            backgroundColor: AppColors.getCard(isDark),
            title: Text(
              'Event Type',
              style: AppTextStyles.titleLarge(isDark: isDark),
            ),
            content: StreamBuilder<List<CategoryModel>>(
              stream: repository.getActiveCategories(),
              builder: (context, snapshot) {
                // Use dialogContext for navigation, not outer context
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.all(AppSizes.paddingXl),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.getPrimary(isDark),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('CategoryDialog Error: ${snapshot.error}');
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
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSizes.spacingSmall),
                        // Retry button
                        TextButton.icon(
                          onPressed: () {
                            // Trigger rebuild by invalidating category provider
                            ref.invalidate(categoryRepositoryProvider);
                          },
                          icon: Icon(
                            Icons.refresh,
                            size: AppSizes.iconSmall.sp,
                          ),
                          label: Text(
                            'Retry',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final categories = snapshot.data ?? [];

                if (categories.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(AppSizes.paddingXl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: AppColors.getTextSecondary(isDark),
                          size: AppSizes.iconXxl,
                        ),
                        SizedBox(height: AppSizes.spacingSmall),
                        Text(
                          'No categories available',
                          style: AppTextStyles.bodyLarge(isDark: isDark),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSizes.spacingMedium),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(Icons.close, size: AppSizes.iconSmall.sp),
                          label: Text(
                            'Close',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                        ),
                      ],
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
                            if (category.icon != null &&
                                category.icon!.isNotEmpty) ...[
                              Text(
                                category.icon!,
                                style: TextStyle(
                                  fontSize: AppSizes.fontXl.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: AppSizes.spacingSmall.w),
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
                        dense: true,
                        onChanged: (String? value) {
                          if (value != null && value.isNotEmpty) {
                            notifier.setCategory(value);
                            Navigator.pop(dialogContext); // Use dialogContext
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
                onPressed: () =>
                    Navigator.pop(dialogContext), // Use dialogContext
                child: Text(
                  'Cancel',
                  style: AppTextStyles.labelLarge(
                    isDark: isDark,
                  ).copyWith(color: AppColors.getTextSecondary(isDark)),
                ),
              ),
            ],
          );
        },
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
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(state.startTime!),
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
                          const SnackBar(
                            content: Text('Please select start time first'),
                          ),
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
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(state.endTime!),
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
                        const SnackBar(
                          content: Text(
                            'Please select both start and end time',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (state.startTime!.isAfter(state.endTime!)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('End time must be after start time'),
                        ),
                      );
                    }
                    return;
                  }
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'Done',
                  style: AppTextStyles.labelLarge(
                    isDark: isDark,
                  ).copyWith(color: AppColors.getPrimary(isDark)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
