// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// Widget for the header image with back and bookmark buttons
class HeaderImage extends StatefulWidget {
  final EventEntity event;
  final bool isOrganizer;
  final bool isDark;

  const HeaderImage({
    super.key,
    required this.event,
    required this.isOrganizer,
    required this.isDark,
  });

  @override
  State<HeaderImage> createState() => _HeaderImageState();
}

class _HeaderImageState extends State<HeaderImage> {
  bool _isBookmarked = false;

  // Toggle bookmark state
  void _toggleBookmark() => setState(() => _isBookmarked = !_isBookmarked);

  @override
  Widget build(BuildContext context) {
    // Build header with image and overlay
    return Stack(
      children: [
        // Event image or placeholder
        widget.event.imageUrl != null
            ? Image.network(
                widget.event.imageUrl!,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : _buildPlaceholder(),
        // Dark overlay
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Back and bookmark buttons
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: ResponsiveUtil.getResponsivePadding(
              context,
            ).copyWith(top: 42),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(Icons.arrow_back_ios_rounded, () => context.pop()),
                if (!widget.isOrganizer)
                  _buildButton(
                    _isBookmarked ? Icons.favorite : Icons.favorite_border,
                    _toggleBookmark,
                    _isBookmarked
                        ? AppColors.getFavorite(widget.isDark)
                        : Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper for placeholder image
  Widget _buildPlaceholder() => Container(
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.getSurface(widget.isDark),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.getSurface(widget.isDark),
              AppColors.getSurface(widget.isDark).withOpacity(0.8),
            ],
          ),
        ),
        child: Icon(
          Icons.event_rounded,
          size: 80,
          color: AppColors.getPrimary(widget.isDark).withOpacity(0.5),
        ),
      );

  // Helper for buttons
  Widget _buildButton(IconData icon, VoidCallback onTap, [Color? iconColor]) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
        ),
      );
}