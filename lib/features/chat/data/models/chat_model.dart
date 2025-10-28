import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/chat/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participants,
    required super.participantDetails,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.lastMessageSenderId,
    required super.unreadCount,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantDetails: data['participantDetails'] ?? {},
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      participants: entity.participants,
      participantDetails: entity.participantDetails,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      lastMessageSenderId: entity.lastMessageSenderId,
      unreadCount: entity.unreadCount,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantDetails': participantDetails,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
    };
  }
}