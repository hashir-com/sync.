import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
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
          final horizontalPadding = constraints.maxWidth < 600 ? 20.w : 40.w;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20.h,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    const LoginForm(),
                    SizedBox(height: AppSizes.spacingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.splashText,
                            thickness: AppSizes.dividerThickness,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              fontSize: AppSizes.fontMedium,
                              color: AppColors.splashText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.splashText,
                            thickness: AppSizes.dividerThickness,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SocialButtons(),
                    const Spacer(flex: 1),
                    SizedBox(height: AppSizes.spacingLarge),
                    const Center(child: SignupText()),
                    SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


