import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';
import 'package:sync_event/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<ProfileEntity, GetProfileParams> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(GetProfileParams params) async {
    return await repository.getUserProfile(params.uid);
  }
}

class GetProfileParams extends Equatable {
  final String uid;

  const GetProfileParams({required this.uid});

  @override
  List<Object> get props => [uid];
}