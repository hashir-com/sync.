import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/chat/domain/entities/chat_user_entity.dart';

class ChatUserModel extends ChatUserEntity {
  const ChatUserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.image,
    super.createdAt,
    super.lastSeen,
    super.isOnline,
  });

  factory ChatUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatUserModel(
      uid: data['uid'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      image: data['image'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      isOnline: data['isOnline'] ?? false,
    );
  }

  factory ChatUserModel.fromEntity(ChatUserEntity entity) {
    return ChatUserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      image: entity.image,
      createdAt: entity.createdAt,
      lastSeen: entity.lastSeen,
      isOnline: entity.isOnline,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'image': image,

    'nameLower': name.toLowerCase(), 
    'emailLower': email.toLowerCase(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isOnline': isOnline,
    };
  }

  Map<String, dynamic> toParticipantDetails() {
    return {
      'name': name,
      'image': image,
      'email': email,
    };
  }
}