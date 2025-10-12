import 'dart:io';
import 'package:collection/collection.dart';
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
  // REPLACE: Use maps for categories
  // Human: Capacities per seat type (vip, premium, regular). 0 = not set.
  final Map<String, int> categoryCapacities;
  // Human: Prices per seat type (vip, premium, regular). 0.0 = free/not set.
  final Map<String, double> categoryPrices;
  final String category;
  final String status;
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
    Map<String, int>? categoryCapacities,
    Map<String, double>? categoryPrices,
    this.category = '',
    this.status = "pending",
    this.error,
    this.isSubmitting = false,
  }) : categoryCapacities =
           categoryCapacities ?? const {'vip': 0, 'premium': 0, 'regular': 0},
       categoryPrices =
           categoryPrices ?? const {'vip': 0.0, 'premium': 0.0, 'regular': 0.0};

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
    Map<String, int>? categoryCapacities,
    Map<String, double>? categoryPrices,
    String? category,
    String? status,
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
      categoryCapacities: categoryCapacities ?? this.categoryCapacities,
      categoryPrices: categoryPrices ?? this.categoryPrices,
      category: category ?? this.category,
      status: status ?? this.status,
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
  void setStatus(String v) => state = state.copyWith(status: v);
  void setFree(bool v) => state = state.copyWith(
    isFreeEvent: v,
    categoryPrices: v
        ? {'vip': 0.0, 'premium': 0.0, 'regular': 0.0}
        : state.categoryPrices,
  );
  void setOpenCapacity(bool v) => state = state.copyWith(
    isOpenCapacity: v,
    categoryCapacities: v
        ? {'vip': 0, 'premium': 0, 'regular': 0}
        : state.categoryCapacities,
  );
  void setCategoryCapacity(String category, int value) {
    final updated = Map<String, int>.from(state.categoryCapacities)
      ..[category] = value;
    state = state.copyWith(categoryCapacities: updated);
  }

  void setCategoryPrice(String category, double value) {
    final updated = Map<String, double>.from(state.categoryPrices)
      ..[category] = value;
    state = state.copyWith(categoryPrices: updated);
  }

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
    // UPDATE: Validate category sums
    // Human: If not open, ensure total capacity across categories > 0
    if (!state.isOpenCapacity && state.categoryCapacities.values.sum <= 0) {
      return 'Please enter capacities for at least one category or select open capacity';
    }
    // Human: If not free, ensure at least one category price > 0
    if (!state.isFreeEvent &&
        state.categoryPrices.values.every((p) => p <= 0)) {
      return 'Please enter price for at least one category or mark as free';
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
      // UPDATE: Use sum for total capacity; use 'regular' price as fallback for single ticketPrice (extend Entity for full category support)
      // Human: Calculates total max attendees from category maps; for price, uses regular or first positive (hack until Entity updated).
      final totalCapacity = state.isOpenCapacity
          ? 999999
          : state.categoryCapacities.values.sum;
      final eventPrice = state.isFreeEvent
          ? 0.0
          : (state.categoryPrices['regular'] ?? 0.0);

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
        maxAttendees: totalCapacity,
        category: state.category.trim(),
        status: state.status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ticketPrice: eventPrice,

        // Human: TODO: Add categoryCapacities: state.categoryCapacities, categoryPrices: state.categoryPrices to Entity constructor when updated.
      );

      await createEventUseCase.call(
        entity,
        docFile: state.docFile,
        coverFile: state.coverFile,
      );

      // Clear all fields after successful submission, reset maps
      // Human: Resets state including new maps.
      state = const CreateEventState();
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return e.toString();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
