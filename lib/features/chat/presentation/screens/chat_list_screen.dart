import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/features/chat/presentation/providers/chat_providers.dart';
import 'package:sync_event/features/chat/presentation/widgets/chat_list_tile.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final chatsAsync = ref.watch(userChatsStreamProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/chat/search');
            },
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  SizedBox(height: AppSizes.spacingLarge),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: AppSizes.fontLarge,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    'Start a conversation',
                    style: TextStyle(
                      fontSize: AppSizes.fontMedium,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatListTile(
                chat: chat,
                currentUserId: currentUserId,
                isDark: isDark,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),

              Builder(
                builder: (_) {
                  debugPrint(
                    'Error occurred in userChatsStreamProvider: $error',
                  );
                  return const SizedBox.shrink(); // returns empty widget
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userChatsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
