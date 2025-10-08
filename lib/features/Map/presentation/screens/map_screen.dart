import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sync_event/features/Map/presentation/provider/events_map_provider.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// MarkerCache class remains unchanged
class _MarkerCache {
  static final Map<String, BitmapDescriptor> _icons = {};
  static final Set<Marker> _markers = {};
  static bool _isBuilt = false;
  static String _lastEventHash = '';

  static bool needsRebuild(List<EventEntity> events) {
    final currentHash = events.map((e) => e.id).join(',');
    if (_lastEventHash != currentHash) {
      _lastEventHash = currentHash;
      _isBuilt = false;
      return true;
    }
    return !_isBuilt;
  }

  static void markBuilt() => _isBuilt = true;

  static BitmapDescriptor? getIcon(String eventId) => _icons[eventId];

  static void setIcon(String eventId, BitmapDescriptor icon) =>
      _icons[eventId] = icon;

  static Set<Marker> get markers => _markers;

  static void setMarkers(Set<Marker> markers) {
    _markers.clear();
    _markers.addAll(markers);
  }
}

// Providers for state management
final selectedEventProvider = StateProvider<EventEntity?>((ref) => null);
final filteredEventsProvider = StateProvider<List<EventEntity>>((ref) => []);
final isLoadingMarkersProvider = StateProvider<bool>((ref) => false);
final hasInitializedProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');

// StateNotifier for managing marker building
class MarkerStateNotifier extends StateNotifier<Set<Marker>> {
  MarkerStateNotifier(this.ref) : super(_MarkerCache.markers);

  final Ref ref;

  Future<void> buildMarkers(List<EventEntity> events) async {
    if (!_MarkerCache.needsRebuild(events) ||
        ref.read(isLoadingMarkersProvider)) {
      return;
    }

    ref.read(isLoadingMarkersProvider.notifier).state = true;

    final validEvents = events
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();

    final newMarkers = <Marker>{};
    for (final event in validEvents) {
      final cachedIcon = _MarkerCache.getIcon(event.id);
      newMarkers.add(
        Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude!, event.longitude!),
          icon:
              cachedIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 1.0),
          onTap: () {
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
          },
        ),
      );
    }

    _MarkerCache.setMarkers(newMarkers);
    state = newMarkers;
    ref.read(isLoadingMarkersProvider.notifier).state = false;

    final markersNeedingIcons = validEvents
        .where((event) => _MarkerCache.getIcon(event.id) == null)
        .toList();

    if (markersNeedingIcons.isEmpty) {
      _MarkerCache.markBuilt();
      return;
    }

    const batchSize = 5;
    for (var i = 0; i < markersNeedingIcons.length; i += batchSize) {
      final batch = markersNeedingIcons.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((e) => _getMarkerIcon(e.imageUrl, e.id, ref)),
      );

      final updatedMarkers = <Marker>{};
      for (final event in validEvents) {
        final icon = _MarkerCache.getIcon(event.id);
        updatedMarkers.add(
          Marker(
            markerId: MarkerId(event.id),
            position: LatLng(event.latitude!, event.longitude!),
            icon:
                icon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
            anchor: const Offset(0.5, 1.0),
            onTap: () {
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
            },
          ),
        );
      }

      _MarkerCache.setMarkers(updatedMarkers);
      state = updatedMarkers;
    }

    _MarkerCache.markBuilt();
  }
}

final markerStateProvider =
    StateNotifierProvider<MarkerStateNotifier, Set<Marker>>(
      (ref) => MarkerStateNotifier(ref),
    );

// Provider for GoogleMapController
final mapControllerProvider = StateProvider<GoogleMapController?>(
  (ref) => null,
);

// Provider for all events (to avoid passing through widget)
final allEventsProvider = StateProvider<List<EventEntity>>((ref) => []);

// Image processing function (unchanged)
Future<Uint8List> _processImageInIsolate(Uint8List imageData) async {
  final decodedImage = img.decodeImage(imageData);
  if (decodedImage == null) throw Exception('Failed to decode image');

  final resizedImage = img.copyResize(
    decodedImage,
    width: 120,
    height: 120,
    interpolation: img.Interpolation.linear,
  );

  const padding = 5;
  const imageWidth = 120;
  const finalWidth = imageWidth + 2 * padding;
  const finalHeight = imageWidth + 2 * padding;
  final canvas = img.Image(
    width: finalWidth,
    height: finalHeight,
    numChannels: 4,
  );

  const cornerRadius = 30;
  img.fillRect(
    canvas,
    x1: 0,
    y1: 0,
    x2: finalWidth - 1,
    y2: finalHeight - 1,
    color: img.ColorRgba8(224, 224, 224, 255),
    radius: cornerRadius.toDouble(),
  );

  final mask = img.Image(width: imageWidth, height: imageWidth, numChannels: 4);
  img.fillRect(
    mask,
    x1: 0,
    y1: 0,
    x2: imageWidth - 1,
    y2: imageWidth - 1,
    color: img.ColorRgba8(255, 255, 255, 255),
    radius: cornerRadius.toDouble(),
  );

  final roundRectImage = img.compositeImage(
    img.Image(width: imageWidth, height: imageWidth, numChannels: 4),
    resizedImage,
    mask: mask,
  );

  img.compositeImage(canvas, roundRectImage, dstX: padding, dstY: padding);

  return Uint8List.fromList(img.encodePng(canvas));
}

