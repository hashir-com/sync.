import '../entities/event_entity.dart';
import 'dart:io';

abstract class EventRepository {
  /// Create a new event (pending approval)
  Future<void> createEvent(EventEntity event, {File? docFile, File? coverFile});

  /// Approve an event (admin action)
  Future<void> approveEvent(String eventId, {required String approvedBy});

  /// Get all approved events (for users)
  Future<List<EventEntity>> getApprovedEvents();

  /// Get all pending events (for admin dashboard)
  Future<List<EventEntity>> getPendingEvents();

  /// Join an event (add user to attendees)
  Future<void> joinEvent(String eventId, String userId);
}
