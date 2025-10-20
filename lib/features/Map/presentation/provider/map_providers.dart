// File: features/map/presentation/provider/map_providers.dart
// Purpose: Define Riverpod providers for map-related state and services
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/Map/data/repositories/marker_repositories_impl.dart';
import 'package:sync_event/features/Map/domain/services/location_service.dart';
import 'package:sync_event/features/Map/domain/usecases/build_marker_usecase.dart';
import 'package:sync_event/features/Map/domain/usecases/search_event_usecase.dart';
import 'package:sync_event/features/Map/domain/repositories/marker_repository.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sync_event/features/Map/presentation/state/marker_state_notifier.dart.dart';

// Provider for GoogleMapController
final mapControllerProvider = StateProvider<GoogleMapController?>((ref) => null);

// Provider for markers, using MarkerStateNotifier
final markerStateProvider = StateNotifierProvider<MarkerStateNotifier, Set<Marker>>(
  (ref) => MarkerStateNotifier(ref.watch(buildMarkersUseCaseProvider), ref),
);

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for selected event
final selectedEventProvider = StateProvider<EventEntity?>((ref) => null);

// Provider for marker loading state
final isLoadingMarkersProvider = StateProvider<bool>((ref) => false);

// Provider for location service
final locationServiceProvider = Provider((ref) => LocationService());

// Provider for marker repository
final markerRepositoryProvider = Provider<MarkerRepository>(
  (ref) => MarkerRepositoryImpl(cacheManager: DefaultCacheManager()),
);

// Provider for building markers use case
final buildMarkersUseCaseProvider = Provider(
  (ref) => BuildMarkersUseCase(ref.watch(markerRepositoryProvider), ref),
);

// Provider for searching events use case
final searchEventsUseCaseProvider = Provider((ref) => SearchEventsUseCase());

// Provider for all events (populated by eventsMapProvider)
final allEventsProvider = StateProvider<List<EventEntity>>((ref) => []);

// Provider for filtered events (search results)
final filteredEventsProvider = StateProvider<List<EventEntity>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final allEvents = ref.watch(allEventsProvider);
  final searchUseCase = ref.watch(searchEventsUseCaseProvider);
  final results = searchUseCase.execute(allEvents, query);
  print('map_providers: Filtered ${results.length} events for query "$query"');
  return results;
});

// Provider for approved events stream
final eventsMapProvider = StreamProvider.autoDispose<List<EventEntity>>((ref) {
  final getApprovedEvents = ref.watch(getApprovedEventsUseCaseProvider);
  print('map_providers: Fetching approved events stream');
  return getApprovedEvents(); // Remove asStream()
});