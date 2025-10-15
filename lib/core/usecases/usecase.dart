// ignore_for_file: avoid_types_as_parameter_names

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}




abstract class UseCases<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Define Params class
class Params {
  final String userId;

  Params({required this.userId});
}