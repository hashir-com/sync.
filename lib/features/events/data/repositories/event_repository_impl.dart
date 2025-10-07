import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/exceptions.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/events/data/datasources/event_local_datasource.dart';
import 'package:sync_event/features/events/data/datasources/event_remote_datasource.dart';
import 'package:sync_event/features/events/data/models/event_model.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final EventLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    if (await networkInfo.isConnected) {
      try {
        final eventsData = await remoteDataSource.getEvents();
        final events = eventsData
            .map((data) => EventModel.fromJson(data))
            .toList();
        await localDataSource.cacheEvents(
          events.map((e) => e.toJson().toString()).join(','),
        );
        return Right(events);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      // Try to get cached data
      try {
        final cachedData = await localDataSource.getCachedEvents();
        if (cachedData != null) {
          // Parse cached data and return
          return const Left(CacheFailure(message: 'No cached data available'));
        }
        return const Left(NetworkFailure(message: 'No internet connection'));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventById(String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        final eventData = await remoteDataSource.getEventById(eventId);
        final event = EventModel.fromJson(eventData);
        return Right(event);
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
  Future<Either<Failure, String>> createEvent(
    Map<String, dynamic> eventData,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final eventId = await remoteDataSource.createEvent(eventData);
        return Right(eventId);
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
  Future<Either<Failure, EventEntity>> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateEvent(eventId, eventData);
        final updatedEventData = await remoteDataSource.getEventById(eventId);
        final event = EventModel.fromJson(updatedEventData);
        return Right(event);
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
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteEvent(eventId);
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

  @override
  Future<Either<Failure, void>> joinEvent(String eventId, String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.joinEvent(eventId, userId);
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

  @override
  Future<Either<Failure, void>> leaveEvent(
    String eventId,
    String userId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.leaveEvent(eventId, userId);
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

  @override
  Future<Either<Failure, String>> uploadEventImage(
    String eventId,
    String imagePath,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await remoteDataSource.uploadEventImage(
          File(imagePath),
          eventId,
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
}
