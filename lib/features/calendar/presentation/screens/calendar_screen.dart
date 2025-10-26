// calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/features/calendar/domain/entities/calendar_event_entity.dart';
import 'package:sync_event/features/calendar/presentation/providers/calendar_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Map of normalized date -> events
  Map<DateTime, List<CalendarEventEntity>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<CalendarEventEntity> _getEventsForDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    return _eventsByDate[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    // Month range for fetching events
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final currentRange = DateTimeRange(start: firstDay, end: lastDay);

    final eventsAsync = ref.watch(eventsForDateRangeProvider(currentRange));

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.getCard(isDark),
        title: Text(
          DateFormat('MMMM yyyy').format(_focusedDay),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Widget
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCard(isDark),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: eventsAsync.when(
              data: (events) {
                // Group events by date
                _eventsByDate = {};
                for (var event in events) {
                  final dateKey = _normalizeDate(event.startDate);
                  _eventsByDate.putIfAbsent(dateKey, () => []).add(event);
                }

                return TableCalendar<CalendarEventEntity>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.getPrimary(isDark).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.getPrimary(isDark),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppColors.getPrimary(isDark),
                      shape: BoxShape.circle,
                    ),
                    markerSize: 6,
                    markersMaxCount: 3,
                    markersAlignment: Alignment.bottomCenter,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                    defaultTextStyle: TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    weekendTextStyle: TextStyle(
                      color: AppColors.getPrimary(isDark),
                    ),
                    outsideDaysVisible: false,
                    cellMargin: const EdgeInsets.all(4),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: false,
                    formatButtonShowsNext: false,
                    titleTextStyle: const TextStyle(fontSize: 0),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    formatButtonDecoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.getPrimary(isDark).withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: AppColors.getPrimary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                    formatButtonPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: AppColors.getPrimary(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },

                  // Use CalendarBuilders.markerBuilder to render stacked dot markers (Google-like)
                  calendarBuilders: CalendarBuilders<CalendarEventEntity>(
                    markerBuilder: (context, date, eventsForDay) {
                      if (eventsForDay.isEmpty) return const SizedBox.shrink();

                      // Show up to 3 dots stacked horizontally (you can customize)
                      final dotsToShow = eventsForDay.length > 3
                          ? 3
                          : eventsForDay.length;
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(dotsToShow, (i) {
                              // You can choose colors per-event if event has a color field.
                              // For now reuse primary color but slightly vary opacity.
                              final opacity = 1.0 - (i * 0.2);
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getPrimary(
                                    isDark,
                                  ).withOpacity(opacity),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) {
                debugPrint('Calendar Error: $error');
                return SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load events',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            // Invalidate the provider instance for the current month so it refetches
                            ref.invalidate(
                              eventsForDateRangeProvider(currentRange),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Events list for selected day
          Expanded(child: _buildEventsList(isDark)),
        ],
      ),
    );
  }

  Widget _buildEventsList(bool isDark) {
    if (_selectedDay == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a date to view events',
              style: TextStyle(
                color: AppColors.getTextSecondary(isDark),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final eventsAsync = ref.watch(eventsForDayProvider(_selectedDay!));

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No events on ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header with event count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.getTextSecondary(isDark).withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 20,
                    color: AppColors.getPrimary(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${events.length} event${events.length > 1 ? 's' : ''} on ${DateFormat('EEEE, MMM dd').format(_selectedDay!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Events list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildGoogleStyleEventCard(event, isDark);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: TextStyle(color: AppColors.getTextSecondary(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleStyleEventCard(CalendarEventEntity event, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: AppColors.getPrimary(isDark), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/event-detail', extra: event.toEventEntity());
          },

          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                SizedBox(
                  width: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(event.startDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(event.endDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Event image (safe fallback)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (event.imageUrl.isNotEmpty)
                      ? Image.network(
                          event.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _imageFallback(isDark);
                          },
                        )
                      : _imageFallback(isDark),
                ),

                const SizedBox(width: 16),

                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimary(
                                isDark,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '₹${event.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimary(isDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tickets available
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: event.availableTickets > 0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  event.availableTickets > 0
                                      ? Icons.confirmation_number
                                      : Icons.block,
                                  size: 12,
                                  color: event.availableTickets > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${event.availableTickets} left',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: event.availableTickets > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback(bool isDark) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.event, color: AppColors.getPrimary(isDark), size: 30),
    );
  }
}
