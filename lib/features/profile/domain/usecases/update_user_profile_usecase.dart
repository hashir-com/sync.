import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';
import 'package:sync_event/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfileUseCase implements UseCase<ProfileEntity, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) async {
    return await repository.updateUserProfile(params.uid, params.data);
  }
}

class UpdateProfileParams extends Equatable {
  final String uid;
  final Map<String, dynamic> data;

  const UpdateProfileParams({required this.uid, required this.data});

  @override
  List<Object> get props => [uid, data];
}