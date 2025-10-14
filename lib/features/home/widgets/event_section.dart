// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'event_card_content.dart';

class EventSection extends ConsumerStatefulWidget {
  const EventSection({super.key});

  @override
  ConsumerState<EventSection> createState() => _EventSectionState();
}

class _EventSectionState extends ConsumerState<EventSection> {
  Position? _currentPosition;
  bool _locationDenied = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationDenied = true);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locationDenied = true);
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = pos;
      _locationDenied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(approvedEventsStreamProvider);

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        children: [
          // ------- UPCOMING EVENTS -------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF120D26),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/events'),
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: const Color(0xFF747688),
                          fontSize: 14.sp,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.sp,
                        color: const Color(0xFF747688),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ------- UPCOMING EVENTS LIST -------
          SizedBox(
            height: 260.h,
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

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: InkWell(
                        onTap: () =>
                            context.push('/event-detail', extra: event),
                        child: _buildEventCard(event: event),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error loading events',
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // NEARBY YOU 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby You',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF120D26),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: const Color(0xFF747688),
                          fontSize: 14.sp,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.sp,
                        color: const Color(0xFF747688),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          //  NEARBY EVENTS LIST 
          _locationDenied
              ? Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    'Turn on location to see nearby events.',
                    style: TextStyle(
                      color: const Color(0xFF747688),
                      fontSize: 14.sp,
                    ),
                  ),
                )
              : _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 280.h,
                  child: eventsAsync.when(
                    data: (events) {
                      final nearbyEvents = events.toList();

                      // sort by distance
                      nearbyEvents.sort((a, b) {
                        double distA = Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          a.latitude ?? 0.0,
                          a.longitude ?? 0.0,
                        );
                        double distB = Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          b.latitude ?? 0.0,
                          b.longitude ?? 0.0,
                        );
                        return distA.compareTo(distB);
                      });

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: nearbyEvents.length,
                        itemBuilder: (context, index) {
                          final event = nearbyEvents[index];

                          final distanceMeters = Geolocator.distanceBetween(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            event.latitude ?? 0.0,
                            event.longitude ?? 0.0,
                          );
                          final distanceKm = (distanceMeters / 1000)
                              .toStringAsFixed(1);

                          return Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: InkWell(
                              onTap: () =>
                                  context.push('/event-detail', extra: event),
                              child: _buildEventCard(
                                event: event,
                                distanceKm: distanceKm,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text(
                        'Error loading nearby events',
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // HELPER WIDGETS 
  Widget _buildEventCard({required dynamic event, String? distanceKm}) {
    final dateFormat = DateFormat('dd\nMMM');
    final formattedDate = dateFormat.format(event.startTime);
    final attendeesText = '${event.attendees.length} Going';

    return Container(
      width: 240.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventCardContent(
                  title: event.title,
                  location: event.location,
                  attendees: attendeesText,
                ),
                if (distanceKm != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '$distanceKm km away',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF00796B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage(String date, dynamic event) {
    final color = Colors.grey.shade200;
    return Stack(
      children: [
        Container(
          height: 130.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: event.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: Image.network(
                    event.imageUrl!,
                    width: double.infinity,
                    height: 130.h,
                    fit: BoxFit.cover,
                  ),
                )
              : const Center(child: Icon(Icons.event, size: 60)),
        ),
        Positioned(top: 12.h, left: 12.w, child: _buildDateTag(date)),
        const Positioned(top: 12, right: 12, child: _BookmarkIcon()),
      ],
    );
  }

  Widget _buildDateTag(String date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        date,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF6B6B),
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
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(
        Icons.bookmark_border,
        size: 18.sp,
        color: const Color(0xFFFF6B6B),
      ),
    );
  }
}
