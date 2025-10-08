import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';
import '../../../../core/di/injection_container.dart';

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
  final TextEditingController _locationCtrl = TextEditingController();
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

  Future<void> _pickCoverImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverFile = File(pickedFile.path);
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

  Future<void> _submitEvent() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }

    final event = EventEntity(
      id: '', // Firestore will assign
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      latitude: selectedLatitude,
      longitude: selectedLongitude,
      startTime: _startDateTime!,
      endTime: _endDateTime!,
      imageUrl: null,
      documentUrl: null,
      organizerId: userId ?? 'unknown',
      organizerName: userName ?? 'Anonymous',
      attendees: [],
      maxAttendees: int.tryParse(_maxAttendeesCtrl.text.trim()) ?? 100,
      category: _categoryCtrl.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ticketPrice: double.tryParse(_ticketPriceCtrl.text.trim()) ?? 0.0,
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              ElevatedButton(
                onPressed: () async {
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
                child: const Text("Pick on Map"),
              ),

              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _ticketPriceCtrl,
                decoration: const InputDecoration(labelText: 'Ticket Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _maxAttendeesCtrl,
                decoration: const InputDecoration(labelText: 'Max Attendees'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickStartDateTime,
                    child: Text(
                      _startDateTime == null
                          ? 'Pick Start Time'
                          : DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(_startDateTime!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _pickEndDateTime,
                    child: Text(
                      _endDateTime == null
                          ? 'Pick End Time'
                          : DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(_endDateTime!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickCoverImage,
                    child: Text(
                      _coverFile == null
                          ? 'Pick Cover Image'
                          : 'Cover Selected',
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _pickDocument,
                    child: Text(
                      _docFile == null ? 'Pick Document' : 'Doc Selected',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEvent,
                child: const Text('Submit Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
