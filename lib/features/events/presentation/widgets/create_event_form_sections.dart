import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';

import '../providers/event_providers.dart';
import 'create_event_option_tile.dart';

class TitleField extends ConsumerWidget {
  const TitleField({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final state = ref.watch(createEventNotifierProvider);
    
    return TextFormField(
      initialValue: state.title,
      onChanged: ref.read(createEventNotifierProvider.notifier).setTitle,
      decoration: InputDecoration(
        hintText: 'Add title...',
        hintStyle: AppTextStyles.headingSmall(isDark: isDark).copyWith(
          color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: AppTextStyles.headingSmall(isDark: isDark).copyWith(
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class DescriptionTile extends ConsumerWidget {
  final VoidCallback onTap;
  const DescriptionTile({required this.onTap, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final state = ref.watch(createEventNotifierProvider);
    
    return CreateEventOptionTile(
      icon: Icons.description_outlined,
      label: state.description.isEmpty ? 'Add Description...' : state.description,
      iconColor: AppColors.getTextSecondary(isDark),
      isRequired: true,
      onTap: onTap,
    );
  }
}

class CoverTile extends ConsumerWidget {
  const CoverTile({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = ImagePicker();
    final state = ref.watch(createEventNotifierProvider);
    
    return CreateEventOptionTile(
      icon: Icons.add_photo_alternate_outlined,
      label: state.coverFile == null ? 'Add Cover photo' : 'Cover Selected',
      iconColor: AppColors.success,
      isRequired: true,
      trailing: state.coverFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: Image.file(
                state.coverFile!,
                width: AppSizes.avatarLarge,
                height: AppSizes.avatarLarge,
                fit: BoxFit.cover,
              ),
            )
          : null,
      onTap: () async {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          ref.read(createEventNotifierProvider.notifier).setCover(File(picked.path));
        }
      },
    );
  }
}

class LocationTile extends ConsumerWidget {
  final Future<Map<String, dynamic>?> Function() pickLocation;
  const LocationTile({required this.pickLocation, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    
    if (kDebugMode) {
      print('LocationTile: locationLabel=${state.locationLabel}, lat=${state.latitude}, lng=${state.longitude}');
    }
    
    return CreateEventOptionTile(
      key: ValueKey(state.locationLabel),
      icon: Icons.location_on_outlined,
      label: state.locationLabel.isEmpty ? 'Add Location' : state.locationLabel,
      iconColor: AppColors.info,
      isRequired: true,
      onTap: () async {
        final createNotifier = ref.read(createEventNotifierProvider.notifier);
        final result = await pickLocation();
        
        if (kDebugMode) {
          print('LocationTile: pickLocation result=$result');
        }
        
        if (result != null) {
          try {
            final address = result['address'] as String?;
            final latitude = (result['latitude'] as num?)?.toDouble();
            final longitude = (result['longitude'] as num?)?.toDouble();
            
            if (address != null && latitude != null && longitude != null) {
              createNotifier.setLocation(label: address, lat: latitude, lng: longitude);
              if (kDebugMode) {
                print('LocationTile: Called setLocation with address=$address, lat=$latitude, lng=$longitude');
              }
            } else {
              if (kDebugMode) {
                print('LocationTile: Invalid result - address=$address, latitude=$latitude, longitude=$longitude');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('LocationTile: Error processing result - $e, result=$result');
            }
          }
        } else {
          if (kDebugMode) {
            print('LocationTile: Result is null or context not mounted');
          }
        }
      },
    );
  }
}

class DateTimeTile extends ConsumerWidget {
  final Future<void> Function() pickStart;
  final Future<void> Function() pickEnd;
  final VoidCallback showDialog;
  const DateTimeTile({
    required this.pickStart,
    required this.pickEnd,
    required this.showDialog,
    super.key,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    
    return CreateEventOptionTile(
      icon: Icons.calendar_today_outlined,
      label: state.startTime == null && state.endTime == null
          ? 'Date and Time'
          : '${state.startTime != null ? DateFormat('dd MMM yyyy, HH:mm').format(state.startTime!) : 'Start'} - ${state.endTime != null ? DateFormat('dd MMM yyyy, HH:mm').format(state.endTime!) : 'End'}',
      iconColor: AppColors.info,
      isRequired: true,
      onTap: showDialog,
    );
  }
}

class CapacityTile extends ConsumerWidget {
  final VoidCallback onTap;
  const CapacityTile({required this.onTap, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    final total = state.categoryCapacities.values.fold(0, (a, b) => a + b);
    
    return CreateEventOptionTile(
      icon: Icons.people_outline,
      label: state.isOpenCapacity
          ? 'Open Capacity'
          : (total <= 0 ? 'Max Attendees' : 'Max: $total attendees'),
      iconColor: AppColors.warning,
      isRequired: true,
      onTap: onTap,
    );
  }
}

class PriceTile extends ConsumerWidget {
  final VoidCallback onTap;
  const PriceTile({required this.onTap, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    final positivePrices = state.categoryPrices.values.where((p) => p > 0).toList();
    final minPrice = positivePrices.isNotEmpty ? positivePrices.reduce(min) : null;
    
    return CreateEventOptionTile(
      icon: Icons.confirmation_number_outlined,
      label: state.isFreeEvent
          ? 'Free Event'
          : (minPrice == null ? 'Add Ticket Pricing' : 'Starting from ₹${minPrice.toStringAsFixed(2)}'),
      iconColor: AppColors.warning,
      isRequired: true,
      onTap: onTap,
    );
  }
}

class CategoryTile extends ConsumerWidget {
  final VoidCallback onTap;
  const CategoryTile({required this.onTap, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    
    return CreateEventOptionTile(
      icon: Icons.category_outlined,
      label: state.category.isEmpty ? 'Event Type' : state.category,
      iconColor: AppColors.favorite,
      isRequired: true,
      onTap: onTap,
    );
  }
}

class DocumentTile extends ConsumerWidget {
  const DocumentTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEventNotifierProvider);
    final isDark = ref.watch(themeProvider);
    final hasDocument = state.docFile != null;

    return CreateEventOptionTile(
      key: ValueKey(hasDocument ? state.docFile!.path : 'no_doc'),
      trailing: hasDocument
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: AppSizes.spacingXs),
                IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: AppColors.getPrimary(isDark),
                    size: AppSizes.iconSmall,
                  ),
                  onPressed: () => _openDocument(context, state.docFile!),
                  tooltip: 'Preview document',
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.getError(isDark),
                    size: AppSizes.iconSmall,
                  ),
                  onPressed: () {
                    ref.read(createEventNotifierProvider.notifier).setDoc(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document removed')),
                    );
                  },
                  tooltip: 'Remove document',
                ),
              ],
            )
          : null,
      icon: Icons.attach_file,
      label: hasDocument
          ? state.docFile!.path.split('/').last
          : 'Add Document (Optional)',
      iconColor: AppColors.getTextSecondary(isDark),
      isRequired: false,
      onTap: () async {
        if (hasDocument) {
          _openDocument(context, state.docFile!);
        } else {
          await _pickDocument(context, ref);
        }
      },
    );
  }

  Future<void> _pickDocument(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty || result.files.first.path == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No document selected')),
        );
      }
      return;
    }

    final filePath = result.files.first.path!;
    final selectedFile = File(filePath);
    
    if (!await selectedFile.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected file not accessible')),
        );
      }
      return;
    }

    ref.read(createEventNotifierProvider.notifier).setDoc(selectedFile);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document selected successfully')),
      );
    }
  }

  Future<void> _openDocument(BuildContext context, File file) async {
    try {
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}