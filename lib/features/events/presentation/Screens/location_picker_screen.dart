import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

const kGoogleApiKey = "YOUR_API_KEY"; // Replace with your valid Google API key

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String? address;
  final TextEditingController searchController = TextEditingController();

  Future<List<String>> _getPlaceSuggestions(String input) async {
    if (input.isEmpty) return [];
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleApiKey&types=geocode&components=country:IN";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((p) => p['description'] as String)
              .toList();
        } else {
          print(
            "Places API error: ${data['status']} - ${data['error_message']}",
          );
          return [];
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
      return [];
    }
  }

  Future<LatLng?> _getPlaceLatLng(String placeDescription) async {
    try {
      // Use geocoding package to convert address to LatLng
      final locations = await locationFromAddress(placeDescription);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      print("Error geocoding place: $e");
      return null;
    }
  }

  Future<void> _moveCamera(LatLng newPos) async {
    try {
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 15, tilt: 60),
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
          address = '${place.name}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      print("Error moving camera: $e");
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const initialPosition = LatLng(10.5276, 76.2144);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Event Location"),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedLocation != null && address != null) {
                Navigator.pop(context, {
                  'latitude': selectedLocation!.latitude,
                  'longitude': selectedLocation!.longitude,
                  'address': address,
                });
              }
            },
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: const CameraPosition(
              target: initialPosition,
              zoom: 15,
              tilt: 60,
            ),
            onMapCreated: (controller) => mapController = controller,
            onTap: (position) async {
              setState(() {
                selectedLocation = position;
                address = null;
              });
              try {
                final placemarks = await placemarkFromCoordinates(
                  position.latitude,
                  position.longitude,
                );
                if (placemarks.isNotEmpty) {
                  final place = placemarks.first;
                  setState(() {
                    address =
                        '${place.name ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
                  });
                }
              } catch (e) {
                print("Error getting placemark: $e");
              }
            },
            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("picked_location"),
                      position: selectedLocation!,
                      infoWindow: InfoWindow(
                        title: address ?? "Selected Location",
                      ),
                    ),
                  },
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: TypeAheadField<String>(
                hideOnEmpty: true,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search place...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  );
                },
                suggestionsCallback: (pattern) async {
                  final results = await _getPlaceSuggestions(pattern);
                  print("Suggestions for '$pattern': $results");
                  return results;
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSelected: (String suggestion) async {
                  final latLng = await _getPlaceLatLng(suggestion);
                  if (latLng != null) {
                    await _moveCamera(latLng);
                    searchController.text = suggestion;
                    FocusScope.of(context).unfocus();
                  }
                },
                debounceDuration: const Duration(milliseconds: 300),
                emptyBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No suggestions found'),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: address == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "📍 $address",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}
