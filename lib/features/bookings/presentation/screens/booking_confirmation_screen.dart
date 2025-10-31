import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/email/services/email_services.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_provider.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final EventEntity event;

  const BookingConfirmationScreen({super.key, required this.event});

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  BookingEntity? _booking;
  bool _actionsDone = false;
  dynamic _error;

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
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startSuccessAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _checkController.forward();
        _fadeController.forward();
        _scaleController.forward();
      }
    });

    // Auto-navigate to booking details after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _booking != null) {
        context.go(
          '/booking-details',
          extra: {'booking': _booking!, 'event': widget.event},
        );
      }
    });
  }

  Future<void> _performPostActions(BookingEntity booking) async {
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.uid ?? '';
    if (userId.isEmpty) return;

    final userEmail = authState.user?.email ?? '';

    try {
      await EmailService.sendInvoice(
        userId,
        booking.id,
        booking.totalAmount,
        userEmail,
      );
    } catch (e) {
      print('⚠️ Email failed but continuing: $e');
    }

    if (!mounted) return;

    ref.invalidate(userBookingsProvider(userId));

    if (booking.paymentMethod == 'wallet') {
      if (!mounted) return;
      await ref.read(walletNotifierProvider.notifier).fetchWallet(userId);
      print('✓ Wallet refreshed, new balance should be visible');
    }
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

    final asyncValue = ref.watch(bookingNotifierProvider);

    BookingEntity? currentBooking;
    bool showLoading = true;
    String? errorMessage;

    asyncValue.when(
      data: (booking) {
        currentBooking = booking;
        showLoading = false;
      },
      loading: () {
        showLoading = true;
        currentBooking = _booking;
      },
      error: (error, stackTrace) {
        showLoading = false;
        currentBooking = null;
        errorMessage = error is Failure ? error.message : error.toString();
      },
    );

    if (currentBooking != _booking) {
      _booking = currentBooking;
      if (_booking != null) {
        _startSuccessAnimations();
        if (!_actionsDone) {
          _actionsDone = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _performPostActions(_booking!);
          });
        }
      }
    }

    if (errorMessage != null && _error != errorMessage) {
      _error = errorMessage;
    }

    if (showLoading) {
      return Scaffold(
        backgroundColor: AppColors.getBackground(isDark),
        body: SafeArea(
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.getPrimary(isDark),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingLarge),
                    Text(
                      'Confirming Your Booking',
                      style: AppTextStyles.headingMedium(isDark: isDark),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Reserving your seat...',
                      style: AppTextStyles.bodyMedium(
                        isDark: isDark,
                      ).copyWith(color: AppColors.getTextSecondary(isDark)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_booking != null) {
      return Scaffold(
        backgroundColor: AppColors.getBackground(isDark),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                                    AppColors.getPrimary(
                                      isDark,
                                    ).withOpacity(0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.getPrimary(
                                      isDark,
                                    ).withOpacity(0.4),
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
                          SizedBox(
                            height: ResponsiveUtil.getSpacing(
                              context,
                              baseSpacing: 24,
                            ),
                          ),

                          // Success message
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Booking Confirmed!',
                                  style:
                                      AppTextStyles.headingLarge(
                                        isDark: isDark,
                                      ).copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: titleFontSize,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: ResponsiveUtil.getSpacing(
                                    context,
                                    baseSpacing: 12,
                                  ),
                                ),
                                Text(
                                  'Your seat has been reserved',
                                  style: AppTextStyles.bodyLarge(isDark: isDark)
                                      .copyWith(
                                        color: AppColors.getTextSecondary(
                                          isDark,
                                        ),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtil.getSpacing(
                              context,
                              baseSpacing: 24,
                            ),
                          ),

                          // Booking details card
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Center(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: cardMaxWidth,
                                  ),
                                  padding: EdgeInsets.all(
                                    ResponsiveUtil.getPadding(context),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.getSurface(isDark),
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtil.getBorderRadius(
                                        context,
                                        baseRadius: 16,
                                      ),
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
                                      SizedBox(
                                        height: ResponsiveUtil.getSpacing(
                                          context,
                                          baseSpacing: 12,
                                        ),
                                      ),
                                      _buildDetailRow(
                                        'Ticket Type',
                                        _booking!.ticketType,
                                        Icons.confirmation_number_outlined,
                                        isDark,
                                        context,
                                      ),
                                      SizedBox(
                                        height: ResponsiveUtil.getSpacing(
                                          context,
                                          baseSpacing: 12,
                                        ),
                                      ),
                                      _buildDetailRow(
                                        'Quantity',
                                        '${_booking!.ticketQuantity} ticket${_booking!.ticketQuantity > 1 ? 's' : ''}',
                                        Icons.people_outline,
                                        isDark,
                                        context,
                                      ),
                                      SizedBox(
                                        height: ResponsiveUtil.getSpacing(
                                          context,
                                          baseSpacing: 12,
                                        ),
                                      ),
                                      _buildDetailRow(
                                        'Total Amount',
                                        '₹${_booking!.totalAmount.toStringAsFixed(0)}',
                                        Icons.payments_outlined,
                                        isDark,
                                        context,
                                      ),
                                      SizedBox(
                                        height: ResponsiveUtil.getSpacing(
                                          context,
                                          baseSpacing: 12,
                                        ),
                                      ),
                                      _buildDetailRow(
                                        'Payment Method',
                                        _booking!.paymentMethod == 'wallet'
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
                          SizedBox(
                            height: ResponsiveUtil.getSpacing(
                              context,
                              baseSpacing: 24,
                            ),
                          ),

                          // Skip button
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: TextButton(
                              onPressed: () {
                                context.go(
                                  '/booking-details',
                                  extra: {
                                    'booking': _booking!,
                                    'event': widget.event,
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtil.getPadding(
                                    context,
                                  ),
                                  vertical: isMobile ? 12 : 16,
                                ),
                              ),
                              child: Text(
                                'View Details Now',
                                style: AppTextStyles.bodyMedium(isDark: isDark)
                                    .copyWith(
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

    // Error UI
    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(AppSizes.paddingXl),
            margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.getError(isDark),
                  size: 64,
                ),
                SizedBox(height: AppSizes.spacingLarge),
                Text(
                  'Booking Failed',
                  style: AppTextStyles.headingMedium(isDark: isDark),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.spacingSmall),
                Text(
                  errorMessage ?? 'An unknown error occurred',
                  style: AppTextStyles.bodyMedium(
                    isDark: isDark,
                  ).copyWith(color: AppColors.getTextSecondary(isDark)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.spacingLarge),
                ElevatedButton(
                  onPressed: () => context.go('/root'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimary(isDark),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
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
