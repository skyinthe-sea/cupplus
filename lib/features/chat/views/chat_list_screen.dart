import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_providers.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_list_header.dart';
import '../widgets/chat_list_view.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsListProvider);
    final unreadCount = ref.watch(totalUnreadCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatListHeader(
              unreadCount: unreadCount,
            ),
            Expanded(
              child: conversationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$error'),
                      TextButton(
                        onPressed: () => ref.invalidate(conversationsListProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
                data: (conversations) => conversations.isEmpty
                    ? const ChatEmptyState()
                    : ChatListView(
                        conversations: conversations,
                        onRefresh: () async {
                          ref.invalidate(conversationsListProvider);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
