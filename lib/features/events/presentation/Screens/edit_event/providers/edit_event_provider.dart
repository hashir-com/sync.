import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import '../state/edit_event_state.dart';
import '../state/edit_event_notifier.dart';

final editEventFormProvider =
    StateNotifierProvider.autoDispose<EditEventFormNotifier, EditEventFormData?>(
  (ref) => EditEventFormNotifier(),
);

final editEventSubmissionProvider = StateNotifierProvider.autoDispose<
    EditEventSubmissionNotifier, EditEventSubmissionState>(
  (ref) => EditEventSubmissionNotifier(
    updateEventUseCase: ref.read(updateEventUseCaseProvider),
  ),
);