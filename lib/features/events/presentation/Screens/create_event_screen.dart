// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/event_providers.dart';
import '../widgets/create_event_app_bar.dart';
import '../widgets/create_event_form_sections.dart';
import '../widgets/create_event_dialogs.dart';

class CreateEventScreen extends ConsumerWidget {
  CreateEventScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

    if (kDebugMode) {
      print(
        'CreateEventScreen: Rebuilt with locationLabel=${state.locationLabel}, lat=${state.latitude}, lng=${state.longitude}',
      );
    }

    Future<void> pickStartDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (date == null) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time == null) return;
      notifier.setStart(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
    }

    Future<void> pickEndDateTime() async {
      final start = state.startTime ?? DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: start,
        firstDate: start,
        lastDate: DateTime(2100),
      );
      if (date == null) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time == null) return;
      notifier.setEnd(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
    }

    Future<void> submit() async {
      final error = await notifier.submit(
        organizerId: userId,
        organizerName: userName,
      );
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event submitted for approval!')),
      );
      Navigator.pop(context);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CreateEventAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              const TitleField(),
              const SizedBox(height: 24),

              // Description
              DescriptionTile(
                onTap: () => DescriptionDialog.show(context, ref),
              ),
              const SizedBox(height: 12),

              // Cover Photo
              const CoverTile(),
              const SizedBox(height: 12),

              // Location
              LocationTile(
                pickLocation: () async {
                  final result = await context.push<Map<String, dynamic>>(
                    '/location-picker',
                  );
                  if (kDebugMode) {
                    print(
                      'CreateEventScreen: Location picker result - $result',
                    );
                  }
                  return result;
                },
              ),
              const SizedBox(height: 12),

              // Date and Time
              DateTimeTile(
                pickStart: pickStartDateTime,
                pickEnd: pickEndDateTime,
                showDialog: () => DateTimeDialog.show(
                  context,
                  ref,
                  pickStartDateTime,
                  pickEndDateTime,
                ),
              ),
              const SizedBox(height: 12),

              // Max Attendees
              CapacityTile(onTap: () => MaxAttendeesDialog.show(context, ref)),
              const SizedBox(height: 12),

              // Ticket Pricing
              PriceTile(onTap: () => PriceDialog.show(context, ref)),
              const SizedBox(height: 12),

              // Event Type (Category)
              CategoryTile(onTap: () => CategoryDialog.show(context, ref)),
              const SizedBox(height: 12),

              // Document (Optional)
              const DocumentTile(),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : submit,
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
}
