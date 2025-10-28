import 'package:sync_event/features/chat/domain/entities/message_entity.dart';
import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call({
    required String chatId,
    required String text,
    String? imageUrl,
    MessageType messageType = MessageType.text,
  }) {
    return repository.sendMessage(
      chatId: chatId,
      text: text,
      imageUrl: imageUrl,
      messageType: messageType,
    );
  }
}