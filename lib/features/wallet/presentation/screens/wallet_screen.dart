import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_provider.dart';

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
      duration: const Duration(
        milliseconds: 600,
      ), // Slightly longer for smoother animation
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: walletState.when(
        data: (wallet) =>
            _buildWalletUI(context, isDark, wallet, userName),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleFlip,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle =
                      _flipAnimation.value * 3.14159; // Rotation in radians
                  final isBack = _flipAnimation.value > 0.5;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective effect
                      ..rotateY(angle),
                    child: isBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateY(-angle), // Counter-rotate
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
            const SizedBox(height: 32),
            _buildQuickActions(isDark),
            const SizedBox(height: 32),
            _buildRecentTransactions(isDark, wallet.transactionHistory),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(String userName, bool isDark) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(51),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(38),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(76),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'WALLET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
            bottom: 12,
            right: 20,
            child: Text(
              'Tap to reveal balance',
              style: TextStyle(
                color: Colors.white.withAlpha(140),
                fontSize: 11,
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
      height: 220,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2E)
                    : const Color(0xFF1F2937),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'AVAILABLE BALANCE',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  '₹$balance',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tap to return to front',
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                    fontSize: 11,
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

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            isDark: isDark,
            icon: Icons.add_circle_outline,
            label: 'Add Money',
          ),
          _buildActionItem(
            isDark: isDark,
            icon: Icons.send_outlined,
            label: 'Send',
          ),
          _buildActionItem(
            isDark: isDark,
            icon: Icons.history,
            label: 'History',
          ),
          _buildActionItem(
            isDark: isDark,
            icon: Icons.more_horiz,
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required bool isDark,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.getPrimary(isDark).withAlpha(76),
            ),
            child: Icon(icon, color: AppColors.getPrimary(isDark), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
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
                      fontSize: 14,
                    ),
                  ),
                )
              : Column(
                  children: transactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final transaction = entry.value;
                    final isCredit = transaction['type'] == 'refund';
                    final timestamp = (transaction['timestamp'] as Timestamp?)
                        ?.toDate();
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
                        ),
                        if (index < transactions.length - 1) ...[
                          const SizedBox(height: 12),
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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCredit
                    ? Colors.green.withAlpha(76)
                    : Colors.red.withAlpha(76),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.red,
            fontSize: 14,
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
