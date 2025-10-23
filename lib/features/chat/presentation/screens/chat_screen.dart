import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/features/chat/presentation/providers/chat_providers.dart';
import 'package:sync_event/features/chat/presentation/widgets/message_bubble.dart';
import 'package:sync_event/features/chat/presentation/widgets/message_input_field.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(markMessagesAsReadUseCaseProvider).call(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await ref
          .read(sendMessageUseCaseProvider)
          .call(chatId: widget.chatId, text: text);
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    final showDate =
                        index == messages.length - 1 ||
                        !_isSameDay(
                          message.timestamp,
                          messages[index + 1].timestamp,
                        );

                    return Column(
                      children: [
                        if (showDate)
                          _buildDateDivider(message.timestamp, isDark),
                        MessageBubble(
                          message: message,
                          isMe: isMe,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          MessageInputField(
            controller: _messageController,
            onSend: _sendMessage,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime date, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
      child: Text(
        _formatDate(date),
        style: TextStyle(
          color: AppColors.getTextSecondary(isDark),
          fontSize: 12,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }
}
