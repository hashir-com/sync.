// lib/features/profile/domain/usecases/create_user_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';
import 'package:sync_event/features/profile/domain/repositories/profile_repository.dart';

class CreateUserProfileUseCase implements UseCase<ProfileEntity, CreateProfileParams> {
  final ProfileRepository repository;

  const CreateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(CreateProfileParams params) async {
    return await repository.createUserProfile(params);
  }
}

class CreateProfileParams extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? bio;
  final List<String> interests;

  const CreateProfileParams({
    required this.uid,
    required this.email,
    required this.displayName,
    this.bio,
    this.interests = const [],
  });

  // Convert to Map for repository (assuming repository expects Map<String, dynamic>)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': displayName, // Assuming 'name' in ProfileEntity
      'bio': bio ?? '',
      'interests': interests,
      // Add other defaults like 'image': null, 'createdAt': Timestamp.now(), etc., if needed
    };
  }

  @override
  List<Object?> get props => [uid, email, displayName, bio, interests];
}