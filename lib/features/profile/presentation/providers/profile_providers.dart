import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:sync_event/features/profile/domain/usecases/update_user_profile_usecase.dart';

// Use case providers
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return sl<GetUserProfileUseCase>();
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  return sl<UpdateUserProfileUseCase>();
});
