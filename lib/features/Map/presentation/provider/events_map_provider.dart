import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/usecases/approved_event_usecase.dart';
import '../../../../core/di/injection_container.dart';

final eventsMapProvider = FutureProvider.autoDispose<List<EventEntity>>((ref) async {
  final useCase = sl<GetApprovedEventsUseCase>();
  return await useCase.call();
});
