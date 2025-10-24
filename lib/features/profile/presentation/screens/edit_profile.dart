// lib/features/profile/presentation/screens/edit_profile_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/features/profile/presentation/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

// Providers
final pickedImageProvider = StateProvider<File?>((ref) => null);
final isUploadingProvider = StateProvider<bool>((ref) => false);
final nameControllerProvider = StateProvider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName ?? '';
});

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.text = ref.read(nameControllerProvider);
      _nameController.addListener(() {
        ref.read(nameControllerProvider.notifier).state = _nameController.text;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        ref.read(pickedImageProvider.notifier).state = File(pickedFile.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _updateProfile() async {
    final user = ref.read(currentUserProvider);
    final name = ref.read(nameControllerProvider).trim();

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user logged in')));
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    ref.read(isUploadingProvider.notifier).state = true;

    try {
      String? photoURL = user.photoURL;
      final pickedImage = ref.read(pickedImageProvider);

      if (pickedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'profile_pictures/${user.uid}',
        );
        await storageRef.putFile(
          pickedImage,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoURL = await storageRef.getDownloadURL();
      }

      final success = await ref
          .read(profileNotifierProvider.notifier)
          .updateProfile(displayName: name, photoURL: photoURL);

      if (!mounted) return;

      if (success) {
        await FirebaseAuth.instance.currentUser?.reload();
        ref.invalidate(authStateProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(profileNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) ref.read(isUploadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final pickedImage = ref.watch(pickedImageProvider);
    final isUploading = ref.watch(isUploadingProvider);
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: isUploading || profileState.isLoading
          ? _buildShimmerEffect(isDark)
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: pickedImage != null
                            ? FileImage(pickedImage)
                            : user?.photoURL != null
                            ? NetworkImage(user!.photoURL!) as ImageProvider
                            : null,
                        child: pickedImage == null && user?.photoURL == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade600,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text("Change Profile Picture"),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.cardDark : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerEffect(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 60, backgroundColor: Colors.grey.shade300),
            const SizedBox(height: 10),
            Container(width: 160, height: 20, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
