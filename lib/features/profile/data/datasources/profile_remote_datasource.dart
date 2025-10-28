import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
  Future<String> uploadProfileImage(File imageFile, String userId);
  Future<void> deleteProfileImage(String imageUrl);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ProfileRemoteDataSourceImpl({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    final doc = await firebaseFirestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()!;
    } else {
      throw Exception('User profile not found');
    }
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await firebaseFirestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    final ref = firebaseStorage.ref().child('users/$userId/profile.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = firebaseStorage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image might not exist, ignore error
    }
  }
}