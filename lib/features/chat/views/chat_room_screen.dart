import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../providers/chat_dummy_data.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/date_separator.dart';
import '../widgets/message_bubble.dart';

sealed class _ChatListEntry {}

class _MessageEntry extends _ChatListEntry {
  _MessageEntry(this.message, {required this.showAvatar});
  final ChatMessage message;
  final bool showAvatar;
}

class _DateEntry extends _ChatListEntry {
  _DateEntry(this.date);
  final DateTime date;
}

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _scrollController = ScrollController();
  final List<ChatMessage> _localMessages = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<_ChatListEntry> _buildEntries(List<ChatMessage> messages) {
    final allMessages = [...messages, ..._localMessages];
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final entries = <_ChatListEntry>[];
    DateTime? lastDate;

    for (var i = 0; i < allMessages.length; i++) {
      final msg = allMessages[i];
      final msgDate = DateTime(msg.createdAt.year, msg.createdAt.month, msg.createdAt.day);

      if (lastDate == null || msgDate != lastDate) {
        entries.add(_DateEntry(msg.createdAt));
        lastDate = msgDate;
      }

      final isFirstFromSender = i == 0 ||
          allMessages[i - 1].senderId != msg.senderId ||
          DateTime(
                allMessages[i - 1].createdAt.year,
                allMessages[i - 1].createdAt.month,
                allMessages[i - 1].createdAt.day,
              ) !=
              msgDate;

      entries.add(_MessageEntry(msg, showAvatar: isFirstFromSender && !msg.isMine));
    }

    return entries.reversed.toList();
  }

  void _handleSend(String text) {
    setState(() {
      _localMessages.add(ChatMessage(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: widget.conversationId,
        senderId: 'manager-self',
        content: text,
        type: 'text',
        isRead: false,
        createdAt: DateTime.now(),
        isMine: true,
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final messages = ref.watch(conversationMessagesProvider(widget.conversationId));
    final conversations = ref.watch(allConversationsProvider);
    final conversation = conversations.where((c) => c.id == widget.conversationId).firstOrNull;

    final participantName = conversation?.participantName ?? '';
    final isOnline = conversation?.isOnline ?? false;
    final entries = _buildEntries(messages);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1C20) : const Color(0xFFEBF1F8),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                participantName.characters.firstOrNull ?? '?',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participantName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isOnline ? l10n.chatOnline : l10n.chatOffline,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isOnline
                        ? const Color(0xFF2E7D32)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return switch (entry) {
                  _DateEntry(:final date) => DateSeparator(date: date),
                  _MessageEntry(:final message, :final showAvatar) => MessageBubble(
                      message: message,
                      showAvatar: showAvatar,
                      participantName: participantName,
                    ),
                };
              },
            ),
          ),
          ChatInputArea(onSend: _handleSend),
        ],
      ),
    );
  }
}
