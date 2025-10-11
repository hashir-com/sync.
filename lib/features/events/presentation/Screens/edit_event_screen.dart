import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

// State Provider for Edit Event
final editEventStateProvider = StateProvider.autoDispose<EditEventData?>(
  (ref) => null,
);

class EditEventData {
  final String title;
  final String description;
  final String location;
  final String category;
  final int maxAttendees;
  final double? ticketPrice;
  final DateTime? startTime;
  final DateTime? endTime;
  final File? newCoverImage;
  final File? newDocument;
  final String? existingImageUrl;
  final String? existingDocumentUrl;
  final double? latitude;
  final double? longitude;

  EditEventData({
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.maxAttendees,
    this.ticketPrice,
    this.startTime,
    this.endTime,
    this.newCoverImage,
    this.newDocument,
    this.existingImageUrl,
    this.existingDocumentUrl,
    this.latitude,
    this.longitude,
  });

  EditEventData copyWith({
    String? title,
    String? description,
    String? location,
    String? category,
    int? maxAttendees,
    double? ticketPrice,
    DateTime? startTime,
    DateTime? endTime,
    File? newCoverImage,
    File? newDocument,
    String? existingImageUrl,
    String? existingDocumentUrl,
    double? latitude,
    double? longitude,
    bool clearCoverImage = false,
    bool clearDocument = false,
  }) {
    return EditEventData(
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      newCoverImage: clearCoverImage
          ? null
          : (newCoverImage ?? this.newCoverImage),
      newDocument: clearDocument ? null : (newDocument ?? this.newDocument),
      existingImageUrl: clearCoverImage
          ? null
          : (existingImageUrl ?? this.existingImageUrl),
      existingDocumentUrl: clearDocument
          ? null
          : (existingDocumentUrl ?? this.existingDocumentUrl),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class EditEventScreen extends ConsumerStatefulWidget {
  final EventEntity event;

  const EditEventScreen({super.key, required this.event});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    final event = widget.event;
    ref.read(editEventStateProvider.notifier).state = EditEventData(
      title: event.title,
      description: event.description,
      location: event.location,
      category: event.category,
      maxAttendees: event.maxAttendees,
      ticketPrice: event.ticketPrice,
      startTime: event.startTime,
      endTime: event.endTime,
      existingImageUrl: event.imageUrl,
      existingDocumentUrl: event.documentUrl,
      latitude: event.latitude,
      longitude: event.longitude,
    );
  }

  Future<void> _updateEvent() async {
    final editData = ref.read(editEventStateProvider);

    if (editData == null) return;

    // Validation
    if (editData.title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter event title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add event description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.newCoverImage == null && editData.existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cover image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.location.isEmpty ||
        editData.latitude == null ||
        editData.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select event location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.startTime == null || editData.endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.endTime!.isBefore(editData.startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.maxAttendees < widget.event.attendees.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Max attendees must be at least ${widget.event.attendees.length}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.ticketPrice == null || editData.ticketPrice! < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket price must be 0 or greater'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (editData.category.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select event type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedEvent = EventEntity(
        id: widget.event.id,
        title: editData.title.trim(),
        description: editData.description.trim(),
        location: editData.location.trim(),
        startTime: editData.startTime!,
        endTime: editData.endTime!,
        organizerId: widget.event.organizerId,
        organizerName: widget.event.organizerName,
        attendees: widget.event.attendees,
        maxAttendees: editData.maxAttendees,
        category: editData.category,
        latitude: editData.latitude ?? widget.event.latitude,
        longitude: editData.longitude ?? widget.event.longitude,
        createdAt: widget.event.createdAt,
        updatedAt: DateTime.now(),
        ticketPrice: editData.ticketPrice,
        imageUrl: editData.existingImageUrl,
        documentUrl: editData.existingDocumentUrl,
        status: 'pending', // Set status to pending for resubmission
        approvalReason: null, // Clear approval reason
        rejectionReason: null, // Clear rejection reason
      );

      await ref
          .read(updateEventUseCaseProvider)
          .call(
            updatedEvent,
            coverFile: editData.newCoverImage,
            docFile: editData.newDocument,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated and submitted for review!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update event: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editData = ref.watch(editEventStateProvider);
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    if (editData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              _EditTitleField(editData: editData),
              const SizedBox(height: 24),

              // Description
              _EditDescriptionTile(editData: editData),
              const SizedBox(height: 12),

              // Cover Photo
              _EditCoverTile(editData: editData),
              const SizedBox(height: 12),

              // Location
              _EditLocationTile(editData: editData),
              const SizedBox(height: 12),

              // Date and Time
              _EditDateTimeTile(editData: editData),
              const SizedBox(height: 12),

              // Max Attendees
              _EditCapacityTile(
                editData: editData,
                minAttendees: widget.event.attendees.length,
              ),
              const SizedBox(height: 12),

              // Ticket Pricing
              _EditPriceTile(editData: editData),
              const SizedBox(height: 12),

              // Event Type (Category)
              _EditCategoryTile(editData: editData),
              const SizedBox(height: 12),

              // Document (Optional)
              _EditDocumentTile(editData: editData),
              const SizedBox(height: 16),

              // Current Attendees Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current attendees: ${widget.event.attendees.length}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E72E4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'UPDATE EVENT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Title Field Widget
class _EditTitleField extends ConsumerWidget {
  final EditEventData editData;

  const _EditTitleField({required this.editData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: editData.title,
      decoration: const InputDecoration(
        labelText: 'Event Title',
        hintText: 'Enter event title',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        ref.read(editEventStateProvider.notifier).state = editData.copyWith(
          title: value,
        );
      },
    );
  }
}

// Description Tile Widget
class _EditDescriptionTile extends ConsumerWidget {
  final EditEventData editData;

  const _EditDescriptionTile({required this.editData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.description_outlined),
      title: const Text('Description'),
      subtitle: Text(
        editData.description.isEmpty
            ? 'Tap to add description'
            : editData.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDescriptionDialog(context, ref, editData),
    );
  }

  void _showDescriptionDialog(
    BuildContext context,
    WidgetRef ref,
    EditEventData editData,
  ) {
    final controller = TextEditingController(text: editData.description);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Event Description'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Enter event description',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(editEventStateProvider.notifier).state = editData
                  .copyWith(description: controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Cover Image Tile Widget
class _EditCoverTile extends ConsumerWidget {
  final EditEventData editData;

  const _EditCoverTile({required this.editData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage =
        editData.newCoverImage != null || editData.existingImageUrl != null;

    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.image_outlined),
      title: const Text('Cover Photo'),
      subtitle: Text(hasImage ? 'Photo attached' : 'Optional'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasImage)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                ref.read(editEventStateProvider.notifier).state = editData
                    .copyWith(clearCoverImage: true);
              },
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _pickImage(ref, editData),
    );
  }

  Future<void> _pickImage(WidgetRef ref, EditEventData editData) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      ref.read(editEventStateProvider.notifier).state = editData.copyWith(
        newCoverImage: File(pickedFile.path),
      );
    }
  }
}

// Location Tile Widget
class _EditLocationTile extends ConsumerWidget {
  final EditEventData editData;

  const _EditLocationTile({required this.editData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.location_on_outlined),
      title: const Text('Location'),
      subtitle: Text(
        editData.location.isEmpty ? 'Tap to set location' : editData.location,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLocationDialog(context, ref, editData),
    );
  }

  void _showLocationDialog(
    BuildContext context,
    WidgetRef ref,
    EditEventData editData,
  ) {
    final controller = TextEditingController(text: editData.location);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Event Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter location',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(editEventStateProvider.notifier).state = editData
                  .copyWith(location: controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// DateTime Tile Widget
class _EditDateTimeTile extends ConsumerWidget {
  final EditEventData editData;

  const _EditDateTimeTile({required this.editData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat('MMM dd, yyyy • hh:mm a');
    final startText = editData.startTime != null
        ? formatter.format(editData.startTime!)
        : 'Not set';
    final endText = editData.endTime != null
        ? formatter.format(editData.endTime!)
        : 'Not set';

    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.calendar_today_outlined),
      title: const Text('Date & Time'),
      subtitle: Text('$startText\n$endText', maxLines: 2),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDateTimeDialog(context, ref, editData),
    );
  }

  void _showDateTimeDialog(
    BuildContext context,
    WidgetRef ref,
    EditEventData editData,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Date & Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(
                editData.startTime != null
                    ? DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(editData.startTime!)
                    : 'Tap to select',
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickDateTime(context, ref, editData, true);
              },
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(
                editData.endTime != null
                    ? DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(editData.endTime!)
                    : 'Tap to select',
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickDateTime(context, ref, editData, false);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime(
    BuildContext context,
    WidgetRef ref,
    EditEventData editData,
    bool isStart,
  ) async {
    final initialDate = isStart
        ? (editData.startTime ?? DateTime.now())
        : (editData.endTime ?? editData.startTime ?? DateTime.now());

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
      ref.read(editEventStateProvider.notifier).state = editData.copyWith(
        startTime: dateTime,
      );
    } else {
      ref.read(editEventStateProvider.notifier).state = editData.copyWith(
        endTime: dateTime,
      );
    }
  }
}

// Capacity Tile Widget
class _EditCapacityTile extends ConsumerWidget {
  final EditEventData editData;
  final int minAttendees;

  const _EditCapacityTile({required this.editData, required this.minAttendees});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.people_outline),
      title: const Text('Max Attendees'),
      subtitle: Text('${editData.maxAttendees} people'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCapacityDialog(context, ref, editData),
    );
  }

  void _showCapacityDialog(
    BuildContext context,
    WidgetRef ref,
    EditEventData editData,
  ) {
    final controller = TextEditingController(
      text: editData.maxAttendees.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Max Attendees'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter maximum attendees',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum: $minAttendees (current attendees)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= minAttendees) {
                ref.read(editEventStateProvider.notifier).state = editData
                    .copyWith(maxAttendees: value);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Must be at least $minAttendees')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Price Tile Widget
class _EditPriceTile extends ConsumerWidget {
  final EditEventData editData;

  const _EditPriceTile({required this.editData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = editData.ticketPrice ?? 0;
    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.attach_money),
      title: const Text('Ticket Price'),
      subtitle: Text(price == 0 ? 'Free' : '\$${price.toStringAsFixed(2)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPriceDialog(context, ref, editData),
    );
  }

  void _showPriceDialog(
    BuildContext context,
    WidgetRef ref,
    EditEventData editData,
  ) {
    final controller = TextEditingController(
      text: (editData.ticketPrice ?? 0).toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ticket Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter price (0 for free)',
            border: OutlineInputBorder(),
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0;
              ref.read(editEventStateProvider.notifier).state = editData
                  .copyWith(ticketPrice: value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Category Tile Widget
class _EditCategoryTile extends ConsumerWidget {
  final EditEventData editData;

  const _EditCategoryTile({required this.editData});

  final List<String> _categories = const [
    'Sports',
    'Music',
    'Workshop',
    'Conference',
    'Community',
    'Entertainment',
    'Education',
    'Food & Drink',
    'Art & Culture',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.category_outlined),
      title: const Text('Category'),
      subtitle: Text(editData.category),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCategoryDialog(context, ref, editData),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    EditEventData editData,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _categories.map((category) {
              return RadioListTile<String>(
                title: Text(category),
                value: category,
                groupValue: editData.category,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(editEventStateProvider.notifier).state = editData
                        .copyWith(category: value);
                    Navigator.pop(ctx);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Document Tile Widget
class _EditDocumentTile extends ConsumerWidget {
  final EditEventData editData;

  const _EditDocumentTile({required this.editData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDocument =
        editData.newDocument != null || editData.existingDocumentUrl != null;

    return ListTile(
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.description_outlined),
      title: const Text('Supporting Document'),
      subtitle: Text(hasDocument ? 'Document attached' : 'Optional'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDocument)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                ref.read(editEventStateProvider.notifier).state = editData
                    .copyWith(clearDocument: true);
              },
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _pickDocument(ref, editData),
    );
  }

  Future<void> _pickDocument(WidgetRef ref, EditEventData editData) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      ref.read(editEventStateProvider.notifier).state = editData.copyWith(
        newDocument: File(result.files.single.path!),
      );
    }
  }
}
