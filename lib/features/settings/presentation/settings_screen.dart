// lib/features/settings/presentation/pages/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Title ---
                Text(
                  'Settings',
                  style: AppTextStyles.headingLarge(isDark: isDark).copyWith(
                    fontSize: AppSizes.fontDisplay3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSizes.spacingXxxl),

                // --- Account Section ---
                _buildSectionTitle('Account', isDark),
                SizedBox(height: AppSizes.spacingMedium),

                _buildSettingItem(
                  context,
                  isDark,
                  Icons.person_outline_rounded,
                  'My Profile',
                  '/profile',
                ),
                SizedBox(height: AppSizes.spacingSmall),

                _buildSettingItem(
                  context,
                  isDark,
                  Icons.confirmation_number,
                  'My Tickets',
                  '/mybookings',
                ),
                SizedBox(height: AppSizes.spacingSmall),

                _buildSettingItem(
                  context,
                  isDark,
                  Icons.wallet,
                  'My Wallet',
                  '/wallet',
                ),
                SizedBox(height: AppSizes.spacingXxxl),

                // --- Content Section ---
                _buildSectionTitle('Content', isDark),
                SizedBox(height: AppSizes.spacingMedium),

                _buildSettingItem(
                  context,
                  isDark,
                  Icons.event_note_outlined,
                  'My Events',
                  '/my-events',
                ),
                SizedBox(height: AppSizes.spacingSmall),

                _buildSettingItem(
                  context,
                  isDark,
                  Icons.favorite_border_rounded,
                  'Favorites',
                  '/bookings/:bookingId/cancel',
                ),
                SizedBox(height: AppSizes.spacingXxxl),

                // --- Support Section ---
                _buildSectionTitle('Support', isDark),
                SizedBox(height: AppSizes.spacingMedium),

                _buildSettingItem(
                  context,
                  isDark,
                  Icons.help_outline,
                  'Helps & FAQs',
                  '/help',
                ),
                SizedBox(height: AppSizes.spacingSmall),

                _buildSettingItem(
                  context,
                  isDark,
                  Icons.mail_outline_rounded,
                  'Contact Us',
                  '/contact',
                ),
                SizedBox(height: AppSizes.spacingXxxl),

                // --- Appearance Section ---
                _buildSectionTitle('Appearance', isDark),
                SizedBox(height: AppSizes.spacingMedium),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.getCard(isDark),
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusMedium,
                    ),
                    border: Border.all(
                      color: AppColors.getBorder(isDark),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.brightness_6_outlined,
                            color: AppColors.getTextPrimary(isDark),
                            size: AppSizes.iconMedium,
                          ),
                          SizedBox(width: AppSizes.spacingMedium),
                          Text(
                            'Dark Theme',
                            style: AppTextStyles.bodyLarge(isDark: isDark)
                                .copyWith(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final themeIsDark = ref.watch(themeProvider);

                          return GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              await ref
                                  .read(themeProvider.notifier)
                                  .toggleTheme(!themeIsDark);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 60,
                              height: AppSizes.chipHeight,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingXs,
                              ),
                              decoration: BoxDecoration(
                                color: themeIsDark
                                    ? AppColors.getPrimary(isDark)
                                    : AppColors.getDisabled(isDark),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusXl,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedAlign(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    alignment: themeIsDark
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: AppSizes.iconMedium,
                                      height: AppSizes.iconMedium,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.getShadow(isDark),
                                            blurRadius:
                                                AppSizes.cardElevationLow,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            ),
                                        child: Icon(
                                          themeIsDark
                                              ? Icons.dark_mode_rounded
                                              : Icons.light_mode_rounded,
                                          key: ValueKey<bool>(themeIsDark),
                                          size: AppSizes.iconSmall,
                                          color: themeIsDark
                                              ? AppColors.getPrimary(isDark)
                                              : Colors.orangeAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.spacingXxxl),

                // --- Sign Out Section ---
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightLarge,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getError(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.getCard(isDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusXl,
                            ),
                          ),
                          title: Text(
                            'Sign Out?',
                            style: AppTextStyles.headingSmall(
                              isDark: isDark,
                            ).copyWith(fontSize: AppSizes.fontXl),
                          ),
                          content: Text(
                            'Are you sure you want to sign out?',
                            style: AppTextStyles.bodyMedium(
                              isDark: isDark,
                            ).copyWith(fontSize: AppSizes.fontMedium),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.labelLarge(isDark: isDark)
                                    .copyWith(
                                      fontSize: AppSizes.fontMedium,
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.getError(isDark),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSmall,
                                  ),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Sign Out',
                                style: AppTextStyles.labelLarge(isDark: false)
                                    .copyWith(
                                      fontSize: AppSizes.fontMedium,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true && context.mounted) {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) context.go('/login');
                      }
                    },
                    child: Text(
                      'Sign Out',
                      style: AppTextStyles.labelLarge(isDark: false).copyWith(
                        fontSize: AppSizes.fontMedium,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSizes.spacingXxxl),

                // --- Version Info ---
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: AppTextStyles.bodySmall(
                      isDark: isDark,
                    ).copyWith(color: AppColors.getTextSecondary(isDark)),
                  ),
                ),

                SizedBox(height: AppSizes.spacingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
        color: AppColors.getTextSecondary(isDark),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    String route,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.getBorder(isDark), width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        leading: Icon(
          icon,
          color: AppColors.getTextPrimary(isDark),
          size: AppSizes.iconMedium,
        ),
        title: Text(
          label,
          style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: AppSizes.iconSmall,
          color: AppColors.getTextSecondary(isDark),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(route);
        },
      ),
    );
  }
}
