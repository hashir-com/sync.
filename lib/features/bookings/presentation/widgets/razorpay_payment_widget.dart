import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

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

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _openCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(isDark),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtil.getPadding(context) * 0.75,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtil.getBorderRadius(
                        context,
                        baseRadius: AppSizes.radiusLarge,
                      ),
                    ),
                  ),
                  disabledBackgroundColor: AppColors.getPrimary(
                    isDark,
                  ).withOpacity(0.6),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: ResponsiveUtil.getIconSize(
                              context,
                              baseSize: 20,
                            ),
                            height: ResponsiveUtil.getIconSize(
                              context,
                              baseSize: 20,
                            ),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveUtil.getSpacing(
                              context,
                              baseSpacing: AppSizes.spacingMedium,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Processing Payment...',
                              style: AppTextStyles.button(isDark: false)
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        AppTextStyles.button(
                                          isDark: false,
                                        ).fontSize! *
                                        ResponsiveUtil.getFontSizeMultiplier(
                                          context,
                                        ),
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Pay with Razorpay - ₹${widget.amount.toStringAsFixed(0)}',
                        style: AppTextStyles.button(isDark: false).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize:
                              AppTextStyles.button(isDark: false).fontSize! *
                              ResponsiveUtil.getFontSizeMultiplier(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
          ),

          // Full-screen loading overlay when processing
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtil.getPadding(context) * 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getSurface(isDark),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: AppSizes.radiusLarge,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: ResponsiveUtil.getIconSize(
                              context,
                              baseSize: 40,
                            ),
                            height: ResponsiveUtil.getIconSize(
                              context,
                              baseSize: 40,
                            ),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.getPrimary(isDark),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtil.getSpacing(
                              context,
                              baseSpacing: AppSizes.spacingLarge,
                            ),
                          ),
                          Text(
                            'Processing Payment',
                            style: AppTextStyles.headingMedium(isDark: isDark)
                                .copyWith(
                                  fontSize:
                                      AppTextStyles.headingMedium(
                                        isDark: isDark,
                                      ).fontSize! *
                                      ResponsiveUtil.getFontSizeMultiplier(
                                        context,
                                      ),
                                ),
                          ),
                          SizedBox(
                            height: ResponsiveUtil.getSpacing(
                              context,
                              baseSpacing: AppSizes.spacingSmall,
                            ),
                          ),
                          Text(
                            'Please wait...',
                            style: AppTextStyles.bodyMedium(isDark: isDark)
                                .copyWith(
                                  color: AppColors.getTextSecondary(isDark),
                                  fontSize:
                                      AppTextStyles.bodyMedium(
                                        isDark: isDark,
                                      ).fontSize! *
                                      ResponsiveUtil.getFontSizeMultiplier(
                                        context,
                                      ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
