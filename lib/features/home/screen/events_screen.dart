import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // simple placeholder for Events
      appBar: AppBar(title: Text('Events')),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 12,
        itemBuilder: (ctx, i) => Card(
          child: ListTile(
            title: Text('Event ${i + 1}'),
            subtitle: Text('Venue ${i + 1}'),
            leading: CircleAvatar(child: Icon(Icons.event)),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
