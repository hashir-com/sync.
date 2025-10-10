import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/event_providers.dart';

class LocationSearchBar extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final VoidCallback onTap;
  final bool enabled;
  const LocationSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(locationPickerNotifierProvider);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.search,
                onTap: onTap,
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
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: onClear,
              ),
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: TextButton(
                onPressed: s.selectedLocation != null && s.address != null
                    ? () {
                        final result = {
                          'latitude': s.selectedLocation!.latitude,
                          'longitude': s.selectedLocation!.longitude,
                          'address': s.address,
                        };

                        // Use GoRouter's pop instead of Navigator.pop
                        context.pop(result);
                      }
                    : null,
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: s.selectedLocation != null && s.address != null
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
    );
  }
}

class SuggestionsList extends ConsumerWidget {
  final void Function(int index) onTap;
  const SuggestionsList({required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(locationPickerNotifierProvider);
    if (!s.showSuggestions || s.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: s.suggestions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = s.suggestions[index];
            return ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
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
              onTap: () => onTap(index),
            );
          },
        ),
      ),
    );
  }
}

class SelectedAddressCard extends ConsumerWidget {
  const SelectedAddressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(locationPickerNotifierProvider);
    if (s.address == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.place, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s.address!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapMarkers extends ConsumerWidget {
  const MapMarkers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(locationPickerNotifierProvider);
    if (s.selectedLocation == null) return const SizedBox.shrink();
    return const SizedBox.shrink();
  }
}
