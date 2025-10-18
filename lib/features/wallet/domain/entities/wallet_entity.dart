import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String userId;
  final double balance;

  const WalletEntity({
    required this.userId,
    required this.balance,
  });

  @override
  List<Object?> get props => [userId, balance];
}