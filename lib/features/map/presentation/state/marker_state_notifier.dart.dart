import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/map/data/cache/marker_cache.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/map/domain/usecases/build_marker_usecase.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';

class MarkerStateNotifier extends StateNotifier<Set<Marker>> {
  final BuildMarkersUseCase buildMarkersUseCase;
  final Ref ref;

  MarkerStateNotifier(this.buildMarkersUseCase, this.ref)
    : super(MarkerCache.markers);

  Future<void> buildMarkers(List<EventEntity> events) async {
    print('MarkerStateNotifier: Building markers for ${events.length} events');
    for (var event in events) {
      print(
        'MarkerStateNotifier: Event ${event.title}: id=${event.id}, lat=${event.latitude}, lng=${event.longitude}, status=${event.status}',
      );
    }

    if (ref.read(isLoadingMarkersProvider)) {
      print('MarkerStateNotifier: Skipped due to loading');
      return;
    }

    ref.read(isLoadingMarkersProvider.notifier).state = true;

    try {
      final markers = await buildMarkersUseCase.execute(
        events,
        (event) => _onMarkerTap(event),
        onBatchUpdated: (updated) {
          print(
            'MarkerStateNotifier: Batch updated with ${updated.length} markers',
          );
          state = updated;
        },
      );
      print('MarkerStateNotifier: Built ${markers.length} markers');
      state = markers;
    } catch (e) {
      print('MarkerStateNotifier: Error building markers: $e');
    } finally {
      ref.read(isLoadingMarkersProvider.notifier).state = false;
    }
  }

  void _onMarkerTap(EventEntity event) {
    print('MarkerStateNotifier: Tapped marker for ${event.title}');
    ref.read(selectedEventProvider.notifier).state = event;
    ref
        .read(mapControllerProvider.notifier)
        .state
        ?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(event.latitude!, event.longitude!),
              zoom: 15,
              tilt: 60,
            ),
          ),
        );
  }
}
