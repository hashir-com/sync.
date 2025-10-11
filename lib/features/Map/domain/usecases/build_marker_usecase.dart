// File: features/map/domain/usecases/build_marker_usecase.dart
// Purpose: Build and update map markers from events, using circular image markers
import 'dart:ui';
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

    // Load icons first
    await _loadMarkerIcons(
      validEvents,
      onMarkerTap,
      onBatchUpdated: onBatchUpdated,
    );

    // Create markers with circular icons
    final newMarkers = <Marker>{};
    for (final event in validEvents) {
      print(
        'BuildMarkersUseCase: Creating marker for ${event.title}, id=${event.id}',
      );
      final cachedIcon = await repository.getCachedIcon(event.id);
      newMarkers.add(
        Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude!, event.longitude!),
          icon:
              cachedIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: const Offset(0.5, 0.5), // Center anchor for circular markers
          onTap: () {
            print(
              'BuildMarkersUseCase: Marker tapped for ${event.title}, id=${event.id}',
            );
            ref.read(selectedEventProvider.notifier).state = event;
            ref.invalidate(selectedEventProvider);
            onMarkerTap(event);
          },
        ),
      );
    }

    MarkerCache.setMarkers(newMarkers);
    print('BuildMarkersUseCase: Set ${newMarkers.length} final markers');
    if (onBatchUpdated != null) onBatchUpdated(newMarkers);

    MarkerCache.markBuilt();
    return newMarkers;
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
      print('BuildMarkersUseCase: Processing batch $i-${i + batchSize}');

      await Future.wait(
        batch.map((e) => repository.getMarkerIcon(e.imageUrl, e.id)),
      );

      final updatedMarkers = <Marker>{};
      for (final event in validEvents) {
        final icon = await repository.getCachedIcon(event.id);
        updatedMarkers.add(
          Marker(
            markerId: MarkerId(event.id),
            position: LatLng(event.latitude!, event.longitude!),
            icon:
                icon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            anchor: const Offset(
              0.5,
              0.5,
            ), // Center anchor for circular markers
            onTap: () {
              print(
                'BuildMarkersUseCase: Marker tapped for ${event.title}, id=${event.id}',
              );
              ref.read(selectedEventProvider.notifier).state = event;
              ref.invalidate(selectedEventProvider);
              onMarkerTap(event);
            },
          ),
        );
      }

      MarkerCache.setMarkers(updatedMarkers);
      print(
        'BuildMarkersUseCase: Updated ${updatedMarkers.length} markers in batch',
      );
      if (onBatchUpdated != null) onBatchUpdated(updatedMarkers);
    }
  }
}
