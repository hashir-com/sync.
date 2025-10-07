// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'event_card_content.dart';

class EventSection extends StatelessWidget {
  const EventSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Events', style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF120D26),
              )),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('See All', style: TextStyle(
                      color: Color(0xFF747688),
                      fontSize: 14,
                    )),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF747688)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildEventCard(
                date: '10\nJUNE',
                title: 'International Band Mu...',
                image: 'band',
                location: '36 Guild Street London, UK',
                attendees: '+20 Going',
                color: const Color(0xFFFFE4E1),
              ),
              const SizedBox(width: 16),
              _buildEventCard(
                date: '10\nJUNE',
                title: 'Jo Malone L...',
                image: 'perfume',
                location: 'Radius Gallery • Santa Cruz, CA',
                attendees: '+2k',
                color: const Color(0xFFE0F4FF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nearby You', style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF120D26),
              )),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('See All', style: TextStyle(
                      color: Color(0xFF747688),
                      fontSize: 14,
                    )),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF747688)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEventCard({
    required String date,
    required String title,
    required String image,
    required String location,
    required String attendees,
    required Color color,
  }) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventImage(date, image, color),
          EventCardContent(title: title, location: location, attendees: attendees),
        ],
      ),
    );
  }

  Widget _buildEventImage(String date, String image, Color color) {
    return Stack(
      children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Center(child: _getImageIcon(image)),
        ),
        Positioned(top: 12, left: 12, child: _buildDateTag(date)),
        const Positioned(top: 12, right: 12, child: _BookmarkIcon()),
      ],
    );
  }

  Widget _getImageIcon(String image) {
    return image == 'band'
        ? const Icon(Icons.music_note, size: 60, color: Color(0xFFFF9999))
        : const Icon(Icons.water_drop, size: 60, color: Color(0xFF66B2FF));
  }

  Widget _buildDateTag(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Text(date, textAlign: TextAlign.center, style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFF6B6B),
        height: 1.2,
      )),
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
      child: const Icon(Icons.bookmark_border, size: 18, color: Color(0xFFFF6B6B)),
    );
  }
}