// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:sync_event/core/constants/app_colors.dart';
// import 'package:sync_event/core/constants/app_sizes.dart';
// import 'package:sync_event/core/constants/app_text_styles.dart';
// import 'package:sync_event/core/error/failures.dart';
// import 'package:sync_event/core/util/theme_util.dart';
// import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
// import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
// import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
// import 'package:sync_event/features/bookings/presentation/widgets/razorpay_payment_widget.dart';
// import 'package:sync_event/features/events/domain/entities/event_entity.dart';
// import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
// import 'package:sync_event/features/email/services/email_services.dart';

// final bookingFormProvider =
//     StateNotifierProvider.autoDispose<BookingFormNotifier, BookingFormState>(
//       (ref) => BookingFormNotifier(),
//     );

// class BookingFormState {
//   final String selectedCategory;
//   final int quantity;

//   BookingFormState({required this.selectedCategory, this.quantity = 1});

//   BookingFormState copyWith({String? selectedCategory, int? quantity}) {
//     return BookingFormState(
//       selectedCategory: selectedCategory ?? this.selectedCategory,
//       quantity: quantity ?? this.quantity,
//     );
//   }
// }

// class BookingFormNotifier extends StateNotifier<BookingFormState> {
//   BookingFormNotifier() : super(BookingFormState(selectedCategory: ''));

//   void setCategory(String category) {
//     state = state.copyWith(selectedCategory: category, quantity: 1);
//   }

//   void setQuantity(int quantity) {
//     state = state.copyWith(quantity: quantity);
//   }
// }

// class BookingScreen extends ConsumerStatefulWidget {
//   final String eventId;

//   const BookingScreen({super.key, required this.eventId});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _BookingScreenState();
// }

// class _BookingScreenState extends ConsumerState<BookingScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
//         );

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = ThemeUtils.isDark(context);
//     final eventAsync = ref.watch(approvedEventsStreamProvider);
//     final bookingState = ref.watch(bookingNotifierProvider);

//     return Scaffold(
//       backgroundColor: AppColors.getBackground(isDark),
//       appBar: AppBar(
//         title: Text(
//           'Book Tickets',
//           style: AppTextStyles.headingMedium(
//             isDark: isDark,
//           ).copyWith(fontWeight: FontWeight.w700),
//         ),
//         backgroundColor: AppColors.getBackground(isDark),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_rounded,
//             color: AppColors.getPrimary(isDark),
//           ),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: eventAsync.when(
//         data: (events) {
//           EventEntity? event;
//           try {
//             event = events.firstWhere((event) => event.id == widget.eventId);
//           } catch (e) {
//             return _buildErrorUI(context, isDark, 'Event not found');
//           }

//           return _buildBookingContent(
//             context,
//             ref,
//             event,
//             isDark,
//             bookingState,
//           );
//         },
//         loading: () => _buildLoadingShimmer(isDark),
//         error: (error, stack) =>
//             _buildErrorUI(context, isDark, 'Error loading event', error),
//       ),
//     );
//   }

//   Widget _buildLoadingShimmer(bool isDark) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
//         child: Column(
//           children: [
//             SizedBox(height: AppSizes.spacingMedium.h),
//             _buildShimmerCard(isDark, height: 150.h),
//             SizedBox(height: AppSizes.spacingXxl.h),
//             _buildShimmerCard(isDark, height: 200.h),
//             SizedBox(height: AppSizes.spacingXxl.h),
//             _buildShimmerCard(isDark, height: 180.h),
//             SizedBox(height: AppSizes.spacingXxl.h),
//             _buildShimmerCard(isDark, height: 220.h),
//             SizedBox(height: AppSizes.spacingXxl.h),
//             _buildShimmerCard(isDark, height: 140.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerCard(bool isDark, {required double height}) {
//     return Shimmer.fromColors(
//       baseColor: AppColors.getSurface(isDark),
//       highlightColor: AppColors.getBorder(isDark).withOpacity(0.5),
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           color: AppColors.getSurface(isDark),
//           borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorUI(
//     BuildContext context,
//     bool isDark,
//     String message, [
//     dynamic error,
//   ]) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_rounded,
//             size: AppSizes.iconXxl * 2,
//             color: AppColors.getError(isDark),
//           ),
//           SizedBox(height: AppSizes.spacingLarge.h),
//           Text(message, style: AppTextStyles.headingSmall(isDark: isDark)),
//           if (error != null)
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium.h),
//               child: Text(
//                 error is Failure ? error.message : error.toString(),
//                 style: AppTextStyles.bodyMedium(isDark: isDark),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ElevatedButton(
//             onPressed: () => context.pop(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.getPrimary(isDark),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
//               ),
//             ),
//             child: Text(
//               'Go Back',
//               style: AppTextStyles.labelMedium(
//                 isDark: isDark,
//               ).copyWith(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBookingContent(
//     BuildContext context,
//     WidgetRef ref,
//     EventEntity event,
//     bool isDark,
//     AsyncValue<BookingEntity?> bookingState,
//   ) {
//     final formState = ref.watch(bookingFormProvider);
//     final formNotifier = ref.read(bookingFormProvider.notifier);
//     final authState = ref.watch(authNotifierProvider);
//     final userId = authState.user?.uid ?? '';
//     final userEmail = authState.user?.email ?? '';
//     final isOrganizer = userId == event.organizerId;

