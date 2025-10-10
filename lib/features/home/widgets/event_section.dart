// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'event_card_content.dart';

class EventSection extends ConsumerWidget {
  const EventSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(approvedEventsStreamProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF120D26),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/my_events'),
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF747688), fontSize: 14),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF747688),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: eventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return const Center(
                  child: Text(
                    'No events available',
                    style: TextStyle(color: Color(0xFF747688)),
                  ),
                );
              }

              // Show first 3 events
              final displayEvents = events.toList();

              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: displayEvents.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () => context.push('/event-detail', extra: event),
                      child: _buildEventCard(event: event),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error loading events',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF120D26),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF747688), fontSize: 14),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF747688),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEventCard({required dynamic event}) {
    final dateFormat = DateFormat('dd\nMMM');
    final formattedDate = dateFormat.format(event.startTime);
    final attendeesText = '${event.attendees.length} Going';

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventImage(formattedDate, event),
          EventCardContent(
            title: event.title,
            location: event.location,
            attendees: attendeesText,
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage(String date, dynamic event) {
    final categoryColors = {
      'Music': const Color(0xFFFFE4E1),
      'Sports': const Color(0xFFE0F4FF),
      'Technology': const Color(0xFFE8F5E8),
      'Business': const Color(0xFFFFF3E0),
      'Art & Culture': const Color(0xFFF3E5F5),
      'Food & Drink': const Color(0xFFFFEBEE),
      'Health & Wellness': const Color(0xFFE0F2F1),
      'Education': const Color(0xFFE3F2FD),
      'Entertainment': const Color(0xFFFFF8E1),
      'Other': const Color(0xFFF5F5F5),
    };

    final color = categoryColors[event.category] ?? const Color(0xFFF5F5F5);

    return Stack(
      children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: event.imageUrl != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    event.imageUrl!,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: _getImageIcon(event.category)),
                  ),
                )
              : Center(child: _getImageIcon(event.category)),
        ),
        Positioned(top: 12, left: 12, child: _buildDateTag(date)),
        const Positioned(top: 12, right: 12, child: _BookmarkIcon()),
      ],
    );
  }

  Widget _getImageIcon(String category) {
    switch (category) {
      case 'Music':
        return const Icon(Icons.music_note, size: 60, color: Color(0xFFFF9999));
      case 'Sports':
        return const Icon(Icons.sports, size: 60, color: Color(0xFF66B2FF));
      case 'Technology':
        return const Icon(Icons.computer, size: 60, color: Color(0xFF4CAF50));
      case 'Business':
        return const Icon(Icons.business, size: 60, color: Color(0xFFFF9800));
      case 'Art & Culture':
        return const Icon(Icons.palette, size: 60, color: Color(0xFF9C27B0));
      case 'Food & Drink':
        return const Icon(Icons.restaurant, size: 60, color: Color(0xFFE91E63));
      case 'Health & Wellness':
        return const Icon(
          Icons.fitness_center,
          size: 60,
          color: Color(0xFF00BCD4),
        );
      case 'Education':
        return const Icon(Icons.school, size: 60, color: Color(0xFF2196F3));
      case 'Entertainment':
        return const Icon(Icons.movie, size: 60, color: Color(0xFFFFC107));
      default:
        return const Icon(Icons.event, size: 60, color: Color(0xFF757575));
    }
  }

  Widget _buildDateTag(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        date,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFF6B6B),
          height: 1.2,
        ),
      ),
    );
  }
}

class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.bookmark_border,
        size: 18,
        color: Color(0xFFFF6B6B),
      ),
    );
  }
}
