import 'package:sync_event/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sync_event/features/chat/domain/entities/chat_entity.dart';
import 'package:sync_event/features/chat/domain/entities/chat_user_entity.dart';
import 'package:sync_event/features/chat/domain/entities/message_entity.dart';
import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  String get currentUserId => remoteDataSource.currentUserId;

  @override
  Future<ChatUserEntity?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<ChatUserEntity?> getUserByUid(String uid) async {
    return await remoteDataSource.getUserByUid(uid);
  }

  @override
  Future<String> createOrGetChat(String otherUserId) async {
    return await remoteDataSource.createOrGetChat(otherUserId);
  }

  @override
  Stream<List<ChatEntity>> getUserChats() {
    return remoteDataSource.getUserChats();
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    MessageType messageType = MessageType.text,
  }) async {
    return await remoteDataSource.sendMessage(
      chatId: chatId,
      text: text,
      imageUrl: imageUrl,
      messageType: messageType,
    );
  }

  @override
  Stream<List<MessageEntity>> getChatMessages(String chatId) {
    return remoteDataSource.getChatMessages(chatId);
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {
    return await remoteDataSource.markMessagesAsRead(chatId);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    return await remoteDataSource.deleteChat(chatId);
  }

  @override
  Future<List<ChatUserEntity>> searchUsers(String query) async {
    return await remoteDataSource.searchUsers(query);
  }

  @override
  Future<void> updateOnlineStatus(bool isOnline) async {
    return await remoteDataSource.updateOnlineStatus(isOnline);
  }
}