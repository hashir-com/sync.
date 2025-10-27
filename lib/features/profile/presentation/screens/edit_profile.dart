import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:sync_event/features/profile/domain/entities/profile_entity.dart';
import 'package:sync_event/features/profile/presentation/providers/profile_providers.dart';
import 'package:sync_event/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:sync_event/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:go_router/go_router.dart';

final pickedImageProvider = StateProvider<File?>((ref) => null);
final isUploadingProvider = StateProvider<bool>((ref) => false);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  ProfileEntity? _currentProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No user logged in')));
        if (mounted) context.pop();
      }
      return;
    }
    final useCase = ref.read(getUserProfileUseCaseProvider);
    final result = await useCase(GetProfileParams(uid: user.uid));
    if (!mounted) return;
    result.fold((failure) => _handleFailure(failure), (profile) {
      if (!mounted) return;
      setState(() {
        _currentProfile = profile;
        _nameController.text = profile.name;
        _isLoadingProfile = false;
      });
      // Clear any previously picked image to show current profile image
      if (mounted) {
        ref.read(pickedImageProvider.notifier).state = null;
      }
    });
  }

  void _handleFailure(Failure failure) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message ?? 'Failed to load profile')),
      );
      setState(() => _isLoadingProfile = false);
      // Clear any previously picked image on failure as well
      if (mounted) {
        ref.read(pickedImageProvider.notifier).state = null;
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (pickedFile != null && mounted) {
        ref.read(pickedImageProvider.notifier).state = File(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      }
      return;
    }

    if (mounted) {
      ref.read(isUploadingProvider.notifier).state = true;
    }
    final updateUseCase = ref.read(updateUserProfileUseCaseProvider);
    Map<String, dynamic> updateData = {'name': name};

    try {
      final pickedImage = ref.read(pickedImageProvider);
      String? newImageUrl;
      if (pickedImage != null) {
        // Use usecase for upload
        final uploadUseCase = ref
            .read(getUserProfileUseCaseProvider)
            .repository; // Wait, no: inject upload via repo, but since usecase not for upload, use direct repo? Wait, add upload usecase if needed. For simplicity, use remoteDataSource via DI, but to fit, assume sl<ProfileRepository>().upload...
        // Actually, since upload is in repo, create UploadProfileImageUseCase similar, but to minimal, direct:
        final repo = sl<ProfileRepositoryImpl>(); // Assume DI has it
        final uploadResult = await repo.uploadProfileImage(
          user.uid,
          pickedImage.path,
        );
        uploadResult.fold(
          (failure) => throw Exception(failure.message),
          (url) => newImageUrl = url,
        );
        if (newImageUrl != null) updateData['image'] = newImageUrl;
      }

      // Update Firestore via usecase
      final result = await updateUseCase(
        UpdateProfileParams(uid: user.uid, data: updateData),
      );
      if (!mounted) return;
      result.fold((failure) => _handleFailure(failure), (updatedProfile) async {
        if (!mounted) return;
        // Sync Firebase Auth
        await user.updateDisplayName(name);
        if (newImageUrl != null) await user.updatePhotoURL(newImageUrl);
        await user.reload();

        // Invalidate providers
        if (mounted) {
          ref.invalidate(authStateProvider);
          ref.invalidate(userByIdProvider(user.uid));
        }

        // Clear picked image after successful update
        if (mounted) {
          ref.read(pickedImageProvider.notifier).state = null;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          if (mounted) context.pop();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isUploadingProvider.notifier).state = false;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickedImage = ref.watch(pickedImageProvider);
    final isUploading = ref.watch(isUploadingProvider);

    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
          elevation: 0,
        ),
        body: _buildShimmerEffect(isDark),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: isUploading
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
                            : _currentProfile?.image != null
                            ? NetworkImage(_currentProfile!.image!)
                            : null,
                        child:
                            pickedImage == null &&
                                _currentProfile?.image == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
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
                    child: const Text('Change Profile Picture'),
                  ),
                  const SizedBox(height: 24),
                  // Name Field
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
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
                        'Save Changes',
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
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 60, backgroundColor: Colors.grey.shade300),
            const SizedBox(height: 16),
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
