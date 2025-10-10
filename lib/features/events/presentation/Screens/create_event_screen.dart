// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/features/Map/presentation/provider/map_providers.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';

final createEventProvider = Provider<CreateEventUseCase>(
  (ref) => sl<CreateEventUseCase>(),
);

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  double? selectedLatitude;
  double? selectedLongitude;
  final TextEditingController _ticketPriceCtrl = TextEditingController();
  final TextEditingController _maxAttendeesCtrl = TextEditingController();
  final TextEditingController _categoryCtrl = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final userName = FirebaseAuth.instance.currentUser?.displayName;

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  File? _coverFile;
  File? _docFile;

  final picker = ImagePicker();

  String? _coverError;

  // New fields for validation
  bool _isFreeEvent = false;
  bool _isOpenCapacity = false;

  Future<void> _pickCoverImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverFile = File(pickedFile.path);
        _coverError = null;
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _docFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _startDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTime ?? DateTime.now(),
      firstDate: _startDateTime ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _endDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String? _validateForm() {
    if (_titleCtrl.text.trim().isEmpty) {
      return 'Please enter event title';
    }
    if (_descCtrl.text.trim().isEmpty) {
      return 'Please add event description';
    }
    if (_coverFile == null) {
      return 'Please select a cover image';
    }
    if (locationController.text.isEmpty ||
        selectedLatitude == null ||
        selectedLongitude == null) {
      return 'Please select event location';
    }
    if (_startDateTime == null || _endDateTime == null) {
      return 'Please select start and end time';
    }
    if (_startDateTime!.isAfter(_endDateTime!)) {
      return 'End time must be after start time';
    }
    if (!_isOpenCapacity && _maxAttendeesCtrl.text.trim().isEmpty) {
      return 'Please enter max attendees or select open capacity';
    }
    if (!_isOpenCapacity &&
        (int.tryParse(_maxAttendeesCtrl.text.trim()) ?? 0) <= 0) {
      return 'Max attendees must be greater than 0';
    }
    if (!_isFreeEvent && _ticketPriceCtrl.text.trim().isEmpty) {
      return 'Please enter ticket price or mark as free';
    }
    if (!_isFreeEvent &&
        (double.tryParse(_ticketPriceCtrl.text.trim()) ?? -1) < 0) {
      return 'Ticket price must be 0 or greater';
    }
    if (_categoryCtrl.text.trim().isEmpty) {
      return 'Please select event type';
    }
    return null;
  }

  Future<void> _submitEvent() async {
    // Validate all fields
    final validationError = _validateForm();
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    final event = EventEntity(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: locationController.text.trim(),
      latitude: selectedLatitude,
      longitude: selectedLongitude,
      startTime: _startDateTime!,
      endTime: _endDateTime!,
      imageUrl: null,
      documentUrl: null,
      organizerId: userId ?? 'unknown',
      organizerName: userName ?? 'Anonymous',
      attendees: [],
      maxAttendees: _isOpenCapacity
          ? 999999
          : (int.tryParse(_maxAttendeesCtrl.text.trim()) ?? 100),
      category: _categoryCtrl.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ticketPrice: _isFreeEvent
          ? 0.0
          : (double.tryParse(_ticketPriceCtrl.text.trim()) ?? 0.0),
    );

    try {
      await ref
          .read(createEventProvider)
          .call(event, docFile: _docFile, coverFile: _coverFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event submitted for approval!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create event: $e')));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'CREATE NEW EVENT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.textPrimary),
            onPressed: () {},
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
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Add title...',
                  hintStyle: TextStyle(
                    color: colors.textSecondary.withOpacity(0.5),
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // Description
              _buildOptionTile(
                icon: Icons.description_outlined,
                label: _descCtrl.text.isEmpty
                    ? 'Add Description...'
                    : _descCtrl.text,
                iconColor: colors.textSecondary,
                isRequired: true,
                onTap: () => _showDescriptionDialog(),
              ),
              const SizedBox(height: 12),

              // Cover Photo
              _buildOptionTile(
                icon: Icons.add_photo_alternate_outlined,
                label: _coverFile == null
                    ? 'Add Cover photo'
                    : 'Cover Selected',
                iconColor: const Color(0xFF4CAF50),
                isRequired: true,
                trailing: _coverFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _coverFile!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
                onTap: () async {
                  await _pickCoverImage();
                },
              ),
              const SizedBox(height: 12),

              // Location
              _buildOptionTile(
                icon: Icons.location_on_outlined,
                label: locationController.text.isEmpty
                    ? 'Add Location'
                    : locationController.text,
                iconColor: const Color(0xFF5E72E4),
                isRequired: true,
                onTap: () async {
                  final result = await context.push<Map<String, dynamic>>(
                    '/location-picker',
                  );
                  if (result != null) {
                    setState(() {
                      locationController.text = result['address'];
                      selectedLatitude = result['latitude'];
                      selectedLongitude = result['longitude'];
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Date and Time
              _buildOptionTile(
                icon: Icons.calendar_today_outlined,
                label: _startDateTime == null && _endDateTime == null
                    ? 'Date and Time'
                    : '${_startDateTime != null ? DateFormat('dd MMM yyyy, HH:mm').format(_startDateTime!) : 'Start'} - ${_endDateTime != null ? DateFormat('dd MMM yyyy, HH:mm').format(_endDateTime!) : 'End'}',
                iconColor: const Color(0xFF5E72E4),
                isRequired: true,
                onTap: () => _showDateTimeDialog(),
              ),
              const SizedBox(height: 12),

              // Max Attendees
              _buildOptionTile(
                icon: Icons.people_outline,
                label: _isOpenCapacity
                    ? 'Open Capacity'
                    : (_maxAttendeesCtrl.text.isEmpty
                          ? 'Max Attendees'
                          : 'Max: ${_maxAttendeesCtrl.text} attendees'),
                iconColor: const Color(0xFFFF9800),
                isRequired: true,
                onTap: () => _showMaxAttendeesDialog(),
              ),
              const SizedBox(height: 12),

              // Ticket Pricing
              _buildOptionTile(
                icon: Icons.confirmation_number_outlined,
                label: _isFreeEvent
                    ? 'Free Event'
                    : (_ticketPriceCtrl.text.isEmpty
                          ? 'Add Ticket Pricing'
                          : '${String.fromCharCode(8377)}${_ticketPriceCtrl.text}'),
                iconColor: const Color(0xFFFFC107),
                isRequired: true,
                onTap: () => _showTicketPriceDialog(),
              ),
              const SizedBox(height: 12),

              // Event Type (Category)
              _buildOptionTile(
                icon: Icons.category_outlined,
                label: _categoryCtrl.text.isEmpty
                    ? 'Event Type'
                    : _categoryCtrl.text,
                iconColor: const Color(0xFF9C27B0),
                isRequired: true,
                onTap: () => _showCategoryDialog(),
              ),
              const SizedBox(height: 12),

              // Document (Optional)
              _buildOptionTile(
                icon: Icons.attach_file,
                label: _docFile == null
                    ? 'Add Document (Optional)'
                    : _docFile!.path.split('/').last,
                iconColor: colors.textSecondary,
                isRequired: false,
                onTap: _pickDocument,
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E72E4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SUBMIT',
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

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color iconColor,
    required bool isRequired,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRequired)
                    Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showDescriptionDialog() {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final tempController = TextEditingController(text: _descCtrl.text);

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
              setState(() {
                _descCtrl.text = tempController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }

  void _showMaxAttendeesDialog() {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final tempController = TextEditingController(text: _maxAttendeesCtrl.text);
    bool tempIsOpen = _isOpenCapacity;

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
                    onChanged: (value) {
                      setDialogState(() {
                        tempIsOpen = value ?? false;
                        if (tempIsOpen) {
                          tempController.clear();
                        }
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
                setState(() {
                  _isOpenCapacity = tempIsOpen;
                  _maxAttendeesCtrl.text = tempController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: colors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketPriceDialog() {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final tempController = TextEditingController(text: _ticketPriceCtrl.text);
    bool tempIsFree = _isFreeEvent;

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
                    onChanged: (value) {
                      setDialogState(() {
                        tempIsFree = value ?? false;
                        if (tempIsFree) {
                          tempController.clear();
                        }
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
                setState(() {
                  _isFreeEvent = tempIsFree;
                  _ticketPriceCtrl.text = tempController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: colors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final tempController = TextEditingController(text: _categoryCtrl.text);

    // Predefined categories
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
                (category) => RadioListTile<String>(
                  title: Text(
                    category,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  value: category,
                  groupValue: tempController.text,
                  activeColor: colors.primary,
                  onChanged: (value) {
                    tempController.text = value ?? '';
                    Navigator.pop(context);
                    setState(() {
                      _categoryCtrl.text = tempController.text;
                    });
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

  void _showDateTimeDialog() {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  Navigator.pop(context);
                  await _pickStartDateTime();
                  _showDateTimeDialog();
                },
                icon: const Icon(Icons.event),
                label: Text(
                  _startDateTime == null
                      ? 'Pick Start Time'
                      : DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(_startDateTime!),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_startDateTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select start time first'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  await _pickEndDateTime();
                  _showDateTimeDialog();
                },
                icon: const Icon(Icons.event_available),
                label: Text(
                  _endDateTime == null
                      ? 'Pick End Time'
                      : DateFormat('dd MMM yyyy, HH:mm').format(_endDateTime!),
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
                if (_startDateTime == null || _endDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both start and end time'),
                    ),
                  );
                  return;
                }
                if (_startDateTime!.isAfter(_endDateTime!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End time must be after start time'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
              },
              child: Text('Done', style: TextStyle(color: colors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
