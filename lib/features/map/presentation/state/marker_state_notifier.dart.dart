import 'package:flutter/scheduler.dart';
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
          // CRITICAL: Use addPostFrameCallback for batch updates too
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print('MarkerStateNotifier: Batch updated with ${updated.length} markers');
              state = updated;
            }
          });
        },
      );
      
      // CRITICAL: Defer final state update
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('MarkerStateNotifier: Built ${markers.length} markers');
          state = markers;
        }
      });
    } catch (e) {
      print('MarkerStateNotifier: Error building markers: $e');
    } finally {
      // CRITICAL: Defer loading state update
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(isLoadingMarkersProvider.notifier).state = false;
        }
      });
    }
  }

  void _onMarkerTap(EventEntity event) {
    print('MarkerStateNotifier: Tapped marker for ${event.title}');
    
    // CRITICAL FIX: Defer ALL state updates until after the current frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        // Update selected event
        ref.read(selectedEventProvider.notifier).state = event;
        
        // Animate camera with null check
        final controller = ref.read(mapControllerProvider.notifier).state;
        if (controller != null && 
            event.latitude != null && 
            event.longitude != null) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(event.latitude!, event.longitude!),
                zoom: 15,
                tilt: 60,
              ),
            ),
          );
          print('MarkerStateNotifier: Camera animated to ${event.title}');
        }
      } catch (e) {
        print('MarkerStateNotifier: Error in marker tap handler: $e');
      }
    });
  }
}