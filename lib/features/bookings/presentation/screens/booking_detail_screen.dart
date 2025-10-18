import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:printing/printing.dart';
import 'package:sync_event/features/email/services/email_services.dart';
import 'package:sync_event/features/bookings/presentation/utils/invoice_generator.dart';
import 'package:sync_event/features/bookings/presentation/utils/booking_utils.dart';
import 'dart:math' as math;

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final BookingEntity booking;
  final EventEntity event;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.event,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _fadeController;
  late Animation<double> _flipAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    print('Booking: ${widget.booking.toString()}');
    print('Event: ${widget.event.toString()}');

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    if (_flipController.isAnimating) _flipController.stop();
    if (_fadeController.isAnimating) _fadeController.stop();
    _flipController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isFlipped = !_isFlipped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Your Ticket',
          style: AppTextStyles.headingMedium(
            isDark: isDark,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.getBackground(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.getPrimary(isDark),
          ),
          onPressed: () {
            print('Navigating back. Can pop: ${context.canPop()}');
            context.go('/home');
          },
        ),
        actions: [
          if (widget.booking.status == 'confirmed')
            IconButton(
              tooltip: 'Cancel & Refund',
              icon: Icon(
                Icons.cancel_outlined,
                color: AppColors.getError(isDark),
              ),
              onPressed: () => _showCancellationOptions(context, isDark),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLarge.w),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: AppSizes.spacingMedium.h),
                  _buildFlipTicketCard(isDark),
                  SizedBox(height: AppSizes.spacingXxl.h),
                  _buildAdditionalDetailsSection(isDark),
                  SizedBox(height: AppSizes.spacingXxl.h),
                  _buildActionButtons(isDark),
                  SizedBox(height: AppSizes.paddingLarge.h),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlipTicketCard(bool isDark) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: SizedBox(
        height: 280.h,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * math.pi;
            final isBack = _flipAnimation.value > 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildTicketBack(isDark),
                    )
                  : _buildTicketFront(isDark),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketFront(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDark).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.getPrimary(isDark),
                    AppColors.getPrimary(isDark).withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingLarge.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EVENT TICKET',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.booking.ticketType.isNotEmpty
                              ? widget.booking.ticketType.toUpperCase()
                              : 'N/A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title.isNotEmpty
                            ? widget.event.title
                            : 'Unknown Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        DateFormat('MMM d, y').format(widget.booking.startTime),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.id.isNotEmpty
                            ? 'Booking ID: ${widget.booking.id.substring(0, 8).toUpperCase()}'
                            : 'Booking ID: N/A',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Qty: ${widget.booking.ticketQuantity}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tap to flip →',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketBack(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDark).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Positioned(
              top: 40.h,
              left: 0,
              right: 0,
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2E)
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium.w),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'BOOKING DETAILS',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailItem(
                      label: 'Time',

                      value: DateFormat(
                        'h:mm a',
                      ).format(widget.booking.startTime),
                      isDark: isDark,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailItem(
                      label: 'Location',
                      value: widget.event.location.isNotEmpty
                          ? widget.event.location.split(',').first
                          : 'Unknown',
                      isDark: isDark,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailItem(
                      label: 'Amount',
                      value:
                          '₹${widget.booking.totalAmount.toStringAsFixed(0)}',
                      isDark: isDark,
                      highlight: true,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailItem(
                      label: 'Status',
                      value: widget.booking.status.isNotEmpty
                          ? widget.booking.status.toUpperCase()
                          : 'N/A',
                      isDark: isDark,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Tap to return →',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 9.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required bool isDark,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: highlight
                ? AppColors.getPrimary(isDark)
                : (isDark ? Colors.white : Colors.black87),
            fontSize: highlight ? 14.sp : 12.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDark),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: AppSizes.spacingMedium.w),
            Text(
              'Full Details',
              style: AppTextStyles.headingSmall(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingLarge.h),
        _buildDetailCard(
          title: 'Booking Information',
          isDark: isDark,
          children: [
            _buildDetailItem2(
              icon: Icons.confirmation_number_outlined,
              label: 'Booking ID',
              value: widget.booking.id.isNotEmpty ? widget.booking.id : 'N/A',
              isDark: isDark,
            ),
            _buildDetailItem2(
              icon: Icons.event_seat_outlined,
              label: 'Ticket Type',
              value: widget.booking.ticketType.isNotEmpty
                  ? '${widget.booking.ticketType.toUpperCase()} (x${widget.booking.ticketQuantity})'
                  : 'N/A',
              isDark: isDark,
            ),
            _buildDetailItem2(
              icon: Icons.payment_outlined,
              label: 'Total Amount',
              value: '₹${widget.booking.totalAmount.toStringAsFixed(2)}',
              isDark: isDark,
            ),
            _buildDetailItem2(
              icon: Icons.calendar_month_outlined,
              label: 'Booking Date',
              value: DateFormat(
                'MMM d, y h:mm a',
              ).format(widget.booking.bookingDate),
              isDark: isDark,
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingLarge.h),
        _buildDetailCard(
          title: 'Event Information',
          isDark: isDark,
          children: [
            _buildDetailItem2(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: widget.event.location.isNotEmpty
                  ? widget.event.location
                  : 'Unknown',
              isDark: isDark,
            ),
            _buildDetailItem2(
              icon: Icons.access_time_outlined,
              label: 'Start Time',
              value: DateFormat('h:mm a').format(widget.booking.startTime),
              isDark: isDark,
            ),
            _buildDetailItem2(
              icon: Icons.timelapse_rounded,
              label: 'End Time',
              value: DateFormat('h:mm a').format(widget.booking.endTime),
              isDark: isDark,
            ),
          ],
        ),
        if (widget.booking.status == 'cancelled') ...[
          SizedBox(height: AppSizes.spacingLarge.h),
          _buildDetailCard(
            title: 'Cancellation Details',
            isDark: isDark,
            children: [
              if (widget.booking.cancellationDate != null)
                _buildDetailItem2(
                  icon: Icons.cancel_outlined,
                  label: 'Cancelled On',
                  value: DateFormat(
                    'MMM d, y h:mm a',
                  ).format(widget.booking.cancellationDate!),
                  isDark: isDark,
                ),
              if (widget.booking.refundAmount != null)
                _buildDetailItem2(
                  icon: Icons.money_outlined,
                  label: 'Refund Amount',
                  value: '₹${widget.booking.refundAmount!.toStringAsFixed(2)}',
                  isDark: isDark,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge.w),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDark).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index < children.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.spacingMedium.h,
                    ),
                    child: Divider(
                      color: AppColors.getBorder(isDark).withOpacity(0.2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem2({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: AppColors.getPrimary(isDark)),
        SizedBox(width: AppSizes.spacingMedium.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall(
                  isDark: isDark,
                ).copyWith(color: AppColors.getTextSecondary(isDark)),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: AppTextStyles.bodyMedium(
                  isDark: isDark,
                ).copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightLarge.h,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final bytes = await InvoiceGenerator.generate(
                    widget.booking,
                    widget.event,
                  );
                  await Printing.layoutPdf(
                    onLayout: (_) async => bytes,
                    name: 'Invoice_${widget.booking.id}.pdf',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error generating invoice: $e'),
                      backgroundColor: AppColors.getError(isDark),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Invoice'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.getPrimary(isDark)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.spacingMedium.w),
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightLarge.h,
            child: ElevatedButton(
              onPressed: () {
                print('Navigating back. Can pop: ${context.canPop()}');
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
                ),
              ),
              child: Text(
                'Back',
                style: AppTextStyles.labelMedium(
                  isDark: isDark,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancellationOptions(BuildContext context, bool isDark) async {
    final eligible = BookingUtils.isEligibleForCancellation(
      widget.booking.startTime,
    );
    if (!eligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot cancel within 48 hours of event start.',
            style: AppTextStyles.bodyMedium(
              isDark: true,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.getError(isDark),
        ),
      );
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium.w),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Refund to Wallet'),
                  onTap: () => Navigator.pop(context, 'wallet'),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_outlined),
                  title: const Text('Refund to Bank'),
                  onTap: () => Navigator.pop(context, 'bank'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (choice == null) return;
    try {
      print('Invalidating bookings for userId: ${widget.booking.userId}');
      await ref
          .read(bookingNotifierProvider.notifier)
          .cancelBooking(
            widget.booking.id,
            widget.booking.paymentId,
            widget.booking.eventId,
            refundType: choice,
          );
      ref.invalidate(userBookingsProvider(widget.booking.userId));
      try {
        await EmailService.sendCancellationNotice(
          widget.booking.userId,
          widget.booking.id,
          widget.booking.totalAmount,
        );
      } catch (_) {}
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cancellation requested. Refund will be processed shortly.',
              style: AppTextStyles.bodyMedium(
                isDark: true,
              ).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.getSuccess(isDark),
          ),
        );
      }
      if (context.canPop()) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error cancelling booking: $e',
              style: AppTextStyles.bodyMedium(
                isDark: true,
              ).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.getError(isDark),
          ),
        );
      }
    }
  }
}
