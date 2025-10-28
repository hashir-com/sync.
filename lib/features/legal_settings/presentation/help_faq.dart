// lib/features/legal/presentation/screens/help_faq_screen.dart
import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Help & FAQ',
          style: AppTextStyles.headingSmall(isDark: isDark),
        ),
        backgroundColor: AppColors.getCard(isDark),
        foregroundColor: AppColors.getTextPrimary(isDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtil.getResponsivePadding(context),
        child: Card(
          elevation: ResponsiveUtil.getElevation(context, baseElevation: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.getBorderRadius(context, baseRadius: 20),
            ),
          ),
          color: AppColors.getCard(isDark),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtil.getSpacing(context, baseSpacing: 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: AppTextStyles.headingMedium(isDark: isDark),
                ),
                SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 16)),
                _buildFaqItem(
                  context,
                  'How do I create an account?',
                  'To create an account, tap the "Sign Up" button on the home screen and follow the on-screen instructions. You can use email, phone, or social login.',
                ),
                _buildFaqItem(
                  context,
                  'What payment methods are accepted?',
                  'We accept major credit cards (Visa, Mastercard), debit cards, and digital wallets like PayPal and Apple Pay.',
                ),
                _buildFaqItem(
                  context,
                  'How can I contact support?',
                  'Reach out to our support team via the "Contact Us" page or email at support@syncevent.com.',
                ),
                _buildFaqItem(
                  context,
                  'Is my data secure?',
                  'Yes, we use industry-standard encryption and comply with GDPR and CCPA for data protection.',
                ),
                SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 24)),
                Text(
                  'Need More Help?',
                  style: AppTextStyles.titleLarge(isDark: isDark),
                ),
                SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 8)),
                Text(
                  'If your question isn\'t answered here, please contact us directly.',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
                SizedBox(height: ResponsiveUtil.getSpacing(context, baseSpacing: 16)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Contact Us
                      // context.go('/contact-us');
                    },
                    icon: const Icon(Icons.contact_support),
                    label: const Text('Contact Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getPrimary(isDark),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.getButtonPaddingVertical(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUtil.getBorderRadius(context, baseRadius: 12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveUtil.getSpacing(context, baseSpacing: 12)),
      elevation: ResponsiveUtil.getElevation(context, baseElevation: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtil.getBorderRadius(context, baseRadius: 12)),
      ),
      color: AppColors.getSurface(isDark),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.titleMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w600),
        ),
        childrenPadding: EdgeInsets.all(ResponsiveUtil.getSpacing(context, baseSpacing: 16)),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
        ],
      ),
    );
  }
}