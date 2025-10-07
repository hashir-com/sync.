// ignore_for_file: avoid_types_as_parameter_names

import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCaseStream<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

abstract class UseCaseStreamNoParams<Type> {
  Stream<Either<Failure, Type>> call();
}
