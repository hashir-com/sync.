import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final BookingEntity booking;
  final EventEntity event;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.event,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _checkController.forward();
        _fadeController.forward();
        _scaleController.forward();
      }
    });

    // Auto-navigate to booking details after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(
          '/booking-details',
          extra: {'booking': widget.booking, 'event': widget.event},
        );
      }
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveUtil.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final checkSize = isMobile ? 100.0 : 120.0;
    final checkIconSize = isMobile ? 60.0 : 70.0;
    final titleFontSize = isMobile ? 24.0 : 28.0;
    final cardMaxWidth = isMobile ? screenWidth * 0.9 : 500.0;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: ResponsiveUtil.getResponsivePadding(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Add top spacing
                        SizedBox(height: screenHeight * 0.05),
                        
                        // Animated checkmark
                        ScaleTransition(
                          scale: _checkAnimation,
                          child: Container(
                            width: checkSize,
                            height: checkSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.getPrimary(isDark),
                                  AppColors.getPrimary(isDark).withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getPrimary(isDark).withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: checkIconSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 24)),

                        // Success message
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Booking Confirmed!',
                                style: AppTextStyles.headingLarge(isDark: isDark).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
                              Text(
                                'Your seat has been reserved',
                                style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 24)),

                        // Booking details card
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Center(
                              child: Container(
                                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                                padding: EdgeInsets.all(
                                  ResponsiveUtil.getPadding(context),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getSurface(isDark),
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUtil.getBorderRadius(context, baseRadius: 16),
                                  ),
                                  border: Border.all(
                                    color: AppColors.getBorder(isDark),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildDetailRow(
                                      'Event',
                                      widget.event.title,
                                      Icons.event,
                                      isDark,
                                      context,
                                    ),
                                    SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
                                    _buildDetailRow(
                                      'Ticket Type',
                                      widget.booking.ticketType,
                                      Icons.confirmation_number_outlined,
                                      isDark,
                                      context,
                                    ),
                                    SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
                                    _buildDetailRow(
                                      'Quantity',
                                      '${widget.booking.ticketQuantity} ticket${widget.booking.ticketQuantity > 1 ? 's' : ''}',
                                      Icons.people_outline,
                                      isDark,
                                      context,
                                    ),
                                    SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
                                    _buildDetailRow(
                                      'Total Amount',
                                      '₹${widget.booking.totalAmount.toStringAsFixed(0)}',
                                      Icons.payments_outlined,
                                      isDark,
                                      context,
                                    ),
                                    SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
                                    _buildDetailRow(
                                      'Payment Method',
                                      widget.booking.paymentMethod == 'wallet'
                                          ? 'Wallet'
                                          : 'Razorpay',
                                      Icons.account_balance_wallet_outlined,
                                      isDark,
                                      context,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 24)),

                        // Loading indicator
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              SizedBox(
                                width: isMobile ? 24 : 30,
                                height: isMobile ? 24 : 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: isMobile ? 2.5 : 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.getPrimary(isDark),
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
                              Text(
                                'Preparing your ticket...',
                                style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                  color: AppColors.getTextSecondary(isDark),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 16)),

                        // Skip button
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: TextButton(
                            onPressed: () {
                              context.go(
                                '/booking-details',
                                extra: {
                                  'booking': widget.booking,
                                  'event': widget.event
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtil.getPadding(context),
                                vertical: isMobile ? 12 : 16,
                              ),
                            ),
                            child: Text(
                              'View Details Now',
                              style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                                color: AppColors.getPrimary(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        // Add bottom spacing
                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
    BuildContext context,
  ) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final iconSize = isMobile ? 18.0 : 20.0;
    final iconPadding = isMobile ? 6.0 : 8.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: AppColors.getPrimary(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.getBorderRadius(context, baseRadius: 8),
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: AppColors.getPrimary(isDark),
          ),
        ),
        SizedBox(width: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondary(isDark),
                  fontSize: isMobile ? 11 : 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 13 : 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}