import 'package:flutter/material.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import '../state/edit_event_state.dart';
import 'edit_event_tiles.dart';

class EditEventForm extends StatelessWidget {
  final EventEntity event;
  final EditEventFormData formData;
  final bool isLoading;
  final VoidCallback onUpdate;
  final Future<Map<String, dynamic>?> Function() pickLocation;

  const EditEventForm({
    super.key,
    required this.event,
    required this.formData,
    required this.isLoading,
    required this.onUpdate,
    required this.pickLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditTitleField(formData: formData),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                EditDescriptionTile(formData: formData),
                const SizedBox(height: 12),
                EditCoverTile(formData: formData),
                const SizedBox(height: 12),
                EditLocationTile(
                  formData: formData,
                  pickLocation: pickLocation,
                ),
                const SizedBox(height: 12),
                EditDateTimeTile(formData: formData),
                const SizedBox(height: 12),
                EditCapacityTile(
                  formData: formData,
                  minAttendees: event.attendees.length,
                ),
                const SizedBox(height: 12),
                EditPriceTile(formData: formData),
                const SizedBox(height: 12),
                EditCategoryTile(formData: formData),
                const SizedBox(height: 12),
                EditDocumentTile(formData: formData),
                const SizedBox(height: 16),
                _buildAttendeesInfo(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildAttendeesInfo(BuildContext context) {
    return Container(
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
              'Current attendees: ${event.attendees.length}',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : onUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E72E4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: isLoading
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
      ),
    );
  }
}