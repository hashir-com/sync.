import 'package:flutter/material.dart';
import '../../domain/entities/event_entity.dart';

class EventCard extends StatelessWidget {
  final EventEntity event;
  const EventCard({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    final start = event.startTime;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: event.imageUrl != null
          ? SizedBox(
              width: 72,
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(event.imageUrl!, fit: BoxFit.cover)),
            )
          : SizedBox(width: 72, child: Placeholder()),
      title: Text(event.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.location),
          const SizedBox(height: 4),
          Text('${start.toLocal()} • ${event.category}'),
          if (event.ticketPrice! > 0) Text('Price: ₹${event.ticketPrice?.toStringAsFixed(2)}'),
        ],
      ),
      isThreeLine: true,
    );
  }
}
