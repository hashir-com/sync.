import 'package:equatable/equatable.dart';

enum MessageType { text, image, file }

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final MessageType messageType;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.messageType = MessageType.text,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, text, imageUrl, timestamp, isRead, messageType];
}