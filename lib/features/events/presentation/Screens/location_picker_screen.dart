// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

const kGoogleApiKey = "AIzaSyA6iYBIGA19w4RqJn4LhQqGx6GBUi1_6OQ";

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen>
    with WidgetsBindingObserver {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String? address;
  final TextEditingController searchController = TextEditingController();
  bool is3D = true;
  bool isSearching = false;
  List<PlaceSuggestion> suggestions = [];
  bool showSuggestions = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkAndRequestLocationServices();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestLocationServices();

    // Listen to search text changes for autocomplete
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapController?.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (searchController.text.isEmpty) {
      setState(() {
        suggestions = [];
        showSuggestions = false;
      });
    } else if (searchController.text.length >= 3) {
      _getAutocompleteSuggestions(searchController.text);
    }
  }

  Future<void> _checkAndRequestLocationServices() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Enable Location Services'),
              content: const Text(
                'Location services are disabled. Please enable GPS to use location features.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openLocationSettings();
                    await _handleLocationServicesOnReturn();
                  },
                  child: const Text('Turn On'),
                ),
              ],
            ),
          );
        }
      } else {
        await _requestPermissions();
        if (await Permission.location.isGranted) {
          await _locateMe();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to check location services. Please try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleLocationServicesOnReturn() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        await _requestPermissions();
        if (await Permission.location.isGranted) {
          await _locateMe();
        }
      } else {
        await _checkAndRequestLocationServices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to verify location services. Please try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (await Permission.location.request().isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enable location permission in device settings',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to request location permission. Please enable it manually.',
            ),
          ),
        );
      }
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // New Places API - Autocomplete (Text Search)
  Future<void> _getAutocompleteSuggestions(String input) async {
    if (input.isEmpty || input.length < 3) return;

    try {
      final url = 'https://places.googleapis.com/v1/places:searchText';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': kGoogleApiKey,
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.formattedAddress,places.location',
        },
        body: jsonEncode({'textQuery': input, 'languageCode': 'en'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['places'] != null) {
          final places = data['places'] as List;
          setState(() {
            suggestions = places.map((place) {
              return PlaceSuggestion(
                placeId: place['id'] ?? '',
                displayName: place['displayName']?['text'] ?? 'Unknown',
                formattedAddress: place['formattedAddress'] ?? '',
                location: place['location'] != null
                    ? LatLng(
                        place['location']['latitude'] ?? 0.0,
                        place['location']['longitude'] ?? 0.0,
                      )
                    : null,
              );
            }).toList();
            showSuggestions = suggestions.isNotEmpty;
          });
        }
      } else {
        if (kDebugMode) {
          print(
            'Autocomplete error: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Autocomplete error: $e');
      }
    }
  }

  // New Places API - Get Place Details
  Future<LatLng?> _getPlaceDetails(String placeId) async {
    setState(() => isSearching = true);
    try {
      final url = 'https://places.googleapis.com/v1/$placeId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': kGoogleApiKey,
          'X-Goog-FieldMask': 'location,formattedAddress',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['location'] != null) {
          return LatLng(
            data['location']['latitude'] ?? 0.0,
            data['location']['longitude'] ?? 0.0,
          );
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Place details error: $e');
      }
      return null;
    } finally {
      setState(() => isSearching = false);
    }
  }

  Future<void> _moveCamera(LatLng newPos) async {
    try {
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 15, tilt: is3D ? 60 : 0),
        ),
      );
      final placemarks = await placemarkFromCoordinates(
        newPos.latitude,
        newPos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          selectedLocation = newPos;
          address =
              [
                    place.name,
                    place.locality,
                    place.administrativeArea,
                    place.country,
                  ]
                  .where((element) => element != null && element.isNotEmpty)
                  .join(', ');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update map. Please try again.'),
        ),
      );
    }
  }

  Future<void> _locateMe() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable them.',
            ),
          ),
        );
        return;
      }
      if (await Permission.location.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final latLng = LatLng(position.latitude, position.longitude);
        await _moveCamera(latLng);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission not granted. Please enable it in settings.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get current location. Please try again.'),
        ),
      );
    }
  }

  void _zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _toggle3D() {
    setState(() {
      is3D = !is3D;
    });
    if (selectedLocation != null) {
      _moveCamera(selectedLocation!);
    }
  }

  void _onSuggestionTapped(PlaceSuggestion suggestion) async {
    searchController.text = suggestion.displayName;
    setState(() {
      showSuggestions = false;
      address = suggestion.formattedAddress;
    });

    LatLng? location = suggestion.location;
    if (location == null && suggestion.placeId.isNotEmpty) {
      location = await _getPlaceDetails(suggestion.placeId);
    }

    if (location != null) {
      await _moveCamera(location);
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    const initialPosition = LatLng(0, 0);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: const CameraPosition(
              target: initialPosition,
              zoom: 4,
              tilt: 60,
            ),
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            onTap: (position) async {
              setState(() {
                selectedLocation = position;
                address = null;
                showSuggestions = false;
              });
              await _moveCamera(position);
            },
            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("picked_location"),
                      position: selectedLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(
                        title: address ?? "Selected Location",
                      ),
                    ),
                  },
            zoomControlsEnabled: false,
          ),

          // Search Bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              child: Column(
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 6.0, right: 8.0),
                            child: Icon(Icons.place, color: Colors.grey),
                          ),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              enabled: !isSearching,
                              textInputAction: TextInputAction.search,
                              onTap: () {
                                if (suggestions.isNotEmpty) {
                                  setState(() {
                                    showSuggestions = true;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search places...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                          if (searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  suggestions = [];
                                  showSuggestions = false;
                                });
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: TextButton(
                              onPressed:
                                  selectedLocation != null && address != null
                                  ? () {
                                      Navigator.pop(context, {
                                        'latitude': selectedLocation!.latitude,
                                        'longitude':
                                            selectedLocation!.longitude,
                                        'address': address,
                                      });
                                    }
                                  : null,
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  color:
                                      selectedLocation != null &&
                                          address != null
                                      ? Colors.blue
                                      : Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Suggestions List
                  if (showSuggestions && suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: suggestions.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                              title: Text(
                                suggestion.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                suggestion.formattedAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                              onTap: () => _onSuggestionTapped(suggestion),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (isSearching)
            const Positioned.fill(
              child: ColoredBox(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // Map Controls
          Positioned(
            right: 12,
            bottom: 120,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: _MapButton(
                      icon: Icons.threed_rotation,
                      label: "3D",
                      onPressed: _toggle3D,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          onTap: _zoomIn,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black12,
                                  width: 0.8,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(221, 112, 112, 112),
                              size: 24,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(14),
                          ),
                          onTap: _zoomOut,
                          child: const SizedBox(
                            height: 46,
                            width: 46,
                            child: Icon(
                              Icons.remove,
                              color: Color.fromARGB(221, 116, 116, 116),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: _MapButton(
                      icon: Icons.my_location,
                      onPressed: _locateMe,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected Address Display
          if (address != null)
            Positioned(
              right: 12,
              bottom: 20,
              left: 12,
              child: SafeArea(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PlaceSuggestion {
  final String placeId;
  final String displayName;
  final String formattedAddress;
  final LatLng? location;

  PlaceSuggestion({
    required this.placeId,
    required this.displayName,
    required this.formattedAddress,
    this.location,
  });
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;

  const _MapButton({required this.icon, required this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(221, 104, 104, 104),
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Icon(
                  icon,
                  color: const Color.fromARGB(221, 118, 118, 118),
                  size: 24,
                ),
        ),
      ),
    );
  }
}
