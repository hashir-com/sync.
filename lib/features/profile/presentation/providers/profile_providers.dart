// lib/features/profile/presentation/providers/profile_providers.dart
// UPDATED VERSION WITH AUTH STATE LISTENER

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/features/profile/domain/usecases/create_user_usecase.dart';
import 'package:sync_event/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:sync_event/features/profile/domain/usecases/update_user_profile_usecase.dart';

// UserModel (unified with ProfileEntity for consistency)
class UserModel extends ProfileEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.image,
    super.bio,
    super.interests,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      image: data['image'],
      bio: data['bio'],
      interests: data['interests'] != null
          ? List<String>.from(data['interests'])
          : const [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromFirebaseUser(firebase_auth.User? user) {
    if (user == null) {
      throw ArgumentError('User cannot be null');
    }
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      image: user.photoURL,
    );
  }

  factory UserModel.fromProfileEntity(ProfileEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      image: entity.image,
      bio: entity.bio,
      interests: entity.interests,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

final createUserProfileUseCaseProvider = Provider<CreateUserProfileUseCase>(
  (ref) => sl<CreateUserProfileUseCase>(),
);

// CRITICAL FIX: Auth State Provider that invalidates on changes
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return firebase_auth.FirebaseAuth.instance.userChanges().asyncMap((
    user,
  ) async {
    if (user == null) {
      print(' Auth state changed: User logged out');
      return null;
    }

    print(' Auth state changed: User logged in - ${user.uid}');

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return UserModel.fromFirebaseUser(user);
      }
    } catch (e) {
      print('⚠️ Error fetching user profile: $e');
      return UserModel.fromFirebaseUser(user);
    }
  });
});

// Current Firebase User (synchronous access)
final currentUserProvider = Provider<firebase_auth.User?>((ref) {
  // Watch auth state to trigger rebuilds
  final authState = ref.watch(authStateProvider);
  return firebase_auth.FirebaseAuth.instance.currentUser;
});

// All Users
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  // Listen to auth state - if null, return empty
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance.collection('users').snapshots().map((
        snapshot,
      ) {
        return snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList();
      });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// CRITICAL FIX: User by ID - now invalidates when auth changes
final userByIdProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  // Watch current user to detect auth changes
  final currentUser = ref.watch(currentUserProvider);

  print(
    ' userByIdProvider called for userId: $userId, currentUser: ${currentUser?.uid}',
  );

  if (userId.isEmpty) {
    print('⚠️ Empty userId provided');
    return Stream.value(null);
  }

  // If no current user and requesting own profile, return null
  if (currentUser == null && userId == currentUser?.uid) {
    print(' No current user, returning null');
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) {
          print('⚠️ Profile document does not exist for: $userId');
          return null;
        }
        print(' Profile loaded for: $userId');
        return UserModel.fromFirestore(doc);
      });
});

// User Hosted Events - also watches auth state
final userHostedEventsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      // Watch current user
      final currentUser = ref.watch(currentUserProvider);

      if (userId.isEmpty || currentUser == null) {
        return Stream.value([]);
      }

      return FirebaseFirestore.instance
          .collection('events')
          .where('organizerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList();
          });
    });

// Search Users
final searchUsersProvider = StreamProvider.family<List<UserModel>, String>((
  ref,
  query,
) {
  final currentUser = ref.watch(currentUserProvider);

  if (query.isEmpty || query.length < 2 || currentUser == null) {
    return Stream.value([]);
  }

  final lowerQuery = query.toLowerCase();
  return FirebaseFirestore.instance.collection('users').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where(
          (user) =>
              user.name.toLowerCase().contains(lowerQuery) ||
              user.email.toLowerCase().contains(lowerQuery),
        )
        .toList();
  });
});

// Followers Count
final userFollowersCountProvider = StreamProvider.family<int, String>((
  ref,
  userId,
) {
  if (userId.isEmpty) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('followers')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// Following Count
final userFollowingCountProvider = StreamProvider.family<int, String>((
  ref,
  userId,
) {
  if (userId.isEmpty) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('following')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>(
  (ref) => sl<GetUserProfileUseCase>(),
);

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>(
  (ref) => sl<UpdateUserProfileUseCase>(),
);
