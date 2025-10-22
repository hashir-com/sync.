// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sync_event/core/constants/app_colors.dart';
// import 'package:sync_event/core/constants/app_sizes.dart';
// import 'package:sync_event/core/constants/app_text_styles.dart';
// import 'package:sync_event/core/util/responsive_util.dart';
// import 'package:sync_event/core/util/theme_util.dart';

// // Widget for refund method selection dialog
// class RefundMethodDialog extends StatelessWidget {
//   const RefundMethodDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Build refund method options
//     return SafeArea(
//       child: Padding(
//         padding: ResponsiveUtil.getResponsivePadding(context),
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.account_balance_wallet_outlined),
//               title: const Text('Refund to Wallet'),
//               onTap: () => Navigator.pop(context, 'wallet'),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_balance_outlined),
//               title: const Text('Refund to Bank'),
//               onTap: () => Navigator.pop(context, 'bank'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Widget for cancellation reason prompt dialog
// class CancellationReasonDialog extends StatefulWidget {
//   const CancellationReasonDialog({super.key});

//   @override
//   State<CancellationReasonDialog> createState() => _CancellationReasonDialogState();
// }

// class _CancellationReasonDialogState extends State<CancellationReasonDialog> {
//   String? selectedReason;
//   final otherReasonController = TextEditingController();

//   @override
//   void dispose() {
//     otherReasonController.dispose();
//     super.dispose();
//   }

//   // Build reason selection dialog
//   @override
//   Widget build(BuildContext context) {
//     final isDark = ThemeUtils.isDark(context);
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.all(AppSizes.paddingMedium.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Select Cancellation Reason', style: AppTextStyles.headingSmall(isDark: isDark)),
//             SizedBox(height: AppSizes.spacingMedium.h),
//             _buildRadioTile('Ordered by mistake'),
//             _buildRadioTile('Can\'t attend the event'),
//             _buildRadioTile('Event rescheduled'),
//             _buildRadioTile('Found a better alternative'),
//             _buildRadioTile('Other'),
//             if (selectedReason == 'Other')
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
//                 child: TextField(
//                   controller: otherReasonController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter reason',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r)),
//                   ),
//                   maxLines: 2,
//                 ),
//               ),
//             SizedBox(height: AppSizes.spacingLarge.h),
//             // Action buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Cancel', style: AppTextStyles.bodyMedium(isDark: isDark)),
//                 ),
//                 SizedBox(width: AppSizes.spacingMedium.w),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (selectedReason == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Please select a reason.'), backgroundColor: AppColors.getError(isDark)),
//                       );
//                       return;
//                     }
//                     if (selectedReason == 'Other' && otherReasonController.text.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Please enter a reason.'), backgroundColor: AppColors.getError(isDark)),
//                       );
//                       return;
//                     }
//                     Navigator.pop(context, selectedReason == 'Other' ? otherReasonController.text : selectedReason);
//                   },
//                   style: Theme.of(context).elevatedButtonTheme.style,
//                   child: Text('Submit', style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(color: Colors.white)),
//                 ),
//               ],
//             ),
//             SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper for radio list tiles
//   Widget _buildRadioTile(String value) => ListTile(
//         title: Text(value),
//         leading: Radio<String>(
//           value: value,
//           groupValue: selectedReason,
//           onChanged: (val) => setState(() => selectedReason = val),
//         ),
//       );
// }