import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/responsive_helper.dart';
import 'package:sync_event/features/auth/presentation/widgets/login_form.dart';
import 'package:sync_event/features/auth/presentation/widgets/signup_text.dart';
import 'package:sync_event/features/auth/presentation/widgets/social_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
          final isDesktop = ResponsiveHelper.isDesktop(context);
          
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: ResponsiveHelper.getResponsiveScreenPadding(context),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isDesktop) const Spacer(flex: 1),
                      const LoginForm(),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveHeightSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.splashText,
                              thickness: ResponsiveHelper.getDividerThickness(context),
                            ),
                          ),
                          Padding(
                            padding: ResponsiveHelper.getResponsiveHorizontalPadding(context),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 14,
                                  tablet: 16,
                                  desktop: 16,
                                ),
                                color: AppColors.splashText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.splashText,
                              thickness: ResponsiveHelper.getDividerThickness(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveHeightSpacing(
                          context,
                          mobile: 20,
                          tablet: 24,
                          desktop: 28,
                        ),
                      ),
                      const SocialButtons(),
                      if (isDesktop) const Spacer(flex: 1),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveHeightSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      const Center(child: SignupText()),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveHeightSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


