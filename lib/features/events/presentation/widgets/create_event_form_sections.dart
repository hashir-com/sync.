import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import '../providers/event_providers.dart';
import 'create_event_option_tile.dart';

class TitleField extends ConsumerWidget {
  const TitleField({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final state = ref.watch(createEventNotifierProvider);
    return TextFormField(
      initialValue: state.title,
      onChanged: ref.read(createEventNotifierProvider.notifier).setTitle,
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
    );
  }
}

class DescriptionTile extends ConsumerWidget {
  final VoidCallback onTap;
  const DescriptionTile({required this.onTap, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final state = ref.watch(createEventNotifierProvider);
    return CreateEventOptionTile(
      icon: Icons.description_outlined,
      label: state.description.isEmpty
          ? 'Add Description...'
          : state.description,
      iconColor: colors.textSecondary,
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
      iconColor: const Color(0xFF4CAF50),
      isRequired: true,
      trailing: state.coverFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                state.coverFile!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          : null,
      onTap: () async {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          ref
              .read(createEventNotifierProvider.notifier)
              .setCover(File(picked.path));
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
      print(
        'LocationTile: locationLabel=${state.locationLabel}, lat=${state.latitude}, lng=${state.longitude}',
      );
    }
    return CreateEventOptionTile(
      key: ValueKey(state.locationLabel), // Keep the key as it was originally
      icon: Icons.location_on_outlined,
      label: state.locationLabel.isEmpty ? 'Add Location' : state.locationLabel,
      iconColor: const Color(0xFF5E72E4),
      isRequired: true,
      onTap: () async {
        // Read notifier BEFORE awaiting to avoid using ref after widget disposed
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
              createNotifier.setLocation(
                label: address,
                lat: latitude,
                lng: longitude,
              );
              if (kDebugMode) {
                print(
                  'LocationTile: Called setLocation with address=$address, lat=$latitude, lng=$longitude',
                );
              }
            } else {
              if (kDebugMode) {
                print(
                  'LocationTile: Invalid result - address=$address, latitude=$latitude, longitude=$longitude',
                );
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print(
                'LocationTile: Error processing result - $e, result=$result',
              );
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
      iconColor: const Color(0xFF5E72E4),
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
      iconColor: const Color(0xFFFF9800),
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
    final positivePrices = state.categoryPrices.values
        .where((p) => p > 0)
        .toList();
    final minPrice = positivePrices.isNotEmpty
        ? positivePrices.reduce(min)
        : null;
    return CreateEventOptionTile(
      icon: Icons.confirmation_number_outlined,
      label: state.isFreeEvent
          ? 'Free Event'
          : (minPrice == null
                ? 'Add Ticket Pricing'
                : 'Starting from ₹${minPrice.toStringAsFixed(2)}'),
      iconColor: const Color(0xFFFFC107),
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
      iconColor: const Color(0xFF9C27B0),
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
    final colors = AppColors(isDark);
    final hasDocument = state.docFile != null;

    return CreateEventOptionTile(
      key: ValueKey(hasDocument ? state.docFile!.path : 'no_doc'),
      trailing: hasDocument
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // _buildDocumentPreview(context, state.docFile!),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.visibility, color: colors.primary),
                  onPressed: () => _openDocument(context, state.docFile!),
                  tooltip: 'Preview document',
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref.read(createEventNotifierProvider.notifier).setDoc(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document removed')),
                    );
                  },
                  tooltip: 'Remove document',
                  iconSize: 20,
                ),
              ],
            )
          : null,
      icon: Icons.attach_file,
      label: hasDocument
          ? state.docFile!.path.split('/').last
          : 'Add Document (Optional)',
      iconColor: colors.textSecondary,
      isRequired: false,
      onTap: () async {
        if (hasDocument) {
          // If document exists, open it for preview
          _openDocument(context, state.docFile!);
        } else {
          // Otherwise, pick a new document
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

    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No document selected')));
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
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget _buildDocumentPreview(BuildContext context, File file) {
  //   final extension = file.path.split('.').last.toLowerCase();
  //   Color bgColor;
  //   IconData icon;
  //   Color iconColor;

  //   switch (extension) {
  //     case 'pdf':
  //       bgColor = Colors.red.shade50;
  //       icon = Icons.picture_as_pdf;
  //       iconColor = const Color.fromARGB(255, 101, 54, 244);
  //       break;
  //     case 'doc':
  //     case 'docx':
  //       bgColor = Colors.blue.shade50;
  //       icon = Icons.description;
  //       iconColor = Colors.blue;
  //       break;
  //     default:
  //       bgColor = Colors.grey.shade50;
  //       icon = Icons.insert_drive_file;
  //       iconColor = Colors.grey;
  //   }

  //   return GestureDetector(
  //     onTap: () => _openDocument(context, file),
  //     child: Container(
  //       width: 50,
  //       height: 50,
  //       decoration: BoxDecoration(
  //         color: bgColor,
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(color: Colors.grey.shade300),
  //       ),
  //       child: Icon(icon, color: iconColor, size: 24),
  //     ),
  //   );
  // }
}
