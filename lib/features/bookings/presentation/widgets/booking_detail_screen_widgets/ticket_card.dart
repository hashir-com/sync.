import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_detail_screen_widgets/ticket_back.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_detail_screen_widgets/ticket_front.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'dart:math' as math;

// Widget for the flippable ticket card with animation
class TicketCard extends StatefulWidget {
  final BookingEntity booking;
  final EventEntity event;

  const TicketCard({super.key, required this.booking, required this.event});

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _fadeController;
  late Animation<double> _flipAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFlipped = false;

  // Initialize animation controllers and animations
  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _flipController, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  // Dispose animation controllers
  @override
  void dispose() {
    if (_flipController.isAnimating) _flipController.stop();
    if (_fadeController.isAnimating) _fadeController.stop();
    _flipController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Toggle flip animation
  void _toggleFlip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  // Build the flippable ticket card
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: SizedBox(
        height: 280.h,
        width: double.infinity,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * math.pi;
              final isBack = _flipAnimation.value > 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                child: isBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: TicketBack(booking: widget.booking, event: widget.event),
                      )
                    : TicketFront(booking: widget.booking, event: widget.event),
              );
            },
          ),
        ),
      ),
    );
  }
}