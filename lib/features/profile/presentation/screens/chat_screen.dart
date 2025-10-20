import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Chat Screen

class ChatScreen extends ConsumerStatefulWidget {
  final dynamic otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // TODO: Implement send message logic
    // Add message to Firebase/your backend

    _messageController.clear();

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_rounded, color: Colors.white),
            SizedBox(width: AppSizes.spacingSmall),
            Expanded(child: Text('Messaging feature coming soon!')),
          ],
        ),
        backgroundColor: AppColors.getPrimary(ThemeUtils.isDark(context)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        margin: EdgeInsets.all(AppSizes.paddingMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getCard(isDark),
        elevation: 1,
        shadowColor: AppColors.getShadow(isDark),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getTextPrimary(isDark)),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.getSurface(isDark),
                image: widget.otherUser.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.otherUser.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.otherUser.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      color: AppColors.getTextSecondary(isDark),
                      size: 20,
                    )
                  : null,
            ),
            SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: AppTextStyles.bodyMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Online',
                    style: AppTextStyles.bodySmall(
                      isDark: isDark,
                    ).copyWith(color: AppColors.success, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () {
              _showChatOptions(context, isDark);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(child: _buildComingSoonMessage(isDark)),

          // Message Input
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildComingSoonMessage(bool isDark) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(AppSizes.paddingXxl),
        padding: EdgeInsets.all(AppSizes.paddingXxl),
        decoration: BoxDecoration(
          color: AppColors.getCard(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingXl),
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDark).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: AppColors.getPrimary(isDark),
              ),
            ),
            SizedBox(height: AppSizes.spacingXl),
            Text(
              'Messaging Coming Soon',
              style: AppTextStyles.titleLarge(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              'Real-time messaging feature is under development.\nYou\'ll be able to chat with ${widget.otherUser.name} soon!',
              style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                color: AppColors.getTextSecondary(isDark),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingXl),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back),
              label: Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(isDark),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXxl,
                  vertical: AppSizes.paddingLarge,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDark),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment Button
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: AppColors.getPrimary(isDark),
              ),
              onPressed: () {
                _showAttachmentOptions(context, isDark);
              },
            ),

            // Text Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.bodyMedium(
                      isDark: isDark,
                    ).copyWith(color: AppColors.getTextSecondary(isDark)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLarge,
                      vertical: AppSizes.paddingMedium,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),

            SizedBox(width: AppSizes.spacingSmall),

            // Send Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDark),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getPrimary(isDark).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.getCard(isDark),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXxl),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.getTextSecondary(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: Column(
                  children: [
                    Text(
                      'Attachments',
                      style: AppTextStyles.titleMedium(
                        isDark: isDark,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: AppSizes.spacingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _AttachmentOption(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          color: Colors.purple,
                          isDark: isDark,
                        ),
                        _AttachmentOption(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          color: Colors.pink,
                          isDark: isDark,
                        ),
                        _AttachmentOption(
                          icon: Icons.insert_drive_file_rounded,
                          label: 'Document',
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacingLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.getCard(isDark),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXxl),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.getTextSecondary(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: AppColors.getPrimary(isDark),
                ),
                title: Text(
                  'View Profile',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: AppColors.getError(isDark)),
                title: Text(
                  'Block User',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.report, color: AppColors.getError(isDark)),
                title: Text(
                  'Report',
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
        ),
      ),
    );
  }
}

// Attachment Option Widget

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.paddingLarge),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        SizedBox(height: AppSizes.spacingSmall),
        Text(label, style: AppTextStyles.bodySmall(isDark: isDark)),
      ],
    );
  }
}
