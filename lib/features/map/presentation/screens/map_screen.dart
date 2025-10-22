// File: features/map/presentation/map_screen.dart
// Purpose: Display Google Map with events, search bar, and event details
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/map/domain/services/location_service.dart';
import 'package:sync_event/features/map/presentation/widgets/event_card.dart';
import 'package:sync_event/features/map/presentation/widgets/loading_indicator.dart';
import 'package:sync_event/features/map/presentation/widgets/search_bar.dart';
import 'package:sync_event/features/map/presentation/widgets/search_results.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LocationService _locationService = LocationService();
  bool _listenerSetup = false;

  // Initialize: Set up search controller listener
  @override
  void initState() {
    super.initState();
    _initializeSearchController();
  }

  // InitializeSearchController: Update search query provider on text change
  void _initializeSearchController() {
    _searchController.addListener(() {
      final currentText = _searchController.text;
      if (ref.read(searchQueryProvider) != currentText) {
        ref.read(searchQueryProvider.notifier).state = currentText;
        print('MapScreen: Search query updated to "$currentText"');
      }
    });
  }

  // Dispose: Clean up controllers and focus node
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Build: Render map, search bar, results, and event details
  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsMapProvider);
    final selectedEvent = ref.watch(selectedEventProvider);

    if (!_listenerSetup) {
      _setupEventListener();
      _listenerSetup = true;
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildMap(eventsAsync),
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: SearchBarWidget(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onLocateTap: _handleLocateMe,
              ),
            ),
            Positioned(
              top: 90.h,
              left: 16.w,
              right: 16.w,
              child: const SearchResultsWidget(),
            ),
            Positioned(
              bottom: 100.h,
              left: 0,
              right: 0,
              child: const Center(child: LoadingIndicatorWidget()),
            ),
            if (selectedEvent != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    key: ValueKey(selectedEvent.id),
                    child: EventDetailCard(event: selectedEvent),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // BuildMap: Render Google Map with markers
  Widget _buildMap(AsyncValue eventsAsync) {
    return eventsAsync.when(
      data: (events) {
        print('MapScreen: Rendering map with ${events.length} events');
        return GoogleMap(
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.hybrid,
          initialCameraPosition: _getInitialCameraPosition(events),
          markers: ref.watch(markerStateProvider),
          onMapCreated: (controller) {
            ref.read(mapControllerProvider.notifier).state = controller;
            print('MapScreen: Map created');
            // Force map refresh to address ImageReader_JNI
            controller.setMapStyle(null);
          },
          onTap: (_) {
            ref.read(selectedEventProvider.notifier).state = null;
            print('MapScreen: Map tapped, cleared selected event');
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error: $err', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  // GetInitialCameraPosition: Set initial map position based on events
  CameraPosition _getInitialCameraPosition(List<dynamic> events) {
    if (events.isNotEmpty &&
        events.first.latitude != null &&
        events.first.longitude != null) {
      print(
        'MapScreen: Initial position set to ${events.first.latitude}, ${events.first.longitude}',
      );
      return CameraPosition(
        target: LatLng(events.first.latitude!, events.first.longitude!),
        zoom: 5,
        tilt: 60,
      );
    }
    print('MapScreen: Using default initial position');
    return const CameraPosition(
      target: LatLng(11.8705, 75.3679),
      zoom: 5,
      tilt: 60,
    );
  }

  // SetupEventListener: Listen for event updates and trigger marker building
  void _setupEventListener() {
    ref.listen(eventsMapProvider, (previous, state) {
      state.whenData((events) {
        print('MapScreen: Events updated, ${events.length} events received');
        ref.read(allEventsProvider.notifier).state = events;
        Future.microtask(
          () => ref.read(markerStateProvider.notifier).buildMarkers(events),
        );
      });
    });
  }

  // HandleLocateMe: Move map to user's current location
  Future<void> _handleLocateMe() async {
    try {
      final cameraPosition = await _locationService.getCurrentLocation();
      if (cameraPosition != null && mounted) {
        ref
            .read(mapControllerProvider.notifier)
            .state
            ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        print('MapScreen: Animated to user location');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location found!')));
      }
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
