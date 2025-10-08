import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/features/events/domain/usecases/approved_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/join_event_usecase.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

/// UseCases pulled from GetIt (injection container)
final createEventUseCaseProvider = Provider<CreateEventUseCase>(
  (ref) => sl<CreateEventUseCase>(),
);

final getApprovedEventsUseCaseProvider = Provider<GetApprovedEventsUseCase>(
  (ref) => sl<GetApprovedEventsUseCase>(),
);

final joinEventUseCaseProvider = Provider<JoinEventUseCase>(
  (ref) => sl<JoinEventUseCase>(),
);

/// Stream of approved events for user app
final approvedEventsStreamProvider =
    StreamProvider.autoDispose<List<EventEntity>>((ref) async* {
  final usecase = ref.read(getApprovedEventsUseCaseProvider);
  final events = await usecase.call();
  yield events;
});
