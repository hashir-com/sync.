import 'package:equatable/equatable.dart';

class CalendarEventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String category;
  final String imageUrl;
  final int availableTickets;
  final double price;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.availableTickets,
    required this.price,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        location,
        category,
        imageUrl,
        availableTickets,
        price,
      ];
}