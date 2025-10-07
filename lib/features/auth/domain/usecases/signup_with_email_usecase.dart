import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class SignUpWithEmailUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmail(
      params.email,
      params.password,
      params.name,
      params.imagePath,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String? imagePath;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    this.imagePath,
  });

  @override
  List<Object?> get props => [email, password, name, imagePath];
}
