import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import 'package:sync_event/features/events/data/models/category_model.dart';
import '../../../providers/category_providers.dart';
import '../providers/edit_event_provider.dart';
import '../state/edit_event_state.dart';

class EditDescriptionDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    EditEventFormData formData,
  ) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final controller = TextEditingController(text: formData.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text(
          'Event Description',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: TextFormField(
          controller: controller,
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Description cannot be empty')),
                );
                return;
              }
              ref
                  .read(editEventFormProvider.notifier)
                  .updateFormData(
                    formData.copyWith(description: controller.text),
                  );
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class EditLocationDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    EditEventFormData formData,
  ) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final controller = TextEditingController(text: formData.location);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text(
          'Event Location',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter location',
            hintStyle: TextStyle(color: colors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
          style: TextStyle(color: colors.textPrimary),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location cannot be empty')),
                );
                return;
              }
              ref
                  .read(editEventFormProvider.notifier)
                  .updateFormData(formData.copyWith(location: controller.text));
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class EditDateTimeDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    EditEventFormData formData,
  ) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final currentFormData = ref.watch(editEventFormProvider)!;

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
                    await _pickDateTime(context, ref, currentFormData, true);
                    setState(() {});
                  },
                  icon: const Icon(Icons.event),
                  label: Text(
                    currentFormData.startTime == null
                        ? 'Pick Start Time'
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(currentFormData.startTime!),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (currentFormData.startTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select start time first'),
                        ),
                      );
                      return;
                    }
                    await _pickDateTime(context, ref, currentFormData, false);
                    setState(() {});
                  },
                  icon: const Icon(Icons.event_available),
                  label: Text(
                    currentFormData.endTime == null
                        ? 'Pick End Time'
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(currentFormData.endTime!),
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
                  if (currentFormData.startTime == null ||
                      currentFormData.endTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select both start and end time'),
                      ),
                    );
                    return;
                  }
                  if (currentFormData.startTime!.isAfter(
                    currentFormData.endTime!,
                  )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('End time must be after start time'),
                      ),
                    );
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

  static Future<void> _pickDateTime(
    BuildContext context,
    WidgetRef ref,
    EditEventFormData formData,
    bool isStart,
  ) async {
    final initialDate = isStart
        ? (formData.startTime ?? DateTime.now())
        : (formData.endTime ?? formData.startTime ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (isStart) {
      ref
          .read(editEventFormProvider.notifier)
          .updateFormData(formData.copyWith(startTime: dateTime));
    } else {
      ref
          .read(editEventFormProvider.notifier)
          .updateFormData(formData.copyWith(endTime: dateTime));
    }
  }
}

class EditCapacityDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    EditEventFormData formData,
    int minAttendees,
  ) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final controller = TextEditingController(
      text: formData.maxAttendees.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text(
          'Max Attendees',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter maximum attendees',
                hintStyle: TextStyle(color: colors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
              style: TextStyle(color: colors.textPrimary),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum: $minAttendees (current attendees)',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null || value < minAttendees) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Must be at least $minAttendees')),
                );
                return;
              }
              ref
                  .read(editEventFormProvider.notifier)
                  .updateFormData(formData.copyWith(maxAttendees: value));
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class EditPriceDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    EditEventFormData formData,
  ) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final controller = TextEditingController(
      text: (formData.ticketPrice ?? 0).toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text(
          'Ticket Price',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter price (0 for free)',
            hintStyle: TextStyle(color: colors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            prefixText: '₹ ',
          ),
          style: TextStyle(color: colors.textPrimary),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0;
              if (value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Price cannot be negative')),
                );
                return;
              }
              ref
                  .read(editEventFormProvider.notifier)
                  .updateFormData(formData.copyWith(ticketPrice: value));
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class EditCategoryDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    EditEventFormData formData,
  ) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final repository = ref.read(categoryRepositoryProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text('Event Type', style: TextStyle(color: colors.textPrimary)),
        content: StreamBuilder<List<CategoryModel>>(
          stream: repository.getActiveCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load categories',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ],
                ),
              );
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No categories available'),
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
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    value: category.name,
                    groupValue: formData.category,
                    activeColor: colors.primary,
                    onChanged: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        ref
                            .read(editEventFormProvider.notifier)
                            .updateFormData(formData.copyWith(category: value));
                        Navigator.pop(ctx);
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
            onPressed: () => Navigator.pop(ctx),
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
