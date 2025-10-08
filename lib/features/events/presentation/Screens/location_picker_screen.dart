import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

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
  bool is3D = true; // Default to 3D view
  bool isSearching = false;

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
    WidgetsBinding.instance.addObserver(this); // Add observer
    _checkAndRequestLocationServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    mapController?.dispose();
    searchController.dispose();
    super.dispose();
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
                    // Optionally, handle cancellation (e.g., navigate back or disable features)
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openLocationSettings();
                    // Recheck location services and permissions after returning
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
        // Automatically locate the user if permissions are granted
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
        // If location services are still disabled, show dialog again
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
      print(e);
    }
  }

  Future<LatLng?> _searchPlace(String input) async {
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid place name or address'),
        ),
      );
      return null;
    }
    setState(() => isSearching = true);
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleApiKey&types=geocode&components=country:IN";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          if (predictions.isNotEmpty) {
            final placeId = predictions.first['place_id'] as String;
            final placeDescription = predictions.first['description'] as String;
            return await _getPlaceLatLng(placeId, placeDescription);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No matching places found. Try a different search term.',
                ),
              ),
            );
            return null;
          }
        } else {
          String errorMessage = data['error_message'] ?? 'Unknown error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Places API error: $errorMessage')),
          );
          return null;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: HTTP ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to fetch place. Check your internet connection.',
          ),
        ),
      );
      return null;
    } finally {
      setState(() => isSearching = false);
    }
  }

  Future<LatLng?> _getPlaceLatLng(
    String placeId,
    String placeDescription,
  ) async {
    try {
      final detailsUrl =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$kGoogleApiKey";
      final detailsResponse = await http.get(Uri.parse(detailsUrl));
      if (detailsResponse.statusCode == 200) {
        final detailsData = json.decode(detailsResponse.body);
        if (detailsData['status'] == 'OK') {
          final location = detailsData['result']['geometry']['location'];
          return LatLng(location['lat'] as double, location['lng'] as double);
        }
      }
      final locations = await locationFromAddress(placeDescription);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to find coordinates for this place'),
        ),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get location coordinates. Try again.'),
        ),
      );
      return null;
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

  @override
  Widget build(BuildContext context) {
    const initialPosition = LatLng(11.8705, 75.3679); // Kannur, India

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Event Location"),
        backgroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          TextButton(
            onPressed: selectedLocation != null && address != null
                ? () {
                    Navigator.pop(context, {
                      'latitude': selectedLocation!.latitude,
                      'longitude': selectedLocation!.longitude,
                      'address': address,
                    });
                  }
                : null,
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: initialPosition,
              zoom: 15,
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
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                enabled: !isSearching,
                decoration: InputDecoration(
                  hintText: 'Enter place or address...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.place, color: Colors.grey),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          color: isSearching ? Colors.grey : Colors.blue,
                        ),
                        onPressed: isSearching
                            ? null
                            : () async {
                                final latLng = await _searchPlace(
                                  searchController.text.trim(),
                                );
                                if (latLng != null) {
                                  await _moveCamera(latLng);
                                  FocusScope.of(context).unfocus();
                                }
                              },
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                onSubmitted: isSearching
                    ? null
                    : (value) async {
                        final latLng = await _searchPlace(value.trim());
                        if (latLng != null) {
                          await _moveCamera(latLng);
                          FocusScope.of(context).unfocus();
                        }
                      },
              ),
            ),
          ),
          if (isSearching)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'locateMe',
                  onPressed: _locateMe,
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  onPressed: _zoomIn,
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.zoom_in, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  onPressed: _zoomOut,
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.zoom_out, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'toggle3D',
                  onPressed: _toggle3D,
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: Icon(
                    is3D ? Icons.threed_rotation : Icons.two_k,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (address != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "📍 $address",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
