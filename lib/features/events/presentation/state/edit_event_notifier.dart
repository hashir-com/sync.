import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/usecases/update_event_usecase.dart';

class EditEventState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  EditEventState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  EditEventState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return EditEventState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class EditEventNotifier extends StateNotifier<EditEventState> {
  final UpdateEventUseCase updateEventUseCase;

  EditEventNotifier({required this.updateEventUseCase})
      : super(EditEventState());

  Future<void> updateEvent(
    EventEntity event, {
    File? coverFile,
    File? docFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await updateEventUseCase.call(
        event,
        coverFile: coverFile,
        docFile: docFile,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = EditEventState();
  }
}