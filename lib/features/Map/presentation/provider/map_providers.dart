import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/Map/data/repositories/marker_repositories_impl.dart';
import 'package:sync_event/features/Map/domain/repositories/marker_repository.dart';
import 'package:sync_event/features/Map/domain/usecases/build_marker_usecase.dart';
import 'package:sync_event/features/Map/domain/usecases/search_event_usecase.dart';
import 'package:sync_event/features/Map/presentation/state/marker_state_notifier.dart.dart';

// Repository Provider
final markerRepositoryProvider = Provider<MarkerRepository>((ref) {
  return MarkerRepositoryImpl();
});

// UseCase Providers
final buildMarkersUseCaseProvider = Provider<BuildMarkersUseCase>((ref) {
  return BuildMarkersUseCase(ref.read(markerRepositoryProvider), ref);
});

final searchEventsUseCaseProvider = Provider<SearchEventsUseCase>((ref) {
  return SearchEventsUseCase();
});

// State Providers
final selectedEventProvider = StateProvider<EventEntity?>((ref) => null);
final filteredEventsProvider = StateProvider<List<EventEntity>>((ref) => []);
final isLoadingMarkersProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');
final mapControllerProvider = StateProvider<GoogleMapController?>(
  (ref) => null,
);
final allEventsProvider = StateProvider<List<EventEntity>>((ref) => []);

// Theme Provider
final themeProvider = StateProvider<bool>(
  (ref) => false,
); // false = light, true = dark

// Events Provider - using the approved events stream from events feature
final eventsMapProvider = approvedEventsStreamProvider;

// Marker State Provider
final markerStateProvider =
    StateNotifierProvider<MarkerStateNotifier, Set<Marker>>(
      (ref) => MarkerStateNotifier(ref.read(buildMarkersUseCaseProvider), ref),
    );
