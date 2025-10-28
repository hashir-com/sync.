import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sync_event/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:sync_event/features/chat/domain/entities/chat_entity.dart';
import 'package:sync_event/features/chat/domain/entities/message_entity.dart';
import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';
import 'package:sync_event/features/chat/domain/usecases/create_or_get_usecase.dart';
import 'package:sync_event/features/chat/domain/usecases/delete_chat_usecase.dart';
import 'package:sync_event/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:sync_event/features/chat/domain/usecases/get_user_chats_usecase.dart';
import 'package:sync_event/features/chat/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:sync_event/features/chat/domain/usecases/search_users_usecase.dart';
import 'package:sync_event/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:sync_event/features/chat/domain/usecases/update_online_status_usecase.dart';
// Firebase instances
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
return FirebaseFirestore.instance;
});
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
return FirebaseAuth.instance;
});
// Data Source provider
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
return ChatRemoteDataSourceImpl(
firestore: ref.watch(firebaseFirestoreProvider),
auth: ref.watch(firebaseAuthProvider),
);
});
// Repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
return ChatRepositoryImpl(
remoteDataSource: ref.watch(chatRemoteDataSourceProvider),
);
});
// Use Case providers
final getUserChatsUseCaseProvider = Provider<GetUserChatsUseCase>((ref) {
return GetUserChatsUseCase(ref.watch(chatRepositoryProvider));
});
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});
final getChatMessagesUseCaseProvider = Provider<GetChatMessagesUseCase>((ref) {
return GetChatMessagesUseCase(ref.watch(chatRepositoryProvider));
});
final createOrGetChatUseCaseProvider = Provider<CreateOrGetChatUseCase>((ref) {
return CreateOrGetChatUseCase(ref.watch(chatRepositoryProvider));
});
final searchUsersUseCaseProvider = Provider<SearchUsersUseCase>((ref) {
return SearchUsersUseCase(ref.watch(chatRepositoryProvider));
});
final markMessagesAsReadUseCaseProvider = Provider<MarkMessagesAsReadUseCase>((ref) {
return MarkMessagesAsReadUseCase(ref.watch(chatRepositoryProvider));
});
final deleteChatUseCaseProvider = Provider<DeleteChatUseCase>((ref) {
return DeleteChatUseCase(ref.watch(chatRepositoryProvider));
});
final updateOnlineStatusUseCaseProvider = Provider<UpdateOnlineStatusUseCase>((ref) {
return UpdateOnlineStatusUseCase(ref.watch(chatRepositoryProvider));
});
// Stream providers for UI
final userChatsStreamProvider = StreamProvider<List<ChatEntity>>((ref) {
final useCase = ref.watch(getUserChatsUseCaseProvider);
return useCase();
});
final chatMessagesStreamProvider = StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
final useCase = ref.watch(getChatMessagesUseCaseProvider);
return useCase(chatId);
});
// Current user ID provider
final currentUserIdProvider = Provider<String>((ref) {
return ref.watch(chatRepositoryProvider).currentUserId;
});