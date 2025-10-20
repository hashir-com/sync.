// Add this to your event_providers.dart or create a new user_providers.dart file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================
// User Model (if you don't have one already)
// ============================================

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final List<String>? interests;
  final int? hostedEventsCount;
  final int? followersCount;
  final double? rating;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.interests,
    this.hostedEventsCount,
    this.followersCount,
    this.rating,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
      interests: data['interests'] != null 
          ? List<String>.from(data['interests']) 
          : null,
      hostedEventsCount: data['hostedEventsCount'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      rating: data['rating']?.toDouble(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'interests': interests,
      'hostedEventsCount': hostedEventsCount,
      'followersCount': followersCount,
      'rating': rating,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}

// ============================================
// User Providers
// ============================================

// Provider to get all users from Firestore
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  });
});

// Provider to get a specific user by ID
final userByIdProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  });
});

// Provider to get events hosted by a specific user
final userHostedEventsProvider = StreamProvider.family<List<dynamic>, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('events')
      .where('hostId', isEqualTo: userId)
      .where('status', isEqualTo: 'approved')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    // Use your Event model here
    // return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    
    // For now, returning dynamic. Replace with your Event model
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  });
});

// Provider to search users by name or email
final searchUsersProvider = StreamProvider.family<List<UserModel>, String>((ref, query) {
  if (query.isEmpty || query.length < 2) {
    return Stream.value([]);
  }

  final lowerQuery = query.toLowerCase();
  
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) {
          return user.name.toLowerCase().contains(lowerQuery) ||
              user.email.toLowerCase().contains(lowerQuery);
        })
        .toList();
  });
});

// Provider to get user's followers count
final userFollowersCountProvider = StreamProvider.family<int, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value(0);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('followers')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// Provider to get user's following count
final userFollowingCountProvider = StreamProvider.family<int, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value(0);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('following')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});