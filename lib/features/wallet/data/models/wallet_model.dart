import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  final List<Map<String, dynamic>> transactionHistory;

  const WalletModel({
    required String userId,
    required double balance,
    this.transactionHistory = const [],
  }) : super(userId: userId, balance: balance);

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      transactionHistory: List<Map<String, dynamic>>.from(
        json['transactionHistory'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'transactionHistory': transactionHistory,
      'updatedAt': DateTime.now(),
    };
  }

  WalletModel copyWith({
    String? userId,
    double? balance,
    List<Map<String, dynamic>>? transactionHistory,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      transactionHistory: transactionHistory ?? this.transactionHistory,
    );
  }

  static WalletModel fromEntity(WalletEntity entity) {
    return WalletModel(
      userId: entity.userId,
      balance: entity.balance,
    );
  }
}