import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet(String userId);
  Future<void> updateWallet(WalletModel wallet);
  Future<void> addRefundToWallet(
    String userId,
    double amount,
    String bookingId,
    String? reason,
  );
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final FirebaseFirestore firestore;

  WalletRemoteDataSourceImpl({required this.firestore});

  @override
  Future<WalletModel> getWallet(String userId) async {
    try {
      final doc = await firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        return WalletModel.fromJson(doc.data()!..['userId'] = userId);
      } else {
        final newWallet = WalletModel(
          userId: userId,
          balance: 0.0,
          transactionHistory: [],
        );
        await firestore
            .collection('wallets')
            .doc(userId)
            .set(newWallet.toJson());
        return newWallet;
      }
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    try {
      await firestore
          .collection('wallets')
          .doc(wallet.userId)
          .update(wallet.toJson());
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  @override
  Future<void> addRefundToWallet(
    String userId,
    double amount,
    String bookingId,
    String? reason,
  ) async {
    try {
      print('💰 WalletRemoteDataSource: Adding refund to wallet');
      print('   userId: $userId');
      print('   amount: ₹$amount');
      print('   bookingId: $bookingId');

      final walletRef = firestore.collection('wallets').doc(userId);

      // First, ensure wallet document exists
      print('📝 Checking if wallet exists...');
      final walletSnap = await walletRef.get();
      print('   Wallet exists: ${walletSnap.exists}');

      if (!walletSnap.exists) {
        print('   ⚠️ Wallet does not exist, creating new one...');
        try {
          await walletRef.set({
            'userId': userId,
            'balance': 0.0,
            'transactionHistory': [],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
          print('   ✓ Wallet created successfully');
        } catch (e) {
          print('   ❌ Error creating wallet: $e');
          rethrow;
        }
      } else {
        print('   ✓ Wallet already exists');
      }

      // Now add the refund
      print('💾 Adding refund transaction...');
      final newTransaction = {
        'type': 'refund',
        'amount': amount,
        'bookingId': bookingId,
        'timestamp': DateTime.now().toIso8601String(),
        'description': 'Refund for cancelled booking',
        'reason': reason ?? 'No reason provided',
      };

      try {
        // Get current data first
        final currentSnap = await walletRef.get();
        final currentBalance =
            (currentSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
        final currentTransactions = List<Map<String, dynamic>>.from(
          currentSnap.data()?['transactionHistory'] ?? [],
        );

        print('   Current balance: ₹$currentBalance');
        print('   Current transactions: ${currentTransactions.length}');

        // Calculate new values
        final newBalance = currentBalance + amount;
        final updatedTransactions = [...currentTransactions, newTransaction];

        // Use set with merge instead of update
        await walletRef.set({
          'userId': userId,
          'balance': newBalance,
          'transactionHistory': updatedTransactions,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('   ✓ Wallet updated successfully');
        print('   New balance: ₹$newBalance');
        print('   Total transactions: ${updatedTransactions.length}');
      } catch (e) {
        print('   ❌ Error updating wallet: $e');
        rethrow;
      }

      print('✓ Refund added to wallet successfully: $userId, Amount: ₹$amount');
    } catch (e) {
      print('❌ Error adding refund to wallet: $e');
      throw Exception('Failed to add refund to wallet: $e');
    }
  }
}
