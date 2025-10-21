// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import '../providers/event_providers.dart';
import '../widgets/create_event_widgets/create_event_app_bar.dart';
import '../widgets/create_event_widgets/create_event_form_sections.dart';
import '../widgets/create_event_widgets/create_event_dialogs.dart';

class CreateEventScreen extends ConsumerWidget {
  CreateEventScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    final notifier = ref.read(createEventNotifierProvider.notifier);
    final isDark = ThemeUtils.isDark(context);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: AppTextStyles.bodyMedium(isDark: true)
                  .copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.getError(isDark),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            margin: EdgeInsets.all(AppSizes.paddingLarge),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Event submitted for approval!',
            style: AppTextStyles.bodyMedium(isDark: true)
                .copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.getSuccess(isDark),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          margin: EdgeInsets.all(AppSizes.paddingLarge),
        ),
      );
      Navigator.pop(context);
    }

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: const CreateEventAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingHorizontal,
          vertical: AppSizes.paddingLarge,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              const TitleField(),
              SizedBox(height: AppSizes.spacingXxl),

              // Description
              DescriptionTile(
                onTap: () => DescriptionDialog.show(context, ref),
              ),
              SizedBox(height: AppSizes.spacingMedium),

              // Cover Photo
              const CoverTile(),
              SizedBox(height: AppSizes.spacingMedium),

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
              SizedBox(height: AppSizes.spacingMedium),

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
              SizedBox(height: AppSizes.spacingMedium),

              // Max Attendees
              CapacityTile(onTap: () => MaxAttendeesDialog.show(context, ref)),
              SizedBox(height: AppSizes.spacingMedium),

              // Ticket Pricing
              PriceTile(onTap: () => PriceDialog.show(context, ref)),
              SizedBox(height: AppSizes.spacingMedium),

              // Event Type (Category)
              CategoryTile(onTap: () => CategoryDialog.show(context, ref)),
              SizedBox(height: AppSizes.spacingMedium),

              // Document (Optional)
              const DocumentTile(),

              SizedBox(height: AppSizes.spacingXxxl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimary(isDark),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.getDisabled(isDark).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: state.isSubmitting
                      ? SizedBox(
                          height: AppSizes.iconMedium,
                          width: AppSizes.iconMedium,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'SUBMIT',
                          style: AppTextStyles.button(isDark: isDark).copyWith(
                            color: Colors.white,
                            fontSize: AppSizes.fontLarge,
                            fontWeight: FontWeight.w600,
                            letterSpacing: AppSizes.letterSpacingExtraWide,
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