import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/features/events/domain/usecases/approved_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/join_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/get_user_events_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/update_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/state/create_event_notifier.dart';
import 'package:sync_event/features/events/presentation/state/location_picker_notifier.dart';

final createEventUseCaseProvider = Provider<CreateEventUseCase>(
  (ref) => sl<CreateEventUseCase>(),
);

final getApprovedEventsUseCaseProvider = Provider<GetApprovedEventsUseCase>(
  (ref) => sl<GetApprovedEventsUseCase>(),
);

final joinEventUseCaseProvider = Provider<JoinEventUseCase>(
  (ref) => sl<JoinEventUseCase>(),
);

final getUserEventsUseCaseProvider = Provider<GetUserEventsUseCase>(
  (ref) => sl<GetUserEventsUseCase>(),
);

final updateEventUseCaseProvider = Provider<UpdateEventUseCase>(
  (ref) => sl<UpdateEventUseCase>(),
);

final deleteEventUseCaseProvider = Provider<DeleteEventUseCase>(
  (ref) => sl<DeleteEventUseCase>(),
);

final approvedEventsStreamProvider =
    StreamProvider.autoDispose<List<EventEntity>>((ref) {
  final usecase = ref.read(getApprovedEventsUseCaseProvider);
  return usecase.call();
});

// Stream of current user's events
final userEventsStreamProvider =
    StreamProvider.autoDispose.family<List<EventEntity>, String>((ref, userId) {
  final usecase = ref.read(getUserEventsUseCaseProvider);
  return usecase.call(userId);
});

final createEventNotifierProvider =
    StateNotifierProvider<CreateEventNotifier, CreateEventState>(
  (ref) => CreateEventNotifier(
    createEventUseCase: ref.read(createEventUseCaseProvider),
  ),
);

final locationPickerNotifierProvider =
    StateNotifierProvider.autoDispose<LocationPickerNotifier,
        LocationPickerState>((ref) => LocationPickerNotifier());