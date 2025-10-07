import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';

class CreateEventUseCase implements UseCase<String, CreateEventParams> {
  final EventRepository repository;

  CreateEventUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateEventParams params) async {
    return await repository.createEvent(params.eventData);
  }
}

class CreateEventParams extends Equatable {
  final Map<String, dynamic> eventData;

  const CreateEventParams({required this.eventData});

  @override
  List<Object> get props => [eventData];
}
