// lib/features/legal/presentation/screens/contact_us_screen.dart
import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Message sent successfully! We\'ll get back to you soon.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Contact Us',
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
            padding: EdgeInsets.all(
              ResponsiveUtil.getSpacing(context, baseSpacing: 24),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get in Touch',
                    style: AppTextStyles.headingMedium(isDark: isDark),
                  ),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 8),
                  ),
                  Text(
                    'We\'d love to hear from you. Send us a message and we\'ll respond as soon as possible.',
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 24),
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      filled: true,
                      fillColor: AppColors.getSurface(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.getBorder(isDark),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.getPrimary(isDark),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSizes.getInputPaddingHorizontal(context),
                        vertical: AppSizes.getInputPaddingVertical(context),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter your email'
                        : null,
                  ),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 16),
                  ),
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(
                        Icons.subject_outlined,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      filled: true,
                      fillColor: AppColors.getSurface(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.getBorder(isDark),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.getPrimary(isDark),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSizes.getInputPaddingHorizontal(context),
                        vertical: AppSizes.getInputPaddingVertical(context),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter a subject'
                        : null,
                  ),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 16),
                  ),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      prefixIcon: Icon(
                        Icons.message_outlined,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: AppColors.getSurface(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.getBorder(isDark),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtil.getBorderRadius(
                            context,
                            baseRadius: 12,
                          ),
                        ),
                        borderSide: BorderSide(
                          color: AppColors.getPrimary(isDark),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(
                        AppSizes.getInputPaddingHorizontal(context),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter your message'
                        : null,
                  ),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 24),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.getButtonHeight(context),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getPrimary(isDark),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtil.getBorderRadius(
                              context,
                              baseRadius: 12,
                            ),
                          ),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Send Message',
                              style: AppTextStyles.button(
                                isDark: isDark,
                              ).copyWith(color: Colors.white),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 16),
                  ),
                  Divider(color: AppColors.getDivider(isDark)),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 16),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      SizedBox(
                        width: ResponsiveUtil.getSpacing(
                          context,
                          baseSpacing: 8,
                        ),
                      ),
                      Text(
                        'Phone: 1800 007 007',
                        style: AppTextStyles.bodySmall(isDark: isDark),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveUtil.getSpacing(context, baseSpacing: 8),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                      SizedBox(
                        width: ResponsiveUtil.getSpacing(
                          context,
                          baseSpacing: 8,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Email: support@syncevent.com',
                          style: AppTextStyles.bodySmall(isDark: isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
