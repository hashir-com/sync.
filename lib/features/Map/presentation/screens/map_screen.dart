import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/Map/presentation/provider/events_map_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsMapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events Map')),
      body: eventsAsync.when(
        data: (events) {
          _markers.clear();
          for (final event in events) {
            if (event.latitude != null && event.longitude != null) {
              _markers.add(
                Marker(
                  markerId: MarkerId(event.id),
                  position: LatLng(event.latitude!, event.longitude!),
                  infoWindow: InfoWindow(
                    title: event.title,
                    snippet:
                        '${event.category} • ${event.attendees.length}/${event.maxAttendees} attending',
                  ),
                ),
              );
            }
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  events.isNotEmpty &&
                      events.first.latitude != null &&
                      events.first.longitude != null
                  ? LatLng(events.first.latitude!, events.first.longitude!)
                  : const LatLng(0, 0), // fallback
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