//     final validCategories = event.categoryPrices.entries
//         .where(
//           (entry) =>
//               entry.value > 0 && event.categoryCapacities[entry.key]! > 0,
//         )
//         .map((entry) => entry.key)
//         .toList();

//     if (validCategories.isEmpty) {
//       return _buildErrorUI(context, isDark, 'No ticket categories available');
//     }

//     if (!validCategories.contains(formState.selectedCategory)) {
//       Future.microtask(() => formNotifier.setCategory(validCategories.first));
//     }

//     final selectedCategory =
//         validCategories.contains(formState.selectedCategory)
//         ? formState.selectedCategory
//         : validCategories.first;
//     final totalAmount =
//         event.categoryPrices[selectedCategory]! * formState.quantity;

//     return SlideTransition(
//       position: _slideAnimation,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: AppSizes.spacingMedium.h),
//                 _buildEventHeaderCard(event, isDark, isOrganizer),
//                 SizedBox(height: AppSizes.spacingXxl.h),
//                 _buildEventImageCard(event, isDark),
//                 SizedBox(height: AppSizes.spacingXxl.h),
//                 _buildEventDetailsCard(event, isDark),
//                 SizedBox(height: AppSizes.spacingXxl.h),
//                 _buildTicketSelectionCard(
//                   event,
//                   isDark,
//                   validCategories,
//                   selectedCategory,
//                   formState,
//                   formNotifier,
//                 ),
//                 SizedBox(height: AppSizes.spacingXxl.h),
//                 _buildPriceSummaryCard(
//                   isDark,
//                   selectedCategory,
//                   event,
//                   formState,
//                   totalAmount,
//                 ),
//                 SizedBox(height: AppSizes.spacingXxl.h),
//                 _buildPaymentSection(
//                   context,
//                   ref,
//                   event,
//                   isDark,
//                   userId,
//                   userEmail,
//                   selectedCategory,
//                   formState,
//                   totalAmount,
//                   bookingState,
//                 ),
//                 SizedBox(height: AppSizes.paddingXl.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEventHeaderCard(
//     EventEntity event,
//     bool isDark,
//     bool isOrganizer,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.paddingLarge.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.getPrimary(isDark),
//             AppColors.getPrimary(isDark).withOpacity(0.7),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.getPrimary(isDark).withOpacity(0.25),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             event.title,
//             style: AppTextStyles.headingMedium(isDark: isDark).copyWith(
//               fontSize: AppSizes.fontDisplay2.sp,
//               color: Colors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           SizedBox(height: AppSizes.spacingMedium.h),
//           Row(
//             children: [
//               Icon(
//                 Icons.person_rounded,
//                 color: Colors.white.withOpacity(0.8),
//                 size: AppSizes.iconMedium.sp,
//               ),
//               SizedBox(width: AppSizes.spacingSmall.w),
//               Expanded(
//                 child: Text(
//                   'Organized by ${event.organizerName}',
//                   style: AppTextStyles.bodyMedium(
//                     isDark: isDark,
//                   ).copyWith(color: Colors.white.withOpacity(0.9)),
//                 ),
//               ),
//             ],
//           ),
//           if (isOrganizer)
//             Padding(
//               padding: EdgeInsets.only(top: AppSizes.spacingMedium.h),
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: AppSizes.paddingMedium.w,
//                   vertical: AppSizes.paddingSmall.h,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
//                 ),
//                 child: Text(
//                   'You are the organizer',
//                   style: AppTextStyles.labelSmall(
//                     isDark: isDark,
//                   ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEventImageCard(EventEntity event, bool isDark) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
//       child: event.imageUrl != null
//           ? Image.network(
//               event.imageUrl!,
//               height: 200.h,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Shimmer.fromColors(
//                   baseColor: AppColors.getSurface(isDark),
//                   highlightColor: AppColors.getBorder(isDark).withOpacity(0.5),
//                   child: Container(
//                     height: 200.h,
//                     width: double.infinity,
//                     color: AppColors.getSurface(isDark),
//                   ),
//                 );
//               },
//               errorBuilder: (context, error, stackTrace) => Container(
//                 height: 200.h,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppColors.getPrimary(isDark),
//                       AppColors.getPrimary(isDark).withOpacity(0.6),
//                     ],
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.event,
//                   size: AppSizes.iconXxl,
//                   color: Colors.white.withOpacity(0.6),
//                 ),
//               ),
//             )
//           : Container(
//               height: 200.h,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.getPrimary(isDark),
//                     AppColors.getPrimary(isDark).withOpacity(0.6),
//                   ],
//                 ),
//               ),
//               child: Icon(
//                 Icons.event,
//                 size: AppSizes.iconXxl,
//                 color: Colors.white.withOpacity(0.6),
//               ),
//             ),
//     );
//   }

