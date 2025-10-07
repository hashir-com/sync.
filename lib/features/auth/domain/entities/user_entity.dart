import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? image;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.name,
    this.image,
    this.phoneNumber,
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
        createdAt,
        updatedAt,
      ];
}
