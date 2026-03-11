import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_dummy_data.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_list_header.dart';
import '../widgets/chat_list_view.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(allConversationsProvider);
    final unreadCount = ref.watch(totalUnreadCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatListHeader(unreadCount: unreadCount),
            Expanded(
              child: conversations.isEmpty
                  ? const ChatEmptyState()
                  : ChatListView(conversations: conversations),
            ),
          ],
        ),
      ),
    );
  }
}
