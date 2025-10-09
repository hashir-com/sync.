import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sync_event/features/Map/presentation/provider/events_map_provider.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// MarkerCache class (unchanged)
class _MarkerCache {
  static final Map<String, BitmapDescriptor> _icons = {};
  static final Set<Marker> _markers = {};
  static bool _isBuilt = false;
  static String _lastEventHash = '';

  static bool needsRebuild(List<EventEntity> events) {
    final currentHash = '${events.length}:${events.map((e) => e.id).join(',')}';
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

// Providers (unchanged)
final selectedEventProvider = StateProvider<EventEntity?>((ref) => null);
final filteredEventsProvider = StateProvider<List<EventEntity>>((ref) => []);
final isLoadingMarkersProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');
final mapControllerProvider = StateProvider<GoogleMapController?>(
  (ref) => null,
);
final allEventsProvider = StateProvider<List<EventEntity>>((ref) => []);

// StateNotifier for managing marker building (unchanged)
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

// Image processing (unchanged)
Future<Uint8List> _processImageInIsolate(Uint8List imageData) async {
  final decodedImage = img.decodeImage(imageData);
  if (decodedImage == null) throw Exception('Failed to decode image');

  // Get device pixel ratio (passed via isolate or default to 2.0)
  const pixelRatio = 1.0; // Fallback; ideally pass from context
  const baseSize = 150.0;
  final scaledSize = (baseSize * pixelRatio)
      .toInt(); // Scale based on pixel ratio

  final resizedImage = img.copyResize(
    decodedImage,
    width: scaledSize,
    height: scaledSize,
    interpolation: img.Interpolation.linear, // Higher quality resizing
  );

  const padding = 15;
  const imageWidth = 120;
  final scaledImageWidth = (imageWidth * pixelRatio).toInt();
  final scaledPadding = (padding * pixelRatio).toInt();
  final finalWidth = scaledImageWidth + 2 * scaledPadding;
  final finalHeight = scaledImageWidth + 2 * scaledPadding;

  final canvas = img.Image(
    width: finalWidth,
    height: finalHeight,
    numChannels: 4,
  );

  const cornerRadius = 130;
  img.fillRect(
    canvas,
    x1: 0,
    y1: 0,
    x2: finalWidth - 1,
    y2: finalHeight - 1,
    color: img.ColorRgba8(224, 224, 224, 255),
    radius: cornerRadius.toDouble() * pixelRatio, // Scale radius
  );

  final mask = img.Image(
    width: scaledImageWidth,
    height: scaledImageWidth,
    numChannels: 4,
  );
  img.fillRect(
    mask,
    x1: 0,
    y1: 0,
    x2: scaledImageWidth - 1,
    y2: scaledImageWidth - 1,
    color: img.ColorRgba8(255, 255, 255, 255),
    radius: cornerRadius.toDouble() * pixelRatio,
  );

  final roundRectImage = img.compositeImage(
    img.Image(
      width: scaledImageWidth,
      height: scaledImageWidth,
      numChannels: 4,
    ),
    resizedImage,
    mask: mask,
  );

  img.compositeImage(
    canvas,
    roundRectImage,
    dstX: scaledPadding,
    dstY: scaledPadding,
  );

  final encodedImage = img.encodePng(canvas);
  if (kDebugMode) {
    print(
      'Processed marker image: width=$finalWidth, height=$finalHeight, pixelRatio=$pixelRatio',
    );
  }
  return Uint8List.fromList(encodedImage);
}

// Updated _getMarkerIcon to clear cache and add debug logs
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
      // Clear cache for testing (remove after debugging)
      await cacheManager.removeFile(cacheKey);
      if (kDebugMode) print('Cleared cache for marker_$eventId');

      final cachedFile = await cacheManager.getFileFromCache(cacheKey);

      Uint8List? imageData;
      if (cachedFile != null) {
        imageData = await cachedFile.file.readAsBytes();
        if (kDebugMode) print('Loaded cached image for marker_$eventId');
      } else {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          imageData = response.bodyBytes;
          final finalData = await compute(_processImageInIsolate, imageData);
          await cacheManager.putFile(cacheKey, finalData, fileExtension: 'png');
          imageData = finalData;
          if (kDebugMode)
            print('Processed and cached new image for marker_$eventId');
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

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Sync controller with provider
    searchController.addListener(() {
      final currentText = searchController.text;
      if (ref.read(searchQueryProvider) != currentText) {
        ref.read(searchQueryProvider.notifier).state = currentText;
      }
    });
    // Debug focus changes
    searchFocusNode.addListener(() {
      if (kDebugMode) {
        print('TextField focus changed: ${searchFocusNode.hasFocus}');
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsMapProvider);
    final allEvents = ref.watch(allEventsProvider);

    // Initialize markers when events load
    ref.listen(eventsMapProvider, (previous, state) {
      state.whenData((events) {
        ref.read(allEventsProvider.notifier).state = events;
        Future.microtask(
          () => ref.read(markerStateProvider.notifier).buildMarkers(events),
        );
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
      ref.read(searchQueryProvider.notifier).state = '';
      searchFocusNode.unfocus();
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
            // Animated Search Bar
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: TweenAnimationBuilder<double>(
                key: const ValueKey('search_bar'),
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  final safeValue = value.clamp(0.0, 1.0);
                  if (kDebugMode) {
                    print('Search bar animation value: $safeValue');
                  }
                  return Transform.scale(
                    scale: safeValue,
                    child: Opacity(opacity: safeValue, child: child),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: const TextSelectionThemeData(
                            cursorColor: Colors.blue,
                            selectionColor: Colors.blueAccent,
                            selectionHandleColor: Colors.blue,
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: ref.watch(searchQueryProvider).isNotEmpty
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius:
                                    ref.watch(searchQueryProvider).isNotEmpty
                                    ? 15.r
                                    : 10.r,
                                offset: const Offset(0, 4),
                                spreadRadius:
                                    ref.watch(searchQueryProvider).isNotEmpty
                                    ? 2
                                    : 0,
                              ),
                            ],
                          ),
                          child: TextField(
                            key: const ValueKey('search_textfield'),
                            controller: searchController,
                            focusNode: searchFocusNode,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            cursorColor: Colors.blue,
                            decoration: InputDecoration(
                              hintText: 'Search events...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: AnimatedRotation(
                                duration: const Duration(milliseconds: 300),
                                turns: ref.watch(searchQueryProvider).isNotEmpty
                                    ? 0.5
                                    : 0,
                                child: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade600,
                                  size: 22.sp,
                                ),
                              ),
                              suffixIcon:
                                  ref.watch(searchQueryProvider).isNotEmpty
                                  ? ScaleTransition(
                                      scale: Tween<double>(begin: 0, end: 1)
                                          .animate(
                                            CurvedAnimation(
                                              parent: kAlwaysCompleteAnimation,
                                              curve: Curves.elasticOut,
                                            ),
                                          ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey.shade600,
                                          size: 22.sp,
                                        ),
                                        onPressed: () {
                                          searchController.clear();
                                          ref
                                                  .read(
                                                    searchQueryProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              '';
                                          searchFocusNode.unfocus();
                                          if (kDebugMode) {
                                            print('Search cleared');
                                          }
                                        },
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                            ),
                            onChanged: (value) {
                              if (kDebugMode) {
                                print('TextField input: $value');
                                print(
                                  'Controller text: ${searchController.text}',
                                );
                              }
                              ref.read(searchQueryProvider.notifier).state =
                                  value;
                              final query = value.toLowerCase();
                              ref
                                  .read(filteredEventsProvider.notifier)
                                  .state = query.isNotEmpty
                                  ? allEvents
                                        .where(
                                          (e) =>
                                              e.title.toLowerCase().contains(
                                                query,
                                              ) ||
                                              e.category.toLowerCase().contains(
                                                query,
                                              ),
                                        )
                                        .toList()
                                  : [];
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 10.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: locateMe,
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Animated Search Results (Updated for Clean, Minimal UI)
            if (ref.watch(searchQueryProvider).isNotEmpty &&
                ref.watch(filteredEventsProvider).isNotEmpty)
              Positioned(
                top: 90.h,
                left: 16.w,
                right: 16.w,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(ref.watch(filteredEventsProvider).length),
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 300.h,
                    ), // Reduced for less intrusion
                    decoration: BoxDecoration(
                      color: Colors.white, // Solid white background
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: Colors.grey.shade200, // Thinner, lighter border
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.05,
                          ), // Softer shadow
                          blurRadius: 8.r,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white, // Solid white, no gradient
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey.shade600, // Neutral color
                                  size: 18.sp, // Smaller icon
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '${ref.watch(filteredEventsProvider).length} result${ref.watch(filteredEventsProvider).length != 1 ? 's' : ''} found',
                                  style: TextStyle(
                                    fontSize: 12.sp, // Smaller font
                                    fontWeight:
                                        FontWeight.w500, // Consistent weight
                                    color:
                                        Colors.grey.shade600, // Neutral color
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const BouncingScrollPhysics(),
                              itemCount: ref
                                  .watch(filteredEventsProvider)
                                  .length,
                              itemBuilder: (context, index) {
                                final event = ref.watch(
                                  filteredEventsProvider,
                                )[index];
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(
                                    milliseconds: 200 + (index * 80),
                                  ),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, animValue, child) {
                                    return Transform.translate(
                                      offset: Offset(50 * (1 - animValue), 0),
                                      child: Opacity(
                                        opacity: animValue,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => onSearchResultTap(event),
                                      splashColor:
                                          Colors.grey.shade100, // Subtle splash
                                      highlightColor: Colors.grey.shade50,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ), // Slightly larger padding
                                        decoration: BoxDecoration(
                                          border:
                                              index !=
                                                  ref
                                                          .watch(
                                                            filteredEventsProvider,
                                                          )
                                                          .length -
                                                      1
                                              ? Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade200,
                                                    width: 1,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Hero(
                                              tag: 'search_${event.id}',
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 6.r,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        18.r,
                                                      ),
                                                  child: Image.network(
                                                    event.imageUrl ??
                                                        'https://via.placeholder.com/50',
                                                    width: 50
                                                        .w, // Slightly smaller
                                                    height: 50.h,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          width: 50.w,
                                                          height: 50.h,
                                                          decoration:
                                                              BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade200,
                                                              ),
                                                          child: Icon(
                                                            Icons.event,
                                                            size: 24.sp,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event.title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14.sp,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                              vertical: 3.h,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                                colors: [
                                                                  Colors
                                                                      .blue
                                                                      .shade50,
                                                                  Colors
                                                                      .blue
                                                                      .shade100,
                                                                ],
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.r,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          event.category,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blue
                                                                .shade700,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(
                                                6.w,
                                              ), // Smaller padding
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12.sp, // Smaller icon
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Animated Loading Indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ref.watch(isLoadingMarkersProvider)
                  ? Positioned(
                      key: const ValueKey('loading'),
                      bottom: 80.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors
                                  .blue
                                  .shade600, // Simplified to solid color
                              borderRadius: BorderRadius.circular(30.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.1,
                                  ), // Softer shadow
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Loading markers...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('not_loading')),
            ),
            // Animated Bottom Card (Tweaked for Minimal UI)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(0, 1.5),
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: ref.watch(selectedEventProvider) != null
                  ? Container(
                      key: ValueKey(ref.watch(selectedEventProvider)!.id),

                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Solid white, no gradient
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  16.w,
                                ), // Slightly smaller padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Hero(
                                          tag: ref
                                              .watch(selectedEventProvider)!
                                              .id,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 6.r,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              child: Image.network(
                                                ref
                                                        .watch(
                                                          selectedEventProvider,
                                                        )!
                                                        .imageUrl ??
                                                    'https://via.placeholder.com/80',
                                                width: 80.w, // Slightly smaller
                                                height: 80.h,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.event,
                                                      size: 80.sp,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 22.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ref
                                                    .watch(
                                                      selectedEventProvider,
                                                    )!
                                                    .title,
                                                style: TextStyle(
                                                  fontSize:
                                                      16.sp, // Smaller font
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 6.h),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 18.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue.shade50,
                                                      Colors.blue.shade100,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                ),
                                                child: Text(
                                                  ref
                                                      .watch(
                                                        selectedEventProvider,
                                                      )!
                                                      .category,
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: const Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      82,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            onTap: () =>
                                                ref
                                                        .read(
                                                          selectedEventProvider
                                                              .notifier,
                                                        )
                                                        .state =
                                                    null,
                                            child: Container(
                                              padding: EdgeInsets.all(8.w),
                                              child: Icon(
                                                Icons.close,
                                                size: 20.sp, // Smaller icon
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .grey
                                            .shade50, // Subtle background
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        ref
                                            .watch(selectedEventProvider)!
                                            .description,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: 16.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                '${ref.watch(selectedEventProvider)!.attendees.length}/${ref.watch(selectedEventProvider)!.maxAttendees}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          curve: Curves.easeOut,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: 0.9 + (0.1 * value),
                                              child: child,
                                            );
                                          },
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              onTap: () {
                                                // Navigate to event details
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                  vertical: 10.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .blue
                                                      .shade600, // Solid color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 6.r,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'View Details',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13.sp,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6.w),
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      color: Colors.white,
                                                      size: 16.sp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no_event')),
            ),
          ],
        ),
      ),
    );
  }
}
