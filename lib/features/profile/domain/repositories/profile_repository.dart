import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getUserProfile(String uid);
  Future<Either<Failure, ProfileEntity>> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    String imagePath,
  );
  Future<Either<Failure, void>> deleteProfileImage(String imageUrl);
}
