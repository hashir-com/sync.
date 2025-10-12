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
      'vip': TextEditingController(text: state.categoryCapacities['vip']?.toString() ?? ''),
      'premium': TextEditingController(text: state.categoryCapacities['premium']?.toString() ?? ''),
      'regular': TextEditingController(text: state.categoryCapacities['regular']?.toString() ?? ''),
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text('Max Attendees per Category', style: TextStyle(color: colors.textPrimary)),
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
                  Text('Open Capacity (Unlimited)', style: TextStyle(color: colors.textPrimary)),
                ],
              ),
              const SizedBox(height: 12),
              if (!tempIsOpen) ...[
                // Human: Input for VIP capacity
                TextFormField(
                  controller: tempControllers['vip'],
                  decoration: InputDecoration(
                    hintText: 'VIP (e.g., 50)',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.border)),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                // Human: Input for Premium capacity
                TextFormField(
                  controller: tempControllers['premium'],
                  decoration: InputDecoration(
                    hintText: 'Premium (e.g., 100)',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.border)),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                // Human: Input for Regular capacity
                TextFormField(
                  controller: tempControllers['regular'],
                  decoration: InputDecoration(
                    hintText: 'Regular (e.g., 200)',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.border)),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
            TextButton(
              onPressed: () {
                if (!tempIsOpen) {
                  final vip = int.tryParse(tempControllers['vip']!.text.trim()) ?? 0;
                  final premium = int.tryParse(tempControllers['premium']!.text.trim()) ?? 0;
                  final regular = int.tryParse(tempControllers['regular']!.text.trim()) ?? 0;
                  if (vip + premium + regular <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total capacity must be >0 or select open')));
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
    final tempControllers = {
      'vip': TextEditingController(text: state.categoryPrices['vip']?.toStringAsFixed(2) ?? ''),
      'premium': TextEditingController(text: state.categoryPrices['premium']?.toStringAsFixed(2) ?? ''),
      'regular': TextEditingController(text: state.categoryPrices['regular']?.toStringAsFixed(2) ?? ''),
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text('Ticket Price per Category', style: TextStyle(color: colors.textPrimary)),
          content: Column(
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
                          tempControllers.forEach((_, ctrl) => ctrl.clear());
                        }
                      });
                    },
                    activeColor: colors.primary,
                  ),
                  Text('Free Event', style: TextStyle(color: colors.textPrimary)),
                ],
              ),
              const SizedBox(height: 12),
              if (!tempIsFree) ...[
                // Human: Input for VIP price
                TextFormField(
                  controller: tempControllers['vip'],
                  decoration: InputDecoration(
                    hintText: 'VIP (e.g., 100.0)',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.border)),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                // Human: Input for Premium price
                TextFormField(
                  controller: tempControllers['premium'],
                  decoration: InputDecoration(
                    hintText: 'Premium (e.g., 50.0)',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.border)),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                // Human: Input for Regular price
                TextFormField(
                  controller: tempControllers['regular'],
                  decoration: InputDecoration(
                    hintText: 'Regular (e.g., 20.0)',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.border)),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: colors.textSecondary))),
            TextButton(
              onPressed: () {
                if (!tempIsFree) {
                  final vip = double.tryParse(tempControllers['vip']!.text.trim()) ?? 0.0;
                  final premium = double.tryParse(tempControllers['premium']!.text.trim()) ?? 0.0;
                  final regular = double.tryParse(tempControllers['regular']!.text.trim()) ?? 0.0;
                  if (vip <= 0 && premium <= 0 && regular <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Set price for at least one category or mark free')));
                    return;
                  }
                  notifier.setCategoryPrice('vip', vip);
                  notifier.setCategoryPrice('premium', premium);
                  notifier.setCategoryPrice('regular', regular);
                }
                notifier.setFree(tempIsFree);
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
        // Use Consumer to get fresh ref
        builder: (context, ref, child) {
          final state = ref.watch(
            createEventNotifierProvider,
          ); // Watch inside builder

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
                    Navigator.pop(dialogContext); // Use dialogContext
                    await pickStart();
                    if (context.mounted) {
                      // Check if still mounted
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
                    Navigator.pop(dialogContext); // Use dialogContext
                    await pickEnd();
                    if (context.mounted) {
                      // Check if still mounted
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
                  Navigator.pop(dialogContext); // Use dialogContext
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
