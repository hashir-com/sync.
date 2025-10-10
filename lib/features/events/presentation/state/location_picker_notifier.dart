import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerState {
  final LatLng? selectedLocation;
  final String? address;
  final bool is3D;
  final bool isSearching;
  final List<PlaceSuggestion> suggestions;
  final bool showSuggestions;

  const LocationPickerState({
    this.selectedLocation,
    this.address,
    this.is3D = true,
    this.isSearching = false,
    this.suggestions = const [],
    this.showSuggestions = false,
  });

  LocationPickerState copyWith({
    LatLng? selectedLocation,
    String? address,
    bool? is3D,
    bool? isSearching,
    List<PlaceSuggestion>? suggestions,
    bool? showSuggestions,
  }) {
    return LocationPickerState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      address: address ?? this.address,
      is3D: is3D ?? this.is3D,
      isSearching: isSearching ?? this.isSearching,
      suggestions: suggestions ?? this.suggestions,
      showSuggestions: showSuggestions ?? this.showSuggestions,
    );
  }
}

class PlaceSuggestion {
  final String placeId;
  final String displayName;
  final String formattedAddress;
  final LatLng? location;

  const PlaceSuggestion({
    required this.placeId,
    required this.displayName,
    required this.formattedAddress,
    this.location,
  });
}

class LocationPickerNotifier extends StateNotifier<LocationPickerState> {
  LocationPickerNotifier() : super(const LocationPickerState());

  void setLocation(LatLng pos, String? addr) {
    state = state.copyWith(selectedLocation: pos, address: addr, showSuggestions: false);
  }

  void set3D(bool v) => state = state.copyWith(is3D: v);
  void setSearching(bool v) => state = state.copyWith(isSearching: v);
  void setSuggestions(List<PlaceSuggestion> s) =>
      state = state.copyWith(suggestions: s, showSuggestions: s.isNotEmpty);
  void clearSuggestions() => state = state.copyWith(suggestions: const [], showSuggestions: false);
}

