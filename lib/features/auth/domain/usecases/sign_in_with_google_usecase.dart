import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class SignInWithGoogleUseCase
    implements UseCase<UserEntity, GoogleSignInParams> {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GoogleSignInParams params) async {
    return await repository.signInWithGoogle(params.forceAccountChooser);
  }
}

class GoogleSignInParams extends Equatable {
  final bool forceAccountChooser;

  const GoogleSignInParams({required this.forceAccountChooser});

  @override
  List<Object> get props => [forceAccountChooser];
}
