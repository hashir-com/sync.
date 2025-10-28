// File: features/map/domain/usecases/build_marker_usecase.dart
// Purpose: Build and update map markers from events, using circular image markers
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/map/data/cache/marker_cache.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/map/domain/repositories/marker_repository.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';

class BuildMarkersUseCase {
  final MarkerRepository repository;
  final Ref ref;

  BuildMarkersUseCase(this.repository, this.ref);

  // Execute: Build markers for valid events with circular image icons
  Future<Set<Marker>> execute(
    List<EventEntity> events,
    void Function(EventEntity) onMarkerTap, {
    void Function(Set<Marker>)? onBatchUpdated,
  }) async {
    print('BuildMarkersUseCase: Executing for ${events.length} events');
    final validEvents = events
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();
    print(
      'BuildMarkersUseCase: ${validEvents.length} valid events with lat/lng',
    );

    if (validEvents.isEmpty) {
      print('BuildMarkersUseCase: No valid events, returning empty set');
      return <Marker>{};
    }

    // CRITICAL FIX: Create initial markers with default icons FIRST
    // This prevents grey screen while loading custom icons
    final initialMarkers = _createMarkersWithDefaultIcons(validEvents, onMarkerTap);
    MarkerCache.setMarkers(initialMarkers);
    
    // Notify immediately with default markers
    if (onBatchUpdated != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onBatchUpdated(initialMarkers);
      });
    }

    // Load custom icons asynchronously in background
    await _loadMarkerIcons(
      validEvents,
      onMarkerTap,
      onBatchUpdated: onBatchUpdated,
    );

    // Create final markers with custom icons
    final finalMarkers = await _createMarkersWithCustomIcons(
      validEvents,
      onMarkerTap,
    );

    MarkerCache.setMarkers(finalMarkers);
    MarkerCache.markBuilt();
    
    print('BuildMarkersUseCase: Set ${finalMarkers.length} final markers');
    
    // CRITICAL: Defer final update
    if (onBatchUpdated != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onBatchUpdated(finalMarkers);
      });
    }

    return finalMarkers;
  }

  // Create markers with default icons (fast, prevents grey screen)
  Set<Marker> _createMarkersWithDefaultIcons(
    List<EventEntity> events,
    void Function(EventEntity) onMarkerTap,
  ) {
    print('BuildMarkersUseCase: Creating ${events.length} markers with default icons');
    final markers = <Marker>{};
    
    for (final event in events) {
      markers.add(
        Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude!, event.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 1.0), // Bottom center for default markers
          onTap: () => onMarkerTap(event),
        ),
      );
    }
    
    return markers;
  }

  // Create markers with custom circular icons
  Future<Set<Marker>> _createMarkersWithCustomIcons(
    List<EventEntity> events,
    void Function(EventEntity) onMarkerTap,
  ) async {
    print('BuildMarkersUseCase: Creating markers with custom icons');
    final markers = <Marker>{};
    
    for (final event in events) {
      final cachedIcon = await repository.getCachedIcon(event.id);
      
      markers.add(
        Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude!, event.longitude!),
          icon: cachedIcon ?? 
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: cachedIcon != null 
              ? const Offset(0.5, 0.5)  // Center for circular custom icons
              : const Offset(0.5, 1.0), // Bottom center for default markers
          onTap: () => onMarkerTap(event),
        ),
      );
    }
    
    return markers;
  }

  // LoadMarkerIcons: Asynchronously load and cache circular marker icons
  Future<void> _loadMarkerIcons(
    List<EventEntity> validEvents,
    void Function(EventEntity) onMarkerTap, {
    void Function(Set<Marker>)? onBatchUpdated,
  }) async {
    print(
      'BuildMarkersUseCase: Loading icons for ${validEvents.length} events',
    );
    
    final markersNeedingIcons = validEvents
        .where((event) => MarkerCache.getIcon(event.id) == null)
        .toList();
    
    print(
      'BuildMarkersUseCase: ${markersNeedingIcons.length} markers need icons',
    );

    if (markersNeedingIcons.isEmpty) {
      MarkerCache.markBuilt();
      return;
    }

    const batchSize = 5;
    for (var i = 0; i < markersNeedingIcons.length; i += batchSize) {
      final batch = markersNeedingIcons.skip(i).take(batchSize).toList();
      print('BuildMarkersUseCase: Processing batch $i-${i + batch.length}');

      try {
        // Load icons in parallel for batch
        await Future.wait(
          batch.map((e) => repository.getMarkerIcon(e.imageUrl, e.id)),
          eagerError: false, // Continue even if some fail
        );

        // CRITICAL FIX: Create updated markers after batch loads
        final updatedMarkers = await _createMarkersWithCustomIcons(
          validEvents,
          onMarkerTap,
        );

        MarkerCache.setMarkers(updatedMarkers);
        
        // CRITICAL: Defer batch update
        if (onBatchUpdated != null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            print(
              'BuildMarkersUseCase: Updated ${updatedMarkers.length} markers in batch',
            );
            onBatchUpdated(updatedMarkers);
          });
        }

        // Small delay between batches to prevent overwhelming the map
        if (i + batchSize < markersNeedingIcons.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        print('BuildMarkersUseCase: Error loading batch: $e');
        // Continue to next batch even if this one fails
      }
    }
  }
}