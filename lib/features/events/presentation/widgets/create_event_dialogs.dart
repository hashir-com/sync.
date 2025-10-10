import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import '../../../map/presentation/provider/map_providers.dart';
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
    final tempController = TextEditingController(text: state.maxAttendees);
    bool tempIsOpen = state.isOpenCapacity;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text(
            'Max Attendees',
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
                        if (tempIsOpen) tempController.clear();
                      });
                    },
                    activeColor: colors.primary,
                  ),
                  Text(
                    'Open Capacity',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!tempIsOpen)
                TextFormField(
                  controller: tempController,
                  decoration: InputDecoration(
                    hintText: 'Enter max attendees...',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: TextInputType.number,
                  autofocus: !tempIsOpen,
                ),
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
                if (!tempIsOpen && tempController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter max attendees or select open capacity',
                      ),
                    ),
                  );
                  return;
                }
                if (!tempIsOpen &&
                    (int.tryParse(tempController.text.trim()) ?? 0) <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Max attendees must be greater than 0'),
                    ),
                  );
                  return;
                }
                notifier.setOpenCapacity(tempIsOpen);
                notifier.setMaxAttendees(tempController.text);
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
    final tempController = TextEditingController(text: state.ticketPrice);
    bool tempIsFree = state.isFreeEvent;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text(
            'Ticket Price',
            style: TextStyle(color: colors.textPrimary),
          ),
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
                        if (tempIsFree) tempController.clear();
                      });
                    },
                    activeColor: colors.primary,
                  ),
                  Text(
                    'Free Event',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!tempIsFree)
                TextFormField(
                  controller: tempController,
                  decoration: InputDecoration(
                    hintText: 'Enter ticket price...',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                  ),
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: TextInputType.number,
                  autofocus: !tempIsFree,
                ),
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
                if (!tempIsFree && tempController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter ticket price or mark as free',
                      ),
                    ),
                  );
                  return;
                }
                if (!tempIsFree &&
                    (double.tryParse(tempController.text.trim()) ?? -1) < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ticket price must be 0 or greater'),
                    ),
                  );
                  return;
                }
                notifier.setFree(tempIsFree);
                notifier.setTicketPrice(tempController.text);
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
