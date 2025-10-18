import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required String userId,
    required double balance,
  }) : super(
          userId: userId,
          balance: balance,
        );

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'],
      balance: (json['balance'] as num).toDouble(), // Already double, no cast needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'lastUpdated': FieldValue.serverTimestamp(), // Optional: Add timestamp for tracking
    };
  }

  static WalletModel fromEntity(WalletEntity entity) {
    return WalletModel(
      userId: entity.userId,
      balance: entity.balance,
    );
  }
}