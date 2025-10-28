// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                SizedBox(height: AppSizes.spacingMedium),

                //INDIVIDUAL CAPACITY SETTINGS
                if (!tempIsOpenCommon) ...[
                  Text(
                    'Individual Limits',
                    style: AppTextStyles.titleMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

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
                        _checkAutoCommonTick(
                          setDialogState,
                          tempIsOpenVip,
                          tempIsOpenPremium,
                          tempIsOpenRegular,
                        );
                      });
                    },
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

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
                        _checkAutoCommonTick(
                          setDialogState,
                          tempIsOpenVip,
                          tempIsOpenPremium,
                          tempIsOpenRegular,
                        );
                      });
                    },
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

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
                        _checkAutoCommonTick(
                          setDialogState,
                          tempIsOpenVip,
                          tempIsOpenPremium,
                          tempIsOpenRegular,
                        );
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
                style: AppTextStyles.labelLarge(
                  isDark: isDark,
                ).copyWith(color: AppColors.getTextSecondary(isDark)),
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
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onCommonChanged(!isOpenCommon),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
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
                      style: AppTextStyles.bodySmall(
                        isDark: isDark,
                      ).copyWith(color: AppColors.getTextSecondary(isDark)),
                    ),
                  ],
                ),
              ),
              if (isOpenCommon)
                Icon(
                  Icons.loop,
                  color: AppColors.getPrimary(isDark),
                  size: AppSizes.iconMedium,
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
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXs),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
                child: Icon(icon, color: iconColor, size: AppSizes.iconSmall),
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),
          InkWell(
            onTap: () => onOpenChanged(!isOpen),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXs),
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
            SizedBox(height: AppSizes.spacingSmall),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall(
                  isDark: isDark,
                ).copyWith(color: AppColors.getTextSecondary(isDark)),
                prefixIcon: Icon(
                  Icons.people_outline,
                  size: AppSizes.iconSmall,
                  color: AppColors.getTextSecondary(isDark),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(
                    color: AppColors.getPrimary(isDark),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
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
    final vipCapacity = isOpenVip
        ? 99999
        : (int.tryParse(controllers['vip']!.text.trim()) ?? 0);
    final premiumCapacity = isOpenPremium
        ? 99999
        : (int.tryParse(controllers['premium']!.text.trim()) ?? 0);
    final regularCapacity = isOpenRegular
        ? 99999
        : (int.tryParse(controllers['regular']!.text.trim()) ?? 0);

    final totalFiniteCapacity =
        (vipCapacity != 99999 ? vipCapacity : 0) +
        (premiumCapacity != 99999 ? premiumCapacity : 0) +
        (regularCapacity != 99999 ? regularCapacity : 0);

    // Validation
    if (totalFiniteCapacity <= 0 &&
        !isOpenVip &&
        !isOpenPremium &&
        !isOpenRegular) {
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
                //COMMON FREE OPTION (TOP)
                _buildCommonFreeTile(
                  isDark: isDark,
                  isFree: tempIsFree,
                  setDialogState: setDialogState,
                  onFreeChanged: (bool value) {
                    setDialogState(() {
                      tempIsFree = value;
                      if (value) {
                        //Set all individual free when common is selected
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
                ),
                SizedBox(height: AppSizes.spacingMedium),

                //INDIVIDUAL PRICE SETTINGS
                if (!tempIsFree) ...[
                  Text(
                    'Individual Prices',
                    style: AppTextStyles.titleMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

                  _buildPriceTile(
                    isDark: isDark,
                    title: 'VIP Tickets',
                    icon: Icons.star,
                    iconColor: AppColors.warning,
                    isFree: tempIsFreeCategory['vip']!,
                    controller: tempControllers['vip']!,
                    hint: 'VIP price',
                    setDialogState: setDialogState,
                    tempIsFree: tempIsFree,
                    tempIsFreeCategory: tempIsFreeCategory,
                    category: 'vip',
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

                  _buildPriceTile(
                    isDark: isDark,
                    title: 'Premium Tickets',
                    icon: Icons.diamond,
                    iconColor: AppColors.primary,
                    isFree: tempIsFreeCategory['premium']!,
                    controller: tempControllers['premium']!,
                    hint: 'Premium price',
                    setDialogState: setDialogState,
                    tempIsFree: tempIsFree,
                    tempIsFreeCategory: tempIsFreeCategory,
                    category: 'premium',
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

                  _buildPriceTile(
                    isDark: isDark,
                    title: 'Regular Tickets',
                    icon: Icons.person_outline,
                    iconColor: AppColors.secondary,
                    isFree: tempIsFreeCategory['regular']!,
                    controller: tempControllers['regular']!,
                    hint: 'Regular price',
                    setDialogState: setDialogState,
                    tempIsFree: tempIsFree,
                    tempIsFreeCategory: tempIsFreeCategory,
                    category: 'regular',
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

  //NEW: Common free tile
  static Widget _buildCommonFreeTile({
    required bool isDark,
    required bool isFree,
    required StateSetter setDialogState,
    required void Function(bool) onFreeChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onFreeChanged(!isFree),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
          child: Row(
            children: [
              Checkbox(
                value: isFree,
                onChanged: (v) => onFreeChanged(v ?? false),
                activeColor: AppColors.getPrimary(isDark),
                checkColor: Colors.white,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Event (All Categories Free)',
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getPrimary(isDark),
                      ),
                    ),
                    Text(
                      'No cost for VIP, Premium & Regular',
                      style: AppTextStyles.bodySmall(
                        isDark: isDark,
                      ).copyWith(color: AppColors.getTextSecondary(isDark)),
                    ),
                  ],
                ),
              ),
              if (isFree)
                Icon(
                  Icons.money,
                  color: AppColors.getPrimary(isDark),
                  size: AppSizes.iconMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }

  //UPDATED: Price tile (same as capacity but for prices)
  static Widget _buildPriceTile({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isFree,
    required TextEditingController controller,
    required String hint,
    required StateSetter setDialogState,
    required bool tempIsFree,
    required Map<String, bool> tempIsFreeCategory,
    required String category,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXs),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
                child: Icon(icon, color: iconColor, size: AppSizes.iconSmall),
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingSmall),
          InkWell(
            onTap: () => {
              if (!tempIsFree)
                setDialogState(() {
                  tempIsFreeCategory[category] = !isFree;
                  if (tempIsFreeCategory[category]!) {
                    controller.clear();
                  }
                }),
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXs),
              child: Row(
                children: [
                  Checkbox(
                    value: isFree,
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
                    checkColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Free $title',
                      style: AppTextStyles.bodyMedium(isDark: isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isFree) ...[
            SizedBox(height: AppSizes.spacingSmall),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall(
                  isDark: isDark,
                ).copyWith(color: AppColors.getTextSecondary(isDark)),
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(
                    color: AppColors.getPrimary(isDark),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                filled: true,
                fillColor: AppColors.getSurface(isDark),
                counterText: '',
              ),
              style: AppTextStyles.bodyLarge(isDark: isDark),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
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
                          icon: Icon(Icons.refresh, size: AppSizes.iconSmall),
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
                          icon: Icon(Icons.close, size: AppSizes.iconSmall),
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
                                  fontSize: AppSizes.fontXl,
                                  fontWeight: FontWeight.w600,
                                ),
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
