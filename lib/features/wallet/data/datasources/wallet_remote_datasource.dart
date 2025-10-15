import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/wallet/data/models/wallet_model.dart';
import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRemoteDataSource {
  Future<WalletEntity> getWallet(String userId);
  Future<void> updateWallet(WalletModel wallet); // Updated to WalletModel
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final FirebaseFirestore firestore;

  WalletRemoteDataSourceImpl({required this.firestore});

  @override
  Future<WalletEntity> getWallet(String userId) async {
    final doc = await firestore.collection('wallets').doc(userId).get();
    if (doc.exists) {
      return WalletModel.fromJson(doc.data()!); // Return as WalletEntity
    }
    // Create a new wallet with zero balance if not found
    await firestore.collection('wallets').doc(userId).set({'balance': 0.0});
    return WalletModel(userId: userId, balance: 0.0);
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    await firestore.collection('wallets').doc(wallet.userId).set(
      wallet.toJson(),
      SetOptions(merge: true),
    );
  }
}