import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/profile/presentation/provider/user_provider.dart';

// Provider for the picked image
final pickedImageProvider = StateProvider<File?>((ref) => null);

// Provider for the uploading state
final isUploadingProvider = StateProvider<bool>((ref) => false);

// Provider for the name input
final nameControllerProvider = StateProvider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName ?? '';
});

// Provider for user stats 
final userStatsProvider = Provider<Map<String, String>>((ref) {
  return {'following': '950', 'followers': '550'};
});

final userChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

// Provider for user interests
final interestsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [
    {'label': 'Games', 'icon': Icons.videogame_asset, 'color': Colors.blue},
    {'label': 'Concerts', 'icon': Icons.music_note, 'color': Colors.red},
    {'label': 'Art', 'icon': Icons.brush, 'color': Colors.purple},
    {'label': 'Music', 'icon': Icons.library_music, 'color': Colors.green},
    {'label': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.orange},
    {'label': 'Theatre', 'icon': Icons.theaters, 'color': Colors.teal},
  ];
});
