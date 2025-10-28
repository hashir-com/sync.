import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> participantDetails;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;

  const ChatEntity({
    required this.id,
    required this.participants,
    required this.participantDetails,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCount,
  });

  Map<String, dynamic>? getOtherUserDetails(String currentUserId) {
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantDetails[otherUserId];
  }

  int getUnreadCount(String currentUserId) {
    return unreadCount[currentUserId] ?? 0;
  }

  @override
  List<Object?> get props => [id, participants, participantDetails, lastMessage, lastMessageTime, lastMessageSenderId, unreadCount];
}