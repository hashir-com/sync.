// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// import 'package:sync_event/core/constants/app_colors.dart';
// import 'package:sync_event/core/constants/app_sizes.dart';
// import 'package:sync_event/core/constants/app_text_styles.dart';
// import 'package:sync_event/core/constants/app_theme.dart';
// import 'package:sync_event/core/util/theme_util.dart';
// import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

// class RazorpayPaymentWidget extends ConsumerStatefulWidget {
//   final double amount;
//   final void Function(String paymentId) onSuccess;

//   const RazorpayPaymentWidget({
//     super.key,
//     required this.amount,
//     required this.onSuccess,
//   });

//   @override
//   _RazorpayPaymentWidgetState createState() => _RazorpayPaymentWidgetState();
// }

// class _RazorpayPaymentWidgetState extends ConsumerState<RazorpayPaymentWidget> {
//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   void _openCheckout() {
//     final isDark = ref.watch(themeProvider);
//     final authState = ref.watch(authNotifierProvider);

//     var options = {
//       'key': 'rzp_test_RU0yq41o7lOiIN',
//       'amount': (widget.amount * 100).toInt(),
//       'name': 'Sync Event',
//       'description': 'Event Ticket Booking',
//       'prefill': {
//         'contact': authState.user?.phoneNumber ?? '',
//         'email': authState.user?.email ?? '',
//       },
//       'external': {
//         'wallets': ['paytm'],
//       },
//       'theme': {
//         'color':
//             '#${AppColors.getPrimary(isDark).value.toRadixString(16).padLeft(8, '0').substring(2)}',
//       },
//     };

//     _razorpay.open(options);
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Payment Successful!',
//           style: AppTextStyles.bodyMedium(
//             isDark: true,
//           ).copyWith(color: Colors.white),
//         ),
//         backgroundColor: AppColors.getSuccess(ref.watch(themeProvider)),
//       ),
//     );

//     if (response.paymentId != null) {
//       widget.onSuccess(response.paymentId!);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Payment completed, but payment ID is missing.',
//             style: AppTextStyles.bodyMedium(
//               isDark: true,
//             ).copyWith(color: Colors.white),
//           ),
//           backgroundColor: AppColors.getError(ref.watch(themeProvider)),
//         ),
//       );
//     }
//     // pass paymentId
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Payment Failed: ${response.message}',
//           style: AppTextStyles.bodyMedium(
//             isDark: true,
//           ).copyWith(color: Colors.white),
//         ),
//         backgroundColor: AppColors.getError(ref.watch(themeProvider)),
//       ),
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     // Optional: handle external wallet
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = ThemeUtils.isDark(context);
//     return ElevatedButton(
//       onPressed: widget.amount > 0 ? _openCheckout : null, // disable if free
//       style: ElevatedButton.styleFrom(
//         backgroundColor: widget.amount > 0
//             ? AppColors.getPrimary(isDark)
//             : Colors.grey, // grey out if disabled
//         padding: EdgeInsets.symmetric(
//           horizontal: AppSizes.buttonPaddingHorizontal,
//           vertical: AppSizes.buttonPaddingVertical,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
//         ),
//       ),
//       child: Text(
//         widget.amount > 0
//             ? 'Pay ₹${widget.amount.toStringAsFixed(2)}'
//             : 'Free Event', // show Free Event if amount is 0
//         style: AppTextStyles.button(
//           isDark: isDark,
//         ).copyWith(color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

class RazorpayPaymentWidget extends StatefulWidget {
  final double amount;
  final Function(String paymentId) onSuccess;
  final VoidCallback? onFailure;

  const RazorpayPaymentWidget({
    super.key,
    required this.amount,
    required this.onSuccess,
    this.onFailure,
  });

  @override
  State<RazorpayPaymentWidget> createState() => _RazorpayPaymentWidgetState();
}

class _RazorpayPaymentWidgetState extends State<RazorpayPaymentWidget> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = true);
    print('✓ Razorpay payment success: ${response.paymentId}');
    widget.onSuccess(response.paymentId ?? '');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    print('✗ Razorpay payment error: ${response.code} - ${response.message}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    widget.onFailure?.call();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_RU0yq41o7lOiIN', // Replace with your Razorpay key
      'amount': (widget.amount * 100).toInt(), // Amount in paise
      'name': 'SyncEvent',
      'description': 'Event Ticket Booking',
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#6366F1'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show loading overlay when processing payment
    return Stack(
      children: [
        ElevatedButton(
          onPressed: _isProcessing ? null : _openCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.getPrimary(isDark),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
            disabledBackgroundColor: AppColors.getPrimary(
              isDark,
            ).withOpacity(0.6),
          ),
          child: _isProcessing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: AppSizes.spacingMedium),
                    Text(
                      'Processing Payment...',
                      style: AppTextStyles.button(
                        isDark: false,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : Text(
                  'Pay with Razorpay - ₹${widget.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.button(
                    isDark: false,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
        ),

        // Full-screen loading overlay when processing
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(AppSizes.paddingXl),
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
                        'Processing Payment',
                        style: AppTextStyles.headingMedium(isDark: isDark),
                      ),
                      SizedBox(height: AppSizes.spacingSmall),
                      Text(
                        'Please wait...',
                        style: AppTextStyles.bodyMedium(
                          isDark: isDark,
                        ).copyWith(color: AppColors.getTextSecondary(isDark)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
