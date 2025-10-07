import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/exceptions.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:sync_event/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sync_event/features/profile/data/models/profile_model.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';
import 'package:sync_event/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getUserProfile(String uid) async {
    if (await networkInfo.isConnected) {
      try {
        final profileData = await remoteDataSource.getUserProfile(uid);
        final profileEntity = ProfileModel.fromJson(profileData);
        await localDataSource.cacheProfileData(
          profileEntity.toJson().toString(),
        );
        return Right(profileEntity);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      // Try to get cached data
      try {
        final cachedData = await localDataSource.getCachedProfileData();
        if (cachedData != null) {
          // Parse cached data and return
          // This would need proper JSON parsing implementation
          return const Left(CacheFailure(message: 'No cached data available'));
        }
        return const Left(NetworkFailure(message: 'No internet connection'));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateUserProfile(uid, data);
        // Get updated profile
        final profileData = await remoteDataSource.getUserProfile(uid);
        final profileEntity = ProfileModel.fromJson(profileData);
        await localDataSource.cacheProfileData(
          profileEntity.toJson().toString(),
        );
        return Right(profileEntity);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    String imagePath,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await remoteDataSource.uploadProfileImage(
          File(imagePath),
          userId,
        );
        return Right(imageUrl);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfileImage(String imageUrl) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProfileImage(imageUrl);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
