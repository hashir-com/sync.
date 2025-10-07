import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/features/events/domain/usecases/get_events_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/join_event_usecase.dart';

// Use case providers
final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return sl<GetEventsUseCase>();
});

final createEventUseCaseProvider = Provider<CreateEventUseCase>((ref) {
  return sl<CreateEventUseCase>();
});

final joinEventUseCaseProvider = Provider<JoinEventUseCase>((ref) {
  return sl<JoinEventUseCase>();
});
