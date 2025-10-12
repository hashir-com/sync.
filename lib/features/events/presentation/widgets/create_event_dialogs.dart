import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import '../providers/event_providers.dart';

class DescriptionDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    final tempController = TextEditingController(text: state.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text(
          'Event Description',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: TextFormField(
          controller: tempController,
          decoration: InputDecoration(
            hintText: 'Enter description...',
            hintStyle: TextStyle(color: colors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
          style: TextStyle(color: colors.textPrimary),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
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
            child: Text('Save', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class MaxAttendeesDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
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
          backgroundColor: colors.cardBackground,
          title: Text(
            'Max Attendees per Category',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Column(
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
                    activeColor: colors.primary,
                  ),
                  Text(
                    'Open Capacity (Unlimited)',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!tempIsOpen) ...[
                ExpansionTile(
                  title: Text(
                    (state.categoryCapacities['vip'] ?? 0) > 0
                        ? 'VIP: ${state.categoryCapacities['vip']} seats'
                        : 'Set VIP Capacity',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  collapsedBackgroundColor: colors.background,
                  backgroundColor: colors.background,
                  children: [
                    TextFormField(
                      controller: tempControllers['vip'],
                      decoration: InputDecoration(
                        hintText: 'Enter VIP capacity (e.g., 50)',
                        hintStyle: TextStyle(color: colors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.border),
                        ),
                      ),
                      style: TextStyle(color: colors.textPrimary),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: Text(
                    (state.categoryCapacities['premium'] ?? 0) > 0
                        ? 'Premium: ${state.categoryCapacities['premium']} seats'
                        : 'Set Premium Capacity',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  collapsedBackgroundColor: colors.background,
                  backgroundColor: colors.background,
                  children: [
                    TextFormField(
                      controller: tempControllers['premium'],
                      decoration: InputDecoration(
                        hintText: 'Enter Premium capacity (e.g., 100)',
                        hintStyle: TextStyle(color: colors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.border),
                        ),
                      ),
                      style: TextStyle(color: colors.textPrimary),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: Text(
                    (state.categoryCapacities['regular'] ?? 0) > 0
                        ? 'Regular: ${state.categoryCapacities['regular']} seats'
                        : 'Set Regular Capacity',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  collapsedBackgroundColor: colors.background,
                  backgroundColor: colors.background,
                  children: [
                    TextFormField(
                      controller: tempControllers['regular'],
                      decoration: InputDecoration(
                        hintText: 'Enter Regular capacity (e.g., 200)',
                        hintStyle: TextStyle(color: colors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.border),
                        ),
                      ),
                      style: TextStyle(color: colors.textPrimary),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                if (tempIsOpen) {
                  // Explicitly set capacities to 0 when open (unlimited)
                  notifier.setCategoryCapacity('vip', 0);
                  notifier.setCategoryCapacity('premium', 0);
                  notifier.setCategoryCapacity('regular', 0);
                } else {
                  final vip =
                      int.tryParse(tempControllers['vip']!.text.trim()) ?? 0;
                  final premium =
                      int.tryParse(tempControllers['premium']!.text.trim()) ??
                      0;
                  final regular =
                      int.tryParse(tempControllers['regular']!.text.trim()) ??
                      0;
                  if (vip + premium + regular <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Total capacity must be >0 or select open',
                        ),
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
              child: Text('Save', style: TextStyle(color: colors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    bool tempIsFree = state.isFreeEvent;

    // Track which categories are free individually
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
          backgroundColor: colors.cardBackground,
          title: Text(
            'Ticket Price per Category',
            style: TextStyle(color: colors.textPrimary),
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
                            // Mark all categories as free
                            tempIsFreeCategory['vip'] = true;
                            tempIsFreeCategory['premium'] = true;
                            tempIsFreeCategory['regular'] = true;
                            tempControllers.forEach((_, ctrl) => ctrl.clear());
                          } else {
                            // Unmark all categories
                            tempIsFreeCategory['vip'] = false;
                            tempIsFreeCategory['premium'] = false;
                            tempIsFreeCategory['regular'] = false;
                          }
                        });
                      },
                      activeColor: colors.primary,
                    ),
                    Text(
                      'Mark All Categories as Free',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // VIP Category
                ExpansionTile(
                  title: Text(
                    (state.categoryPrices['vip'] ?? 0.0) > 0
                        ? 'VIP: ₹${state.categoryPrices['vip']!.toStringAsFixed(2)}'
                        : 'Set VIP Price',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  collapsedBackgroundColor: colors.background,
                  backgroundColor: colors.background,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: tempIsFreeCategory['vip'],
                                onChanged: tempIsFree ? null : (v) {
                                  setDialogState(() {
                                    tempIsFreeCategory['vip'] = v ?? false;
                                    if (tempIsFreeCategory['vip']!) {
                                      tempControllers['vip']!.clear();
                                    }
                                  });
                                },
                                activeColor: colors.primary,
                              ),
                              Text(
                                'Free VIP Tickets',
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ],
                          ),
                          if (!tempIsFreeCategory['vip']!)
                            TextFormField(
                              controller: tempControllers['vip'],
                              decoration: InputDecoration(
                                hintText: 'Enter VIP price (e.g., 500)',
                                hintStyle: TextStyle(color: colors.textSecondary),
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: colors.border),
                                ),
                              ),
                              style: TextStyle(color: colors.textPrimary),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Premium Category
                ExpansionTile(
                  title: Text(
                    (state.categoryPrices['premium'] ?? 0.0) > 0
                        ? 'Premium: ₹${state.categoryPrices['premium']!.toStringAsFixed(2)}'
                        : 'Set Premium Price',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  collapsedBackgroundColor: colors.background,
                  backgroundColor: colors.background,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: tempIsFreeCategory['premium'],
                                onChanged: tempIsFree ? null : (v) {
                                  setDialogState(() {
                                    tempIsFreeCategory['premium'] = v ?? false;
                                    if (tempIsFreeCategory['premium']!) {
                                      tempControllers['premium']!.clear();
                                    }
                                  });
                                },
                                activeColor: colors.primary,
                              ),
                              Text(
                                'Free Premium Tickets',
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ],
                          ),
                          if (!tempIsFreeCategory['premium']!)
                            TextFormField(
                              controller: tempControllers['premium'],
                              decoration: InputDecoration(
                                hintText: 'Enter Premium price (e.g., 200)',
                                hintStyle: TextStyle(color: colors.textSecondary),
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: colors.border),
                                ),
                              ),
                              style: TextStyle(color: colors.textPrimary),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Regular Category
                ExpansionTile(
                  title: Text(
                    (state.categoryPrices['regular'] ?? 0.0) > 0
                        ? 'Regular: ₹${state.categoryPrices['regular']!.toStringAsFixed(2)}'
                        : 'Set Regular Price',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  collapsedBackgroundColor: colors.background,
                  backgroundColor: colors.background,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: tempIsFreeCategory['regular'],
                                onChanged: tempIsFree ? null : (v) {
                                  setDialogState(() {
                                    tempIsFreeCategory['regular'] = v ?? false;
                                    if (tempIsFreeCategory['regular']!) {
                                      tempControllers['regular']!.clear();
                                    }
                                  });
                                },
                                activeColor: colors.primary,
                              ),
                              Text(
                                'Free Regular Tickets',
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ],
                          ),
                          if (!tempIsFreeCategory['regular']!)
                            TextFormField(
                              controller: tempControllers['regular'],
                              decoration: InputDecoration(
                                hintText: 'Enter Regular price (e.g., 100)',
                                hintStyle: TextStyle(color: colors.textSecondary),
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: colors.border),
                                ),
                              ),
                              style: TextStyle(color: colors.textPrimary),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                // Parse prices based on checkbox states
                final vip = tempIsFreeCategory['vip']! 
                    ? 0.0 
                    : (double.tryParse(tempControllers['vip']!.text.trim().replaceAll('₹', '').replaceAll(',', '')) ?? 0.0);
                final premium = tempIsFreeCategory['premium']! 
                    ? 0.0 
                    : (double.tryParse(tempControllers['premium']!.text.trim().replaceAll('₹', '').replaceAll(',', '')) ?? 0.0);
                final regular = tempIsFreeCategory['regular']! 
                    ? 0.0 
                    : (double.tryParse(tempControllers['regular']!.text.trim().replaceAll('₹', '').replaceAll(',', '')) ?? 0.0);
                
                // Validate: At least one category must be configured
                // (Either have a capacity set or be explicitly free)
                final hasVipCapacity = (state.categoryCapacities['vip'] ?? 0) > 0;
                final hasPremiumCapacity = (state.categoryCapacities['premium'] ?? 0) > 0;
                final hasRegularCapacity = (state.categoryCapacities['regular'] ?? 0) > 0;
                
                // Check if prices are set for categories that have capacity
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                  return;
                }

                // Save the prices
                notifier.setCategoryPrice('vip', vip);
                notifier.setCategoryPrice('premium', premium);
                notifier.setCategoryPrice('regular', regular);
                
                // Update the global free flag (true only if ALL categories are free)
                final allFree = vip == 0.0 && premium == 0.0 && regular == 0.0;
                notifier.setFree(allFree);
                
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: colors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final state = ref.read(createEventNotifierProvider);
    final tempController = TextEditingController(text: state.category);
    final categories = [
      'Music',
      'Sports',
      'Technology',
      'Business',
      'Art & Culture',
      'Food & Drink',
      'Health & Wellness',
      'Education',
      'Entertainment',
      'Other',
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text('Event Type', style: TextStyle(color: colors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...categories.map(
                (c) => RadioListTile<String>(
                  title: Text(c, style: TextStyle(color: colors.textPrimary)),
                  value: c,
                  groupValue: tempController.text,
                  activeColor: colors.primary,
                  onChanged: (v) {
                    tempController.text = v ?? '';
                    Navigator.pop(context);
                    notifier.setCategory(tempController.text);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
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
    final colors = AppColors(isDark);

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(createEventNotifierProvider);

          return AlertDialog(
            backgroundColor: colors.cardBackground,
            title: Text(
              'Select Date & Time',
              style: TextStyle(color: colors.textPrimary),
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
                  icon: const Icon(Icons.event),
                  label: Text(
                    state.startTime == null
                        ? 'Pick Start Time'
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(state.startTime!),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
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
                  icon: const Icon(Icons.event_available),
                  label: Text(
                    state.endTime == null
                        ? 'Pick End Time'
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(state.endTime!),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
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
                child: Text('Done', style: TextStyle(color: colors.primary)),
              ),
            ],
          );
        },
      ),
    );
  }
}