//   Widget _buildEventDetailsCard(EventEntity event, bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.paddingLarge.w),
//       decoration: BoxDecoration(
//         color: AppColors.getSurface(isDark),
//         borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
//         border: Border.all(
//           color: AppColors.getPrimary(isDark).withOpacity(0.15),
//           width: 1.w,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.getPrimary(isDark).withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Event Details',
//             style: AppTextStyles.headingSmall(
//               isDark: isDark,
//             ).copyWith(fontWeight: FontWeight.w700),
//           ),
//           SizedBox(height: AppSizes.spacingLarge.h),
//           _buildDetailRow(
//             icon: Icons.calendar_today_rounded,
//             label: 'Date',
//             value: DateFormat('EEEE, MMMM d, y').format(event.startTime),
//             isDark: isDark,
//           ),
//           SizedBox(height: AppSizes.spacingMedium.h),
//           _buildDetailRow(
//             icon: Icons.access_time_rounded,
//             label: 'Time',
//             value:
//                 '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
//             isDark: isDark,
//           ),
//           SizedBox(height: AppSizes.spacingMedium.h),
//           _buildDetailRow(
//             icon: Icons.location_on_rounded,
//             label: 'Location',
//             value: event.location,
//             isDark: isDark,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTicketSelectionCard(
//     EventEntity event,
//     bool isDark,
//     List<String> validCategories,
//     String selectedCategory,
//     BookingFormState formState,
//     BookingFormNotifier formNotifier,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.paddingLarge.w),
//       decoration: BoxDecoration(
//         color: AppColors.getSurface(isDark),
//         borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
//         border: Border.all(
//           color: AppColors.getPrimary(isDark).withOpacity(0.15),
//           width: 1.w,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.getPrimary(isDark).withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Select Tickets',
//             style: AppTextStyles.headingSmall(
//               isDark: isDark,
//             ).copyWith(fontWeight: FontWeight.w700),
//           ),
//           SizedBox(height: AppSizes.spacingLarge.h),
//           DropdownButtonFormField<String>(
//             value: selectedCategory,
//             decoration: InputDecoration(
//               labelText: 'Ticket Type',
//               labelStyle: AppTextStyles.bodyMedium(isDark: isDark),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
//                 borderSide: BorderSide(
//                   color: AppColors.getPrimary(isDark).withOpacity(0.3),
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
//                 borderSide: BorderSide(
//                   color: AppColors.getPrimary(isDark).withOpacity(0.3),
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
//                 borderSide: BorderSide(
//                   color: AppColors.getPrimary(isDark),
//                   width: 2.w,
//                 ),
//               ),
//               filled: true,
//               fillColor: AppColors.getBackground(isDark),
//               prefixIcon: Icon(
//                 Icons.confirmation_number_rounded,
//                 color: AppColors.getPrimary(isDark),
//               ),
//             ),
//             items: validCategories
//                 .map(
//                   (category) => DropdownMenuItem<String>(
//                     value: category,
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 8.w,
//                           height: 8.w,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: AppColors.getPrimary(isDark),
//                           ),
//                         ),
//                         SizedBox(width: AppSizes.spacingSmall.w),
//                         Text(
//                           '${category.toUpperCase()} - ₹${event.categoryPrices[category]!.toStringAsFixed(0)}',
//                           style: AppTextStyles.bodyMedium(isDark: isDark),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                 .toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 formNotifier.setCategory(value);
//               }
//             },
//           ),
//           SizedBox(height: AppSizes.spacingLarge.h),
//           Container(
//             padding: EdgeInsets.all(AppSizes.paddingMedium.w),
//             decoration: BoxDecoration(
//               color: AppColors.getBackground(isDark),
//               borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
//               border: Border.all(
//                 color: AppColors.getPrimary(isDark).withOpacity(0.15),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.person_add_alt_1_rounded,
//                       color: AppColors.getPrimary(isDark),
//                       size: AppSizes.iconMedium.sp,
//                     ),
//                     SizedBox(width: AppSizes.spacingMedium.w),
//                     Text(
//                       'Quantity',
//                       style: AppTextStyles.bodyMedium(
//                         isDark: isDark,
//                       ).copyWith(fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.getPrimary(isDark).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(
//                           AppSizes.radiusSmall.r,
//                         ),
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.remove_rounded,
//                           color: AppColors.getPrimary(isDark),
//                         ),
//                         onPressed: formState.quantity > 1
//                             ? () => formNotifier.setQuantity(
//                                 formState.quantity - 1,
//                               )
//                             : null,
//                         iconSize: AppSizes.iconMedium.sp,
//                         constraints: BoxConstraints(
//                           minWidth: 40.w,
//                           minHeight: 40.w,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: AppSizes.spacingSmall.w),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: AppSizes.paddingMedium.w,
//                         vertical: AppSizes.paddingSmall.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.getPrimary(isDark).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(
//                           AppSizes.radiusSmall.r,
//                         ),
//                       ),
//                       child: Text(
//                         '${formState.quantity}',
//                         style: AppTextStyles.bodyLarge(
//                           isDark: isDark,
//                         ).copyWith(fontWeight: FontWeight.w700),
//                       ),
//                     ),
//                     SizedBox(width: AppSizes.spacingSmall.w),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.getPrimary(isDark).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(
//                           AppSizes.radiusSmall.r,
//                         ),
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.add_rounded,
//                           color: AppColors.getPrimary(isDark),
//                         ),
//                         onPressed:
//                             formState.quantity <
//                                 event.categoryCapacities[selectedCategory]!
//                             ? () => formNotifier.setQuantity(
//                                 formState.quantity + 1,
//                               )
//                             : null,
//                         iconSize: AppSizes.iconMedium.sp,
//                         constraints: BoxConstraints(
//                           minWidth: 40.w,
//                           minHeight: 40.w,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceSummaryCard(
//     bool isDark,
//     String selectedCategory,
//     EventEntity event,
//     BookingFormState formState,
//     double totalAmount,
//   ) {
//     final pricePerTicket = event.categoryPrices[selectedCategory]!;

