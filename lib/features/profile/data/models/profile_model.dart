import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.image,
    super.bio,
    super.interests,
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime? toDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
    }

    return ProfileModel(
      id: json['id'] as String? ?? json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      bio: json['bio'] as String?,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : const [],
      createdAt: toDateTime(json['createdAt']),
      updatedAt: toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'image': image,
      'bio': bio,
      'interests': interests,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // For compatibility with UserModel
  factory ProfileModel.fromUserModel(dynamic user) {
    if (user is Map<String, dynamic>) {
      return ProfileModel.fromJson(user);
    }
    return ProfileModel(
      id: user.id,
      email: user.email,
      name: user.name,
      image: user.image,
      bio: user.bio,
      interests: user.interests ?? const [],
      createdAt: user.createdAt,
    );
  }
}
