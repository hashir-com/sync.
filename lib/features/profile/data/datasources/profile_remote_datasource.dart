import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:sync_event/core/error/exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
  Future<String> uploadProfileImage(File imageFile, String userId);
  Future<void> deleteProfileImage(String imageUrl);
  Future<Map<String, dynamic>> createUserProfile(String uid, Map<String, dynamic> data);
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
  
 @override
Future<Map<String, dynamic>> createUserProfile(String uid, Map<String, dynamic> data) async {
  try {
    await firebaseFirestore.collection('users').doc(uid).set(data); // Use uid as doc ID; merge: false for full create
    return data; // Or fetch and return full doc data if needed
  } on FirebaseException catch (e) {
    throw ServerException(message: e.message ?? 'Failed to create user profile');
  }
}

  
}