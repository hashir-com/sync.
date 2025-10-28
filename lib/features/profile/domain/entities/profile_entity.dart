import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? image;
  final String? bio;
  final List<String> interests;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    this.image,
    this.bio,
    this.interests = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        image,
        bio,
        interests,
        createdAt,
        updatedAt,
      ];
}