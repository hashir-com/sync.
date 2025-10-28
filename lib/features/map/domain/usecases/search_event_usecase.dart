// File: features/map/domain/usecases/search_events_usecase.dart
// Purpose: Filter events based on search query
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class SearchEventsUseCase {
  // Execute: Filter events by title, description, category, or location
  List<EventEntity> execute(List<EventEntity> events, String query) {
    print('SearchEventsUseCase: Filtering ${events.length} events with query "$query"');
    if (query.isEmpty) {
      print('SearchEventsUseCase: Empty query, returning all events');
      return events;
    }
    final lowercaseQuery = query.toLowerCase();
    final filtered = events.where((event) {
      final matchesTitle = event.title.toLowerCase().contains(lowercaseQuery);
      final matchesDescription = event.description.toLowerCase().contains(lowercaseQuery);
      final matchesCategory = event.category.toLowerCase().contains(lowercaseQuery);
      final matchesLocation = event.location.toLowerCase().contains(lowercaseQuery);
      return matchesTitle || matchesDescription || matchesCategory || matchesLocation;
    }).toList();
    print('SearchEventsUseCase: Found ${filtered.length} results for query "$query"');
    return filtered;
  }
}