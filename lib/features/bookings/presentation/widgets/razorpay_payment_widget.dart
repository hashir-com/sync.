// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/util/theme_util.dart';

class RazorpayPaymentWidget extends ConsumerStatefulWidget {
  final double amount;
  final VoidCallback onSuccess;

  const RazorpayPaymentWidget({
    Key? key,
    required this.amount,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _RazorpayPaymentWidgetState createState() => _RazorpayPaymentWidgetState();
}

class _RazorpayPaymentWidgetState extends ConsumerState<RazorpayPaymentWidget> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    final isDark = ref.watch(themeProvider); // Assume themeProvider exists
    var options = {
      'key': 'rzp_test_your_key', // Replace with your Razorpay test key
      'amount': (widget.amount * 100).toInt(), // Amount in paise
      'name': 'Sync Event',
      'description': 'Event Ticket Booking',
      'prefill': {'contact': '', 'email': ''}, // Populate with user data if available
      'external': {'wallets': ['paytm']},
      'theme': {'color': AppColors.getPrimary(isDark).value.toRadixString(16).substring(2)},
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful!', style: AppTextStyles.bodyMedium(isDark: true).copyWith(color: Colors.white)),
        backgroundColor: AppColors.getSuccess(ref.watch(themeProvider)),
      ),
    );
    widget.onSuccess();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}', style: AppTextStyles.bodyMedium(isDark: true).copyWith(color: Colors.white)),
        backgroundColor: AppColors.getError(ref.watch(themeProvider)),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle if needed
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    return ElevatedButton(
      onPressed: _openCheckout,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.getPrimary(isDark),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.buttonPaddingHorizontal,
          vertical: AppSizes.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r)),
      ),
      child: Text('Pay ₹${widget.amount.toStringAsFixed(2)}', style: AppTextStyles.button(isDark: isDark).copyWith(color: Colors.white)),
    );
  }
}