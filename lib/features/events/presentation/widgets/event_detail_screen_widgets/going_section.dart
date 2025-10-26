// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';

// import 'package:sync_event/core/constants/app_colors.dart';
// import 'package:sync_event/core/constants/app_sizes.dart';
// import 'package:sync_event/core/constants/app_text_styles.dart';

// // Widget for the "Going" avatars and Invite button
// class GoingSection extends StatelessWidget {
//   final bool isDark;

//   const GoingSection({super.key, required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     // Build going section with avatars and button
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Avatar stack and "Going" text
//         Row(
//           children: [
//             SizedBox(
//               width: 75,
//               height: 40,
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   _buildAvatar(0, 'assets/images/avatar1.jpg'),
//                   _buildAvatar(20, 'assets/images/avatar2.jpg'),
//                   _buildCountBadge(40),
//                 ],
//               ),
//             ),
//             SizedBox(width: AppSizes.spacingSmall),
//             Text(
//               'Going',
//               style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.getTextPrimary(isDark),
//               ),
//             ),
//           ],
//         ),
//         // Invite button
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           decoration: BoxDecoration(
//             color: AppColors.getPrimary(isDark),
//             borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.getShadow(isDark).withOpacity(0.2),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Text(
//             'Invite',
//             style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper for avatar images
//   Widget _buildAvatar(double left, String asset) => Positioned(
//         left: left,
//         child: Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: AppColors.getCard(isDark), width: 2),
//             image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
//           ),
//         ),
//       );

//   // Helper for attendee count badge
//   Widget _buildCountBadge(double left) => Positioned(
//         left: left,
//         child: Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: AppColors.getPrimary(isDark),
//             border: Border.all(color: AppColors.getCard(isDark), width: 2),
//           ),
//           child: Center(
//             child: Text(
//               '+20',
//               style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       );
// }