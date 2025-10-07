import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';

class JoinEventUseCase implements UseCase<void, JoinEventParams> {
  final EventRepository repository;

  JoinEventUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinEventParams params) async {
    return await repository.joinEvent(params.eventId, params.userId);
  }
}

class JoinEventParams extends Equatable {
  final String eventId;
  final String userId;

  const JoinEventParams({required this.eventId, required this.userId});

  @override
  List<Object> get props => [eventId, userId];
}
