import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? image;
  final String? phoneNumber;
  final String? bio;
  final List<String> interests;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.uid,
    required this.email,
    this.name,
    this.image,
    this.phoneNumber,
    this.bio,
    this.interests = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    name,
    image,
    phoneNumber,
    bio,
    interests,
    createdAt,
    updatedAt,
  ];
}
