import 'package:flutter/foundation.dart' show kIsWeb;
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
  
  // Prevent concurrent updates
  bool _isUpdating = false;
  
  // Track last tap time to debounce (critical for web and release)
  DateTime? _lastTapTime;
  static const _tapDebounceMs = 300;

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
          if (!mounted || _isUpdating) return;
          
          // CRITICAL: Different handling for web vs mobile
          if (kIsWeb) {
            // Web: Direct update without frame callback
            Future.microtask(() {
              if (mounted && !_isUpdating) {
                print('MarkerStateNotifier: Batch updated (web) ${updated.length} markers');
                state = updated;
              }
            });
          } else {
            // Mobile: Use frame callback
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isUpdating) {
                print('MarkerStateNotifier: Batch updated (mobile) ${updated.length} markers');
                state = updated;
              }
            });
          }
        },
      );
      
      if (!mounted) return;
      
      // CRITICAL: Platform-specific final update
      if (kIsWeb) {
        Future.microtask(() {
          if (mounted) {
            print('MarkerStateNotifier: Built ${markers.length} markers (web)');
            state = markers;
          }
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            print('MarkerStateNotifier: Built ${markers.length} markers (mobile)');
            state = markers;
          }
        });
      }
    } catch (e) {
      print('MarkerStateNotifier: Error building markers: $e');
    } finally {
      // CRITICAL: Ensure loading state is always reset
      Future.microtask(() {
        if (mounted) {
          ref.read(isLoadingMarkersProvider.notifier).state = false;
        }
      });
    }
  }

  void _onMarkerTap(EventEntity event) {
    // CRITICAL: Debounce taps (especially important for web and release)
    final now = DateTime.now();
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!).inMilliseconds < _tapDebounceMs) {
      print('MarkerStateNotifier: Tap debounced');
      return;
    }
    _lastTapTime = now;
    
    // Prevent concurrent updates
    if (_isUpdating) {
      print('MarkerStateNotifier: Marker tap ignored (update in progress)');
      return;
    }
    
    _isUpdating = true;
    // CRITICAL: Set flag to ignore map taps during handling
    ref.read(handlingMarkerTapProvider.notifier).state = true;
    print('MarkerStateNotifier: Tapped marker for ${event.title}');
    
    // CRITICAL: Web needs longer delay, mobile can be faster
    final delay = kIsWeb ? 50 : 0;
    
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) {
        _isUpdating = false;
        ref.read(handlingMarkerTapProvider.notifier).state = false;
        return;
      }
      
      try {
        // Step 1: Update selected event (minimal state change)
        ref.read(selectedEventProvider.notifier).state = event;
        print('MarkerStateNotifier: Selected event updated');
        
        // Step 2: Animate camera in next frame (no rebuild trigger)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          
          try {
            final controller = ref.read(mapControllerProvider.notifier).state;
            if (controller != null && 
                event.latitude != null && 
                event.longitude != null) {
              
              // CRITICAL: Web has different camera animation behavior
              if (kIsWeb) {
                // Web: Use newLatLng for smoother animation
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(event.latitude!, event.longitude!),
                    15,
                  ),
                );
              } else {
                // Mobile: Full camera position with tilt (FIX: tilt=0.0 to match initial and avoid release rendering issues)
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(event.latitude!, event.longitude!),
                      zoom: 15,
                      tilt: 0.0,  // FIXED: Changed from 60 to 0 for consistency and release stability
                    ),
                  ),
                );
              }
              print('MarkerStateNotifier: Camera animated to ${event.title}');
            }
          } catch (e) {
            print('MarkerStateNotifier: Camera animation error: $e');
            // Don't reset selected event - just skip animation
          }
        });
        
      } catch (e) {
        print('MarkerStateNotifier: Error in marker tap handler: $e');
        // Reset selected event on error
        try {
          ref.read(selectedEventProvider.notifier).state = null;
        } catch (_) {
          // Fail silently if even reset fails
        }
      } finally {
        // Reset flag after animation completes (longer duration for safety)
        Future.delayed(Duration(milliseconds: kIsWeb ? 1000 : 600), () {
          _isUpdating = false;
          ref.read(handlingMarkerTapProvider.notifier).state = false;
        });
      }
    });
  }
}