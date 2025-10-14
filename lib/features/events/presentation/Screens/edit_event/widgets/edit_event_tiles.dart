import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import '../providers/edit_event_provider.dart';
import '../state/edit_event_state.dart';
import 'edit_event_option_tile.dart';
import 'edit_event_dialogs.dart';

class EditTitleField extends ConsumerWidget {
  final EditEventFormData formData;

  const EditTitleField({super.key, required this.formData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    return TextFormField(
      initialValue: formData.title,
      onChanged: (value) {
        ref
            .read(editEventFormProvider.notifier)
            .updateFormData(formData.copyWith(title: value));
      },
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

class EditDescriptionTile extends ConsumerWidget {
  final EditEventFormData formData;

  const EditDescriptionTile({super.key, required this.formData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    return EditEventOptionTile(
      icon: Icons.description_outlined,
      label: formData.description.isEmpty
          ? 'Add Description...'
          : formData.description,
      iconColor: colors.textSecondary,
      isRequired: true,
      onTap: () => EditDescriptionDialog.show(context, ref, formData),
    );
  }
}

class EditCoverTile extends ConsumerWidget {
  final EditEventFormData formData;

  const EditCoverTile({super.key, required this.formData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage =
        formData.newCoverImage != null || formData.existingImageUrl != null;

    return EditEventOptionTile(
      icon: Icons.add_photo_alternate_outlined,
      label: hasImage ? 'Cover Selected' : 'Add Cover photo',
      iconColor: const Color(0xFF4CAF50),
      isRequired: true,
      trailing: hasImage
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (formData.newCoverImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      formData.newCoverImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(editEventFormProvider.notifier)
                        .updateFormData(
                          formData.copyWith(clearCoverImage: true),
                        );
                  },
                  iconSize: 20,
                ),
              ],
            )
          : null,
      onTap: () => _pickImage(ref),
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      ref
          .read(editEventFormProvider.notifier)
          .updateFormData(
            formData.copyWith(newCoverImage: File(pickedFile.path)),
          );
    }
  }
}

class EditLocationTile extends ConsumerWidget {
  final EditEventFormData formData;
  final Future<Map<String, dynamic>?> Function() pickLocation;

  const EditLocationTile({
    super.key,
    required this.formData,
    required this.pickLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditEventOptionTile(
      key: ValueKey(formData.location),
      icon: Icons.location_on_outlined,
      label: formData.location.isEmpty ? 'Add Location' : formData.location,
      iconColor: const Color(0xFF5E72E4),
      isRequired: true,
      onTap: () async {
        final editNotifier = ref.read(editEventFormProvider.notifier);
        final result = await pickLocation();

        if (result != null) {
          try {
            final address = result['address'] as String?;
            final latitude = (result['latitude'] as num?)?.toDouble();
            final longitude = (result['longitude'] as num?)?.toDouble();

            if (address != null && latitude != null && longitude != null) {
              editNotifier.updateFormData(
                formData.copyWith(
                  location: address,
                  latitude: latitude,
                  longitude: longitude,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error selecting location: $e')),
              );
            }
          }
        }
      },
    );
  }
}

class EditDateTimeTile extends ConsumerWidget {
  final EditEventFormData formData;

  const EditDateTimeTile({super.key, required this.formData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startText = formData.startTime != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(formData.startTime!)
        : 'Start';
    final endText = formData.endTime != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(formData.endTime!)
        : 'End';

    return EditEventOptionTile(
      icon: Icons.calendar_today_outlined,
      label: formData.startTime == null && formData.endTime == null
          ? 'Date and Time'
          : '$startText - $endText',
      iconColor: const Color(0xFF5E72E4),
      isRequired: true,
      onTap: () => EditDateTimeDialog.show(context, ref, formData),
    );
  }
}

class EditCapacityTile extends ConsumerWidget {
  final EditEventFormData formData;
  final int minAttendees;

  const EditCapacityTile({
    super.key,
    required this.formData,
    required this.minAttendees,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditEventOptionTile(
      icon: Icons.people_outline,
      label: formData.maxAttendees <= 0
          ? 'Max Attendees'
          : 'Max: ${formData.maxAttendees} attendees',
      iconColor: const Color(0xFFFF9800),
      isRequired: true,
      onTap: () =>
          EditCapacityDialog.show(context, ref, formData, minAttendees),
    );
  }
}

class EditPriceTile extends ConsumerWidget {
  final EditEventFormData formData;

  const EditPriceTile({super.key, required this.formData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = formData.ticketPrice ?? 0;

    return EditEventOptionTile(
      icon: Icons.confirmation_number_outlined,
      label: price == 0
          ? 'Free Event'
          : 'Starting from ₹${price.toStringAsFixed(2)}',
      iconColor: const Color(0xFFFFC107),
      isRequired: true,
      onTap: () => EditPriceDialog.show(context, ref, formData),
    );
  }
}

class EditCategoryTile extends ConsumerWidget {
  final EditEventFormData formData;

  const EditCategoryTile({super.key, required this.formData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditEventOptionTile(
      icon: Icons.category_outlined,
      label: formData.category.isEmpty ? 'Event Type' : formData.category,
      iconColor: const Color(0xFF9C27B0),
      isRequired: true,
      onTap: () => EditCategoryDialog.show(context, ref, formData),
    );
  }
}

class EditDocumentTile extends ConsumerWidget {
  final EditEventFormData formData;

  const EditDocumentTile({super.key, required this.formData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    final hasDocument =
        formData.newDocument != null || formData.existingDocumentUrl != null;

    String? documentName;
    if (formData.newDocument != null) {
      documentName = formData.newDocument!.path.split('/').last;
    } else if (formData.existingDocumentUrl != null) {
      documentName = formData.existingDocumentUrl!.split('/').last;
    }

    return EditEventOptionTile(
      key: ValueKey(
        hasDocument
            ? (formData.newDocument?.path ?? formData.existingDocumentUrl)
            : 'no_doc',
      ),
      icon: Icons.attach_file,
      label: hasDocument
          ? (documentName ?? 'Document attached')
          : 'Add Document (Optional)',
      iconColor: colors.textSecondary,
      isRequired: false,
      trailing: hasDocument
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDocumentPreview(context, formData, colors),
                const SizedBox(width: 4),
                if (formData.newDocument !=
                    null) // Only show preview for local files
                  IconButton(
                    icon: Icon(Icons.visibility, color: colors.primary),
                    onPressed: () =>
                        _openDocument(context, formData.newDocument!),
                    tooltip: 'Preview document',
                    iconSize: 20,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(editEventFormProvider.notifier)
                        .updateFormData(formData.copyWith(clearDocument: true));
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
      onTap: () async {
        if (hasDocument && formData.newDocument != null) {
          // If local document exists, open it for preview
          _openDocument(context, formData.newDocument!);
        } else if (hasDocument && formData.existingDocumentUrl != null) {
          // If only URL exists, show message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document is stored online, cannot preview'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // Otherwise, pick a new document
          await _pickDocument(context, ref);
        }
      },
    );
  }

  Widget _buildDocumentPreview(
    BuildContext context,
    EditEventFormData formData,
    AppColors colors,
  ) {
    String? path;
    if (formData.newDocument != null) {
      path = formData.newDocument!.path;
    } else if (formData.existingDocumentUrl != null) {
      path = formData.existingDocumentUrl;
    }

    final extension = path?.split('.').last.toLowerCase() ?? '';
    Color bgColor;
    IconData icon;
    Color iconColor;

    switch (extension) {
      case 'pdf':
        bgColor = Colors.red.shade50;
        icon = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        bgColor = Colors.blue.shade50;
        icon = Icons.description;
        iconColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey.shade50;
        icon = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return GestureDetector(
      onTap: formData.newDocument != null
          ? () => _openDocument(context, formData.newDocument!)
          : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
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

    ref
        .read(editEventFormProvider.notifier)
        .updateFormData(formData.copyWith(newDocument: selectedFile));

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
}
