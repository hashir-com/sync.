import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonWidgets {
  static const double _avatarRadius = 50;

  static Widget buildProfileAvatar(String? photoURL, ThemeData theme) {
    return Center(
      child: photoURL != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(photoURL),
              radius: _avatarRadius,
              backgroundColor: theme.colorScheme.surface,
              child: CircleAvatar(
                radius: _avatarRadius - 2,
                backgroundColor: Colors.transparent,
              ),
            )
          : CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: theme.colorScheme.surfaceContainer,
              child: Icon(
                Icons.person,
                size: 40,
                // ignore: deprecated_member_use
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
    );
  }

  static Widget buildEditProfileShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 50, backgroundColor: Colors.grey.shade300),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(width: 150, height: 20, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
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