import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/map/data/cache/marker_cache.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/map/domain/repositories/marker_repository.dart';

/// UseCase for building map markers from events
class BuildMarkersUseCase {
  final MarkerRepository repository;
  final Ref ref;

  BuildMarkersUseCase(this.repository, this.ref);

  Future<Set<Marker>> execute(
    List<EventEntity> events,
    Function(EventEntity) onMarkerTap,
  ) async {
    if (!MarkerCache.needsRebuild(events)) {
      return MarkerCache.markers;
    }

    final validEvents = events
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();

    final newMarkers = <Marker>{};
    for (final event in validEvents) {
      final cachedIcon = repository.getCachedIcon(event.id);
      newMarkers.add(
        Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude!, event.longitude!),
          icon: cachedIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 1.0),
          onTap: () => onMarkerTap(event),
        ),
      );
    }

    MarkerCache.setMarkers(newMarkers);

    // Load icons asynchronously in batches
    _loadMarkerIcons(validEvents, onMarkerTap);

    return newMarkers;
  }

  Future<void> _loadMarkerIcons(
    List<EventEntity> validEvents,
    Function(EventEntity) onMarkerTap,
  ) async {
    final markersNeedingIcons = validEvents
        .where((event) => repository.getCachedIcon(event.id) == null)
        .toList();

    if (markersNeedingIcons.isEmpty) {
      MarkerCache.markBuilt();
      return;
    }

    const batchSize = 5;
    for (var i = 0; i < markersNeedingIcons.length; i += batchSize) {
      final batch = markersNeedingIcons.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((e) => repository.getMarkerIcon(e.imageUrl, e.id)),
      );

      final updatedMarkers = <Marker>{};
      for (final event in validEvents) {
        final icon = repository.getCachedIcon(event.id);
        updatedMarkers.add(
          Marker(
            markerId: MarkerId(event.id),
            position: LatLng(event.latitude!, event.longitude!),
            icon: icon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
            anchor: const Offset(0.5, 1.0),
            onTap: () => onMarkerTap(event),
          ),
        );
      }

      MarkerCache.setMarkers(updatedMarkers);
    }

    MarkerCache.markBuilt();
  }
}