// Marker icon fetching function (modified to use ref)
Future<BitmapDescriptor> _getMarkerIcon(
  String? imageUrl,
  String eventId,
  Ref ref,
) async {
  final cachedIcon = _MarkerCache.getIcon(eventId);
  if (cachedIcon != null) return cachedIcon;

  final cacheManager = DefaultCacheManager();

  try {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final cacheKey = 'marker_${eventId}_v3';
      final cachedFile = await cacheManager.getFileFromCache(cacheKey);

      Uint8List? imageData;
      if (cachedFile != null) {
        imageData = await cachedFile.file.readAsBytes();
      } else {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          imageData = response.bodyBytes;
          final finalData = await compute(_processImageInIsolate, imageData);
          await cacheManager.putFile(cacheKey, finalData, fileExtension: 'png');
          imageData = finalData;
        }
      }

      if (imageData != null) {
        final markerIcon = BitmapDescriptor.fromBytes(imageData);
        _MarkerCache.setIcon(eventId, markerIcon);
        return markerIcon;
      }
    }
  } catch (e) {
    if (kDebugMode) print('Error loading marker icon: $e');
  }

  final defaultIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueAzure,
  );
  _MarkerCache.setIcon(eventId, defaultIcon);
  return defaultIcon;
}

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsMapProvider);
    final searchController = TextEditingController();
    final allEvents = ref.watch(allEventsProvider);

    // Listen to search controller changes
    searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = searchController.text;
      final query = ref.read(searchQueryProvider).toLowerCase();
      ref.read(filteredEventsProvider.notifier).state = query.isNotEmpty
          ? allEvents
                .where(
                  (e) =>
                      e.title.toLowerCase().contains(query) ||
                      e.category.toLowerCase().contains(query),
                )
                .toList()
          : [];
    });

    // Initialize markers when events load
    ref.listen(eventsMapProvider, (_, state) {
      state.whenData((events) {
        ref.read(allEventsProvider.notifier).state = events;
        if (!ref.read(hasInitializedProvider) &&
            _MarkerCache.needsRebuild(events)) {
          ref.read(hasInitializedProvider.notifier).state = true;
          Future.microtask(
            () => ref.read(markerStateProvider.notifier).buildMarkers(events),
          );
        }
      });
    });

    // Locate me function
    Future<void> locateMe() async {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
          return;
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        ref
            .read(mapControllerProvider.notifier)
            .state
            ?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15,
                  tilt: 45,
                ),
              ),
            );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location found!')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    }

    // Handle search result tap
    void onSearchResultTap(EventEntity event) {
      ref.read(selectedEventProvider.notifier).state = event;
      searchController.clear();
      if (event.latitude != null && event.longitude != null) {
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            eventsAsync.when(
              data: (events) => GoogleMap(
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.hybrid,
                initialCameraPosition: CameraPosition(
                  target:
                      events.isNotEmpty &&
                          events.first.latitude != null &&
                          events.first.longitude != null
                      ? LatLng(events.first.latitude!, events.first.longitude!)
                      : const LatLng(11.8705, 75.3679),
                  zoom: 5,
                  tilt: 60,
                ),
                markers: ref.watch(markerStateProvider),
                onMapCreated: (controller) =>
                    ref.read(mapControllerProvider.notifier).state = controller,
                onTap: (_) =>
                    ref.read(selectedEventProvider.notifier).state = null,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: searchController.clear,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.blue),
                      onPressed: locateMe,
                      tooltip: 'My Location',
                    ),
                  ),
                ],
              ),
            ),
            if (ref.watch(searchQueryProvider).isNotEmpty &&
                ref.watch(filteredEventsProvider).isNotEmpty)
              Positioned(
                top: 80,
                left: 16,
                right: 16,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ref.watch(filteredEventsProvider).length,
                    itemBuilder: (context, index) {
                      final event = ref.watch(filteredEventsProvider)[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event.imageUrl ?? 'https://via.placeholder.com/50',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.event, size: 50),
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          event.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSearchResultTap(event),
                      );
                    },
                  ),
                ),
              ),
            if (ref.watch(isLoadingMarkersProvider))
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading markers...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (ref.watch(selectedEventProvider) != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                ref.watch(selectedEventProvider)!.imageUrl ??
                                    'https://via.placeholder.com/80',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.event,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ref.watch(selectedEventProvider)!.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ref.watch(selectedEventProvider)!.category,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  ref
                                          .read(selectedEventProvider.notifier)
                                          .state =
                                      null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ref.watch(selectedEventProvider)!.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${ref.watch(selectedEventProvider)!.attendees.length}/${ref.watch(selectedEventProvider)!.maxAttendees} attending',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to event details
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
