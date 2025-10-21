import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_provider.dart';
import 'dart:math' as math;


class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    Future.microtask(() {
      final userId = ref.read(authStateProvider).value?.uid ?? '';
      if (userId.isNotEmpty) {
        ref.read(walletNotifierProvider.notifier).fetchWallet(userId);
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isFlipped = !_isFlipped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletState = ref.watch(walletNotifierProvider);
    final userState = ref.watch(authStateProvider);
    final userName = userState.value?.displayName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: AppTextStyles.headingMedium(isDark: isDark),
        ),
        backgroundColor: AppColors.getBackground(isDark),
        elevation: 0,
      ),
      body: walletState.when(
        data: (wallet) => _buildWalletUI(context, isDark, wallet, userName),
        loading: () => _buildSkeletonLoader(context, isDark),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context, bool isDark) {
    final skeletonColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final skeletonTextColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Skeleton for Card
            Container(
              height: 220.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: skeletonColor,
              ),
            ),
            SizedBox(height: 32.h),
            // Skeleton for Recent Transactions Header
            Row(
              children: [
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Skeleton for Transactions Container
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: index < 2 ? 12.h : 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.h,
                                decoration: BoxDecoration(
                                  color: skeletonTextColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 12.h,
                                      decoration: BoxDecoration(
                                        color: skeletonTextColor,
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Container(
                                      width: 80.w,
                                      height: 10.h,
                                      decoration: BoxDecoration(
                                        color: skeletonTextColor,
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: skeletonTextColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletUI(
    BuildContext context,
    bool isDark,
    WalletModel wallet,
    String userName,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleFlip,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * math.pi;
                  final isBack = _flipAnimation.value > 0.5;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: isBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildCardBack(
                              wallet.balance.toStringAsFixed(2),
                              isDark,
                            ),
                          )
                        : _buildCardFront(userName, isDark),
                  );
                },
              ),
            ),
            // SizedBox(height: 32.h),
            // _buildQuickActions(isDark),
            SizedBox(height: 32.h),
            _buildRecentTransactions(isDark, wallet.transactionHistory),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(String userName, bool isDark) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E3A8A),
                  const Color(0xFF0F172A),
                  const Color(0xFF1E1B4B),
                ]
              : [
                  const Color(0xFF3B82F6),
                  const Color(0xFF1E40AF),
                  const Color(0xFF7C3AED),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(76)
                : Colors.blue.withAlpha(76),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50.h,
            right: -50.w,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(51),
              ),
            ),
          ),
          Positioned(
            bottom: -40.h,
            left: -40.w,
            child: Container(
              width: 180.w,
              height: 180.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(38),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SyncEvent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(76),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'WALLET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cardholder',
                      style: TextStyle(
                        color: Colors.white.withAlpha(178),
                        fontSize: 12.sp,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12.h,
            right: 20.w,
            child: Text(
              'Tap to reveal balance',
              style: TextStyle(
                color: Colors.white.withAlpha(140),
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(String balance, bool isDark) {
    return Container(
      width: 320.w,
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1B1B1F),
                  const Color(0xFF0F0F13),
                  const Color(0xFF1A1A1E),
                ]
              : [
                  const Color(0xFFF3F4F6),
                  const Color(0xFFE5E7EB),
                  const Color(0xFFF9FAFB),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(76)
                : Colors.grey.withAlpha(76),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50.h,
            left: 0,
            right: 0,
            child: Container(
              height: 40.h,

              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2E)
                    : const Color(0xFF1F2937),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'AVAILABLE BALANCE',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: 36.h),
                Center(
                  child: Text(
                    '₹$balance',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 42.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
                Text(
                  'Tap to return to front',
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildQuickActions(bool isDark) {
  //   return Container(
  //     padding: EdgeInsets.all(20.w),
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
  //       borderRadius: BorderRadius.circular(16.r),
  //       border: Border.all(
  //         color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildActionItem(
  //           isDark: isDark,
  //           icon: Icons.add_circle_outline,
  //           label: 'Add Money',
  //         ),
  //         _buildActionItem(
  //           isDark: isDark,
  //           icon: Icons.send_outlined,
  //           label: 'Send',
  //         ),
  //         _buildActionItem(
  //           isDark: isDark,
  //           icon: Icons.history,
  //           label: 'History',
  //         ),
  //         _buildActionItem(
  //           isDark: isDark,
  //           icon: Icons.more_horiz,
  //           label: 'More',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildActionItem({
  //   required bool isDark,
  //   required IconData icon,
  //   required String label,
  // }) {
  //   return GestureDetector(
  //     onTap: () {},
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(12.w),
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: AppColors.getPrimary(isDark).withAlpha(76),
  //           ),
  //           child: Icon(icon, color: AppColors.getPrimary(isDark), size: 20.sp),
  //         ),
  //         SizedBox(height: 8.h),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: isDark ? Colors.grey[300] : Colors.grey[700],
  //             fontSize: 12.sp,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRecentTransactions(
    bool isDark,
    List<Map<String, dynamic>> transactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: transactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                )
              : Column(
                  children: transactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final transaction = entry.value;
                    final isCredit = transaction['type'] == 'refund';
                    final timestamp = transaction['timestamp'] is String
                        ? DateTime.tryParse(transaction['timestamp'])
                        : (transaction['timestamp'] as Timestamp?)?.toDate();
                    return Column(
                      children: [
                        _buildTransactionItem(
                          isDark: isDark,
                          title: transaction['description'] ?? 'Transaction',
                          subtitle: timestamp != null
                              ? _formatTimestamp(timestamp)
                              : 'Unknown time',
                          amount: isCredit
                              ? '+ ₹${transaction['amount'].toStringAsFixed(2)}'
                              : '- ₹${transaction['amount'].toStringAsFixed(2)}',
                          icon: isCredit ? Icons.add_circle : Icons.event,
                          isCredit: isCredit,
                          reason: transaction['reason'] ?? 'No reason provided',
                        ),
                        if (index < transactions.length - 1) ...[
                          SizedBox(height: 12.h),
                          Divider(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required bool isDark,
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    bool isCredit = false,
    required String reason,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCredit
                      ? Colors.green.withAlpha(76)
                      : Colors.red.withAlpha(76),
                ),
                child: Icon(
                  icon,
                  size: 16.sp,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Reason: $reason',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.red,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final time =
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    if (date == today) {
      return 'Today at $time';
    } else if (date == DateTime(now.year, now.month, now.day - 1)) {
      return 'Yesterday at $time';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} at $time';
    }
  }
}