//     return Container(
//       padding: EdgeInsets.all(AppSizes.paddingLarge.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.getPrimary(isDark).withOpacity(0.08),
//             AppColors.getPrimary(isDark).withOpacity(0.04),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
//         border: Border.all(
//           color: AppColors.getPrimary(isDark).withOpacity(0.2),
//           width: 1.w,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Price Summary',
//             style: AppTextStyles.headingSmall(
//               isDark: isDark,
//             ).copyWith(fontWeight: FontWeight.w700),
//           ),
//           SizedBox(height: AppSizes.spacingLarge.h),
//           _buildPriceRow(
//             label: 'Price per ticket',
//             value: '₹${pricePerTicket.toStringAsFixed(0)}',
//             isDark: isDark,
//             isSubtitle: true,
//           ),
//           SizedBox(height: AppSizes.spacingMedium.h),
//           _buildPriceRow(
//             label: 'Quantity',
//             value: '${formState.quantity}x',
//             isDark: isDark,
//             isSubtitle: true,
//           ),
//           SizedBox(height: AppSizes.spacingMedium.h),
//           Divider(
//             color: AppColors.getPrimary(isDark).withOpacity(0.2),
//             thickness: 1.h,
//           ),
//           SizedBox(height: AppSizes.spacingMedium.h),
//           _buildPriceRow(
//             label: 'Total Amount',
//             value: '₹${totalAmount.toStringAsFixed(0)}',
//             isDark: isDark,
//             isTotal: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceRow({
//     required String label,
//     required String value,
//     required bool isDark,
//     bool isSubtitle = false,
//     bool isTotal = false,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: isTotal
//               ? AppTextStyles.bodyLarge(
//                   isDark: isDark,
//                 ).copyWith(fontWeight: FontWeight.w700)
//               : AppTextStyles.bodyMedium(
//                   isDark: isDark,
//                 ).copyWith(color: AppColors.getTextSecondary(isDark)),
//         ),
//         Text(
//           value,
//           style: isTotal
//               ? AppTextStyles.headingSmall(isDark: isDark).copyWith(
//                   color: AppColors.getPrimary(isDark),
//                   fontWeight: FontWeight.w800,
//                 )
//               : AppTextStyles.bodyMedium(
//                   isDark: isDark,
//                 ).copyWith(fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }

//   Widget _buildPaymentSection(
//     BuildContext context,
//     WidgetRef ref,
//     EventEntity event,
//     bool isDark,
//     String userId,
//     String userEmail,
//     String selectedCategory,
//     BookingFormState formState,
//     double totalAmount,
//     AsyncValue<BookingEntity?> bookingState,
//   ) {
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.getPrimary(isDark).withOpacity(0.25),
//                 blurRadius: 30,
//                 offset: const Offset(0, 12),
//               ),
//             ],
//           ),
//           child: SizedBox(
//             width: double.infinity,
//             height: AppSizes.buttonHeightLarge.h,
//             child: RazorpayPaymentWidget(
//               amount: totalAmount,
//              onSuccess: (paymentId) async {
//   if (userId.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Please log in to book tickets',
//           style: AppTextStyles.bodyMedium(isDark: true)
//               .copyWith(color: Colors.white),
//         ),
//         backgroundColor: AppColors.getError(isDark),
//       ),
//     );
//     return;
//   }

//   final booking = BookingEntity(
//     id: '', // Will be generated in notifier
//     userId: userId,
//     eventId: event.id,
//     ticketType: selectedCategory,
//     ticketQuantity: formState.quantity,
//     totalAmount: totalAmount,
//     paymentId: paymentId,
//     seatNumbers: const [],
//     bookingDate: DateTime.now(),
//     startTime: event.startTime,
//     endTime: event.endTime,
//     status: 'confirmed',
//     userEmail: userEmail,
//   );

//   try {
//     await ref
//         .read(bookingNotifierProvider.notifier)
//         .bookTicket(
//           eventId: event.id,
//           userId: userId,
//           ticketType: selectedCategory,
//           ticketQuantity: formState.quantity,
//           totalAmount: totalAmount,
//           paymentId: paymentId,
//           startTime: event.startTime,
//           endTime: event.endTime,
//           seatNumbers: const [],
//           userEmail: userEmail,
//         );

//     final bookingStateResult = ref.read(bookingNotifierProvider);
//     bookingStateResult.when(
//       data: (bookingResult) {
//         if (bookingResult != null) {
//           () async {
//             try {
//               await EmailService.sendInvoice(
//                 userId,
//                 bookingResult.id,
//                 totalAmount,
//                 userEmail,
//               );
//             } catch (_) {}
//           }();
//           ref.invalidate(userBookingsProvider(userId));
//           context.go(
//             '/booking-details',
//             extra: {'booking': bookingResult, 'event': event},
//           );
//         }
//       },
//       error: (error, stack) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Booking failed: ${error.toString()}',
//               style: AppTextStyles.bodyMedium(isDark: true)
//                   .copyWith(color: Colors.white),
//             ),
//             backgroundColor: AppColors.getError(isDark),
//           ),
//         );
//       },
//       loading: () {},
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Booking failed: $e',
//           style: AppTextStyles.bodyMedium(isDark: true)
//               .copyWith(color: Colors.white),
//         ),
//         backgroundColor: AppColors.getError(isDark),
//       ),
//     );
//   }
// }
//             ),
//           ),
//         ),
//         SizedBox(height: AppSizes.spacingLarge.h),
//         bookingState.when(
//           data: (booking) => booking != null
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.check_circle_rounded,
//                       color: AppColors.getSuccess(isDark),
//                       size: AppSizes.iconMedium.sp,
//                     ),
//                     SizedBox(width: AppSizes.spacingSmall.w),
//                     Text(
//                       'Processing booking...',
//                       style: AppTextStyles.bodyMedium(
//                         isDark: isDark,
//                       ).copyWith(color: AppColors.getSuccess(isDark)),
//                     ),
//                   ],
//                 )
//               : const SizedBox.shrink(),
//           loading: () => Shimmer.fromColors(
//             baseColor: AppColors.getSurface(isDark),
//             highlightColor: AppColors.getBorder(isDark).withOpacity(0.5),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   width: 20.w,
//                   height: 20.w,
//                   child: const CircularProgressIndicator(strokeWidth: 2),
//                 ),
//                 SizedBox(width: AppSizes.spacingMedium.w),
//                 Container(
//                   width: 150.w,
//                   height: 16.h,
//                   decoration: BoxDecoration(
//                     color: AppColors.getSurface(isDark),
//                     borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           error: (error, stack) => Container(
//             padding: EdgeInsets.all(AppSizes.paddingMedium.w),
//             decoration: BoxDecoration(
//               color: AppColors.getError(isDark).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
//               border: Border.all(
//                 color: AppColors.getError(isDark).withOpacity(0.3),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.error_rounded, color: AppColors.getError(isDark)),
//                 SizedBox(width: AppSizes.spacingMedium.w),
//                 Expanded(
//                   child: Text(
//                     'Error: ${error is Failure ? error.message : error.toString()}',
//                     style: AppTextStyles.bodySmall(
//                       isDark: isDark,
//                     ).copyWith(color: AppColors.getError(isDark)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     required bool isDark,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(AppSizes.paddingSmall.w),
//           decoration: BoxDecoration(
//             color: AppColors.getPrimary(isDark).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
//           ),
//           child: Icon(
//             icon,
//             size: AppSizes.iconMedium.sp,
//             color: AppColors.getPrimary(isDark),
//           ),
//         ),
//         SizedBox(width: AppSizes.spacingMedium.w),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
//                   color: AppColors.getTextSecondary(isDark),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               SizedBox(height: AppSizes.spacingXs.h),
//               Text(
//                 value,
//                 style: AppTextStyles.bodyMedium(
//                   isDark: isDark,
//                 ).copyWith(fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/bookings/presentation/states/booking_screen_state.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_event_detail_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_event_image.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_payment_selection.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_price_summary_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_ticket_selection_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_widget.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String eventId;

  const BookingScreen({super.key, required this.eventId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    final eventAsync = ref.watch(approvedEventsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: _buildAppBar(isDark, context),
      body: eventAsync.when(
        data: (events) => _handleEventData(events, isDark),
        loading: () => const BookingLoadingWidget(),
        error: (error, stack) =>
            BookingErrorWidget(error: error, isDark: isDark),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark, BuildContext context) {
    return AppBar(
      title: Text(
        'Book Tickets',
        style: AppTextStyles.headingMedium(isDark: isDark)
            .copyWith(fontWeight: FontWeight.w700),
      ),
      backgroundColor: AppColors.getBackground(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.getPrimary(isDark),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _handleEventData(List<EventEntity> events, bool isDark) {
    try {
      final event = events.firstWhere((e) => e.id == widget.eventId);
      final bookingState = ref.watch(bookingNotifierProvider);
      return _buildBookingContent(event, isDark, bookingState);
    } catch (e) {
      return BookingErrorWidget(error: 'Event not found', isDark: isDark);
    }
  }

  Widget _buildBookingContent(
    EventEntity event,
    bool isDark,
    AsyncValue<BookingEntity?> bookingState,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.spacingMedium.h),
                BookingEventHeaderCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingEventImageCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingEventDetailsCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingTicketSelectionCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingPriceSummaryCard(event: event, isDark: isDark),
                SizedBox(height: AppSizes.spacingXxl.h),
                BookingPaymentSection(
                  event: event,
                  isDark: isDark,
                  bookingState: bookingState,
                ),
                SizedBox(height: AppSizes.paddingXl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}