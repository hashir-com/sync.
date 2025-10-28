import 'package:equatable/equatable.dart';

class ChatUserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? image;
  final DateTime? createdAt;
  final DateTime? lastSeen;
  final bool isOnline;

  const ChatUserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.image,
    this.createdAt,
    this.lastSeen,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [uid, name, email, image, createdAt, lastSeen, isOnline];
}