import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';

// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider to fetch user data by UID
final userDataProvider = FutureProvider.family<UserEntity?, String>((ref, uid) async {
  if (uid.isEmpty) return null;
  
  final firestore = ref.watch(firestoreProvider);
  
  try {
    final doc = await firestore.collection('users').doc(uid).get();
    
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        return UserEntity(
          uid: data['uid'] ?? uid,
          email: data['email'] ?? '',
          name: data['name'],
          image: data['image'],
          phoneNumber: data['phoneNumber'],
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate() 
              : null,
          updatedAt: data['updatedAt'] != null 
              ? (data['updatedAt'] as Timestamp).toDate() 
              : null,
        );
      }
    }
    return null;
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
});