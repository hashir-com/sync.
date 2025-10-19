import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet(String userId);
  Future<void> updateWallet(WalletModel wallet);
  Future<void> addRefundToWallet(String userId, double amount, String bookingId, String? reason);
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
        await firestore.collection('wallets').doc(userId).set(newWallet.toJson());
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
      final walletRef = firestore.collection('wallets').doc(userId);

      await firestore.runTransaction((transaction) async {
        final walletSnap = await transaction.get(walletRef);

        double currentBalance = 0.0;
        List<Map<String, dynamic>> currentTransactions = [];
        if (walletSnap.exists) {
          currentBalance =
              (walletSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
          currentTransactions = List<Map<String, dynamic>>.from(
              walletSnap.data()?['transactionHistory'] ?? []);
        }

        final newBalance = currentBalance + amount;
        final newTransaction = {
          'type': 'refund',
          'amount': amount,
          'bookingId': bookingId,
          'timestamp': FieldValue.serverTimestamp(),
          'description': 'Refund for cancelled booking',
          'reason': reason ?? 'No reason provided',
        };

        transaction.set(walletRef, {
          'userId': userId,
          'balance': newBalance,
          'transactionHistory': [...currentTransactions, newTransaction],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      print('✓ Refund added to wallet: $userId, Amount: ₹$amount, Reason: $reason');
    } catch (e) {
      throw Exception('Failed to add refund to wallet: $e');
    }
  }
}