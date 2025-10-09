import 'package:sync_event/features/events/domain/entities/event_entity.dart';

/// UseCase for searching events
class SearchEventsUseCase {
  List<EventEntity> execute(List<EventEntity> events, String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return events
        .where(
          (event) =>
              event.title.toLowerCase().contains(lowerQuery) ||
              event.category.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}