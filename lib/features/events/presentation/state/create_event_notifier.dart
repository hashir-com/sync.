import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';

import '../../domain/entities/event_entity.dart';

class CreateEventState {
  final String title;
  final String description;
  final String locationLabel;
  final double? latitude;
  final double? longitude;
  final DateTime? startTime;
  final DateTime? endTime;
  final File? coverFile;
  final File? docFile;
  final bool isFreeEvent;
  final bool isOpenCapacity;
  final String ticketPrice;
  final String maxAttendees;
  final String category;
  final String? error;
  final bool isSubmitting;

  const CreateEventState({
    this.title = '',
    this.description = '',
    this.locationLabel = '',
    this.latitude,
    this.longitude,
    this.startTime,
    this.endTime,
    this.coverFile,
    this.docFile,
    this.isFreeEvent = false,
    this.isOpenCapacity = false,
    this.ticketPrice = '',
    this.maxAttendees = '',
    this.category = '',
    this.error,
    this.isSubmitting = false,
  });

  CreateEventState copyWith({
    String? title,
    String? description,
    String? locationLabel,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    File? coverFile,
    File? docFile,
    bool? isFreeEvent,
    bool? isOpenCapacity,
    String? ticketPrice,
    String? maxAttendees,
    String? category,
    String? error,
    bool? isSubmitting,
  }) {
    return CreateEventState(
      title: title ?? this.title,
      description: description ?? this.description,
      locationLabel: locationLabel ?? this.locationLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      coverFile: coverFile ?? this.coverFile,
      docFile: docFile ?? this.docFile,
      isFreeEvent: isFreeEvent ?? this.isFreeEvent,
      isOpenCapacity: isOpenCapacity ?? this.isOpenCapacity,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      category: category ?? this.category,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CreateEventNotifier extends StateNotifier<CreateEventState> {
  final CreateEventUseCase createEventUseCase;
  CreateEventNotifier({required this.createEventUseCase})
    : super(const CreateEventState());

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setCover(File? f) => state = state.copyWith(coverFile: f);
  void setDoc(File? f) => state = state.copyWith(docFile: f);
  void setCategory(String v) => state = state.copyWith(category: v);
  void setFree(bool v) => state = state.copyWith(
    isFreeEvent: v,
    ticketPrice: v ? '0' : state.ticketPrice,
  );
  void setOpenCapacity(bool v) => state = state.copyWith(
    isOpenCapacity: v,
    maxAttendees: v ? '' : state.maxAttendees,
  );
  void setTicketPrice(String v) => state = state.copyWith(ticketPrice: v);
  void setMaxAttendees(String v) => state = state.copyWith(maxAttendees: v);
  void setLocation({
    required String label,
    required double lat,
    required double lng,
  }) {
    state = state.copyWith(locationLabel: label, latitude: lat, longitude: lng);
    if (kDebugMode) {
      print(
        'CreateEventNotifier: Location set - label=$label, lat=$lat, lng=$lng',
      );
    }
  }

  void setStart(DateTime d) => state = state.copyWith(startTime: d);
  void setEnd(DateTime d) => state = state.copyWith(endTime: d);

  String? validate() {
    if (state.title.trim().isEmpty) return 'Please enter event title';
    if (state.description.trim().isEmpty) return 'Please add event description';
    if (state.coverFile == null) return 'Please select a cover image';
    if (state.locationLabel.isEmpty ||
        state.latitude == null ||
        state.longitude == null) {
      return 'Please select event location';
    }
    if (state.startTime == null || state.endTime == null) {
      return 'Please select start and end time';
    }
    if (state.startTime!.isAfter(state.endTime!)) {
      return 'End time must be after start time';
    }
    if (!state.isOpenCapacity && state.maxAttendees.trim().isEmpty) {
      return 'Please enter max attendees or select open capacity';
    }
    if (!state.isOpenCapacity &&
        (int.tryParse(state.maxAttendees.trim()) ?? 0) <= 0) {
      return 'Max attendees must be greater than 0';
    }
    if (!state.isFreeEvent && state.ticketPrice.trim().isEmpty) {
      return 'Please enter ticket price or mark as free';
    }
    if (!state.isFreeEvent &&
        (double.tryParse(state.ticketPrice.trim()) ?? -1) < 0) {
      return 'Ticket price must be 0 or greater';
    }
    if (state.category.trim().isEmpty) return 'Please select event type';
    return null;
  }

  Future<String?> submit({
    required String organizerId,
    required String organizerName,
  }) async {
    final validation = validate();
    if (validation != null) return validation;
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final entity = EventEntity(
        id: '',
        title: state.title.trim(),
        description: state.description.trim(),
        location: state.locationLabel.trim(),
        latitude: state.latitude,
        longitude: state.longitude,
        startTime: state.startTime!,
        endTime: state.endTime!,
        imageUrl: null,
        documentUrl: null,
        organizerId: organizerId,
        organizerName: organizerName,
        attendees: const [],
        maxAttendees: state.isOpenCapacity
            ? 999999
            : (int.tryParse(state.maxAttendees.trim()) ?? 100),
        category: state.category.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ticketPrice: state.isFreeEvent
            ? 0.0
            : (double.tryParse(state.ticketPrice.trim()) ?? 0.0),
      );

      await createEventUseCase.call(
        entity,
        docFile: state.docFile,
        coverFile: state.coverFile,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
