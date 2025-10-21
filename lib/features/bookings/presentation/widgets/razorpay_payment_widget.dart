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
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

class RazorpayPaymentWidget extends ConsumerStatefulWidget {
  final double amount;
  final void Function(String paymentId) onSuccess;

  const RazorpayPaymentWidget({
    super.key,
    required this.amount,
    required this.onSuccess,
  });

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
    final isDark = ref.watch(themeProvider);
    final authState = ref.watch(authNotifierProvider);

    var options = {
      'key': 'rzp_test_RU0yq41o7lOiIN',
      'amount': (widget.amount * 100).toInt(),
      'name': 'Sync Event',
      'description': 'Event Ticket Booking',
      'prefill': {
        'contact': authState.user?.phoneNumber ?? '',
        'email': authState.user?.email ?? '',
      },
      'external': {
        'wallets': ['paytm'],
      },
      'theme': {
        'color':
            '#${AppColors.getPrimary(isDark).value.toRadixString(16).padLeft(8, '0').substring(2)}',
      },
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Successful!',
          style: AppTextStyles.bodyMedium(
            isDark: true,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.getSuccess(ref.watch(themeProvider)),
      ),
    );

    if (response.paymentId != null) {
      widget.onSuccess(response.paymentId!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment completed, but payment ID is missing.',
            style: AppTextStyles.bodyMedium(
              isDark: true,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.getError(ref.watch(themeProvider)),
        ),
      );
    }
    // pass paymentId
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Failed: ${response.message}',
          style: AppTextStyles.bodyMedium(
            isDark: true,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.getError(ref.watch(themeProvider)),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Optional: handle external wallet
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
        ),
      ),
      child: Text(
        'Pay ₹${widget.amount.toStringAsFixed(2)}',
        style: AppTextStyles.button(
          isDark: isDark,
        ).copyWith(color: Colors.white),
      ),
    );
  }
}
