import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/map/domain/services/location_service.dart';
import 'package:sync_event/features/map/presentation/widgets/event_card.dart';
import 'package:sync_event/features/map/presentation/widgets/loading_indicator.dart';
import 'package:sync_event/features/map/presentation/widgets/search_bar.dart';
import 'package:sync_event/features/map/presentation/widgets/search_results.dart';

import '../provider/map_providers.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeSearchController();
  }

  void _initializeSearchController() {
    _searchController.addListener(() {
      final currentText = _searchController.text;
      if (ref.read(searchQueryProvider) != currentText) {
        ref.read(searchQueryProvider.notifier).state = currentText;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsMapProvider);
    final selectedEvent = ref.watch(selectedEventProvider);

    // Setup listener only once
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
                  child: EventDetailCard(
                    key: ValueKey(selectedEvent.id),
                    event: selectedEvent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(AsyncValue eventsAsync) {
    return eventsAsync.when(
      data: (events) => GoogleMap(
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.hybrid,
        initialCameraPosition: _getInitialCameraPosition(events),
        markers: ref.watch(markerStateProvider),
        onMapCreated: (controller) =>
            ref.read(mapControllerProvider.notifier).state = controller,
        onTap: (_) => ref.read(selectedEventProvider.notifier).state = null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error: $err', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  CameraPosition _getInitialCameraPosition(dynamic events) {
    if (events.isNotEmpty &&
        events.first.latitude != null &&
        events.first.longitude != null) {
      return CameraPosition(
        target: LatLng(events.first.latitude!, events.first.longitude!),
        zoom: 5,
        tilt: 60,
      );
    }
    return const CameraPosition(
      target: LatLng(11.8705, 75.3679),
      zoom: 5,
      tilt: 60,
    );
  }

  void _setupEventListener() {
    ref.listen(eventsMapProvider, (previous, state) {
      state.whenData((events) {
        ref.read(allEventsProvider.notifier).state = events;
        Future.microtask(
          () => ref.read(markerStateProvider.notifier).buildMarkers(events),
        );
      });
    });
  }

  Future<void> _handleLocateMe() async {
    try {
      final cameraPosition = await _locationService.getCurrentLocation();

      if (cameraPosition != null && mounted) {
        ref
            .read(mapControllerProvider.notifier)
            .state
            ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

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
