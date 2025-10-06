import 'dart:io';

class ProfileModel {
  final String displayName;
  final File? photoFile;

  ProfileModel({
    required this.displayName,
    this.photoFile,
  });
}