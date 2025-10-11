import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/Map/data/cache/marker_cache.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/Map/domain/usecases/build_marker_usecase.dart';
import 'package:sync_event/features/Map/presentation/provider/map_providers.dart';

/// State notifier for managing map markers
class MarkerStateNotifier extends StateNotifier<Set<Marker>> {
  final BuildMarkersUseCase buildMarkersUseCase;
  final Ref ref;

  MarkerStateNotifier(this.buildMarkersUseCase, this.ref)
    : super(MarkerCache.markers);

  Future<void> buildMarkers(List<EventEntity> events) async {
    if (!MarkerCache.needsRebuild(events) ||
        ref.read(isLoadingMarkersProvider)) {
      return;
    }

    ref.read(isLoadingMarkersProvider.notifier).state = true;

    try {
      final markers = await buildMarkersUseCase.execute(
        events,
        (event) => _onMarkerTap(event),
        onBatchUpdated: (updated) {
          // push progressive updates so custom icons appear as they load
          state = updated;
        },
      );
      state = markers;
    } finally {
      ref.read(isLoadingMarkersProvider.notifier).state = false;
    }
  }

  void _onMarkerTap(EventEntity event) {
    ref.read(selectedEventProvider.notifier).state = event;
    ref
        .read(mapControllerProvider.notifier)
        .state
        ?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(event.latitude!, event.longitude!),
              zoom: 18,
              tilt: 60,
            ),
          ),
        );
  }
}
