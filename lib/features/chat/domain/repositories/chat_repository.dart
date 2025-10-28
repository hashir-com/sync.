import 'package:sync_event/features/chat/domain/entities/chat_entity.dart';
import 'package:sync_event/features/chat/domain/entities/chat_user_entity.dart';
import 'package:sync_event/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  String get currentUserId;
  
  Future<ChatUserEntity?> getCurrentUser();
  Future<ChatUserEntity?> getUserByUid(String uid);
  Future<String> createOrGetChat(String otherUserId);
  Stream<List<ChatEntity>> getUserChats();
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    MessageType messageType = MessageType.text,
  });
  Stream<List<MessageEntity>> getChatMessages(String chatId);
  Future<void> markMessagesAsRead(String chatId);
  Future<void> deleteChat(String chatId);
  Future<List<ChatUserEntity>> searchUsers(String query);
  Future<void> updateOnlineStatus(bool isOnline);
}