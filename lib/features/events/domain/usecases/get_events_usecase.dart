import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';

class GetEventsUseCase implements UseCaseNoParams<List<EventEntity>> {
  final EventRepository repository;

  GetEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<EventEntity>>> call() async {
    return await repository.getEvents();
  }
}
