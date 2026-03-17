import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../models/chat_message.dart';
import '../models/conversation_summary.dart';

part 'chat_providers.g.dart';

const _messagePageSize = 30;

// ─── Chat List Entry Types ──────────────────────────────────

sealed class ChatListEntry {}

class MessageEntry extends ChatListEntry {
  MessageEntry(this.message, {required this.showAvatar});
  final ChatMessage message;
  final bool showAvatar;
}

class DateEntry extends ChatListEntry {
  DateEntry(this.date);
  final DateTime date;
}

// ─── Conversations List (Notifier + Realtime) ────────────────

@Riverpod(keepAlive: true)
class ConversationsList extends _$ConversationsList {
  final _onlineUserIds = <String>{};

  @override
  Future<List<ConversationSummary>> build() async {
    final client = ref.read(supabaseClientProvider);
    // Watch currentUser so provider rebuilds on login/logout
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    _subscribeRealtime(client, user.id);
    _subscribePresence(client, user.id);
    final conversations = await _fetchConversations(client, user.id);
    // Apply cached online status from Presence
    if (_onlineUserIds.isNotEmpty) {
      return conversations.map((conv) {
        return conv.copyWith(
          isOnline: _onlineUserIds.contains(conv.participantId),
        );
      }).toList();
    }
    return conversations;
  }

  void _subscribeRealtime(SupabaseClient client, String userId) {
    final convChannel = client
        .channel('conv-list-rt')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) async {
            try {
              state = AsyncData(await _fetchConversations(client, userId));
            } catch (_) {}
          },
        );

    final msgChannel = client
        .channel('msg-unread-rt')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isEmpty) return;
            _handleNewMessage(record, userId);
          },
        );

    ref.onDispose(() {
      client.removeChannel(convChannel);
      client.removeChannel(msgChannel);
    });

    convChannel.subscribe();
    msgChannel.subscribe();
  }

  void _subscribePresence(SupabaseClient client, String userId) {
    final presenceChannel = client.channel('managers-presence');

    presenceChannel
        .onPresenceSync((payload) {
          final states = presenceChannel.presenceState();
          _onlineUserIds.clear();
          for (final state in states) {
            for (final p in state.presences) {
              final uid = p.payload['user_id'] as String?;
              if (uid != null) _onlineUserIds.add(uid);
            }
          }
          _updateOnlineStatus();
        })
        .onPresenceJoin((payload) {
          for (final p in payload.newPresences) {
            final uid = p.payload['user_id'] as String?;
            if (uid != null) _onlineUserIds.add(uid);
          }
          _updateOnlineStatus();
        })
        .onPresenceLeave((payload) {
          for (final p in payload.leftPresences) {
            final uid = p.payload['user_id'] as String?;
            if (uid != null) _onlineUserIds.remove(uid);
          }
          _updateOnlineStatus();
        })
        .subscribe((status, [ref]) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await presenceChannel.track({
              'user_id': userId,
              'online_at': DateTime.now().toUtc().toIso8601String(),
            });
          }
        });

    ref.onDispose(() {
      presenceChannel.untrack();
      client.removeChannel(presenceChannel);
    });
  }

  void _updateOnlineStatus() {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.map((conv) {
      final online = _onlineUserIds.contains(conv.participantId);
      if (online == conv.isOnline) return conv;
      return conv.copyWith(isOnline: online);
    }).toList());
  }

  void _handleNewMessage(Map<String, dynamic> record, String userId) {
    final convId = record['conversation_id'] as String?;
    final senderId = record['sender_id'] as String?;
    if (convId == null) return;

    final current = state.valueOrNull;
    if (current == null) return;

    final index = current.indexWhere((c) => c.id == convId);
    if (index == -1) return;

    final updated = current.map((conv) {
      if (conv.id != convId) return conv;
      return conv.copyWith(
        lastMessage: record['content'] as String? ?? '',
        lastMessageType: record['type'] as String? ?? 'text',
        lastMessageAt: DateTime.now(),
        unreadCount:
            senderId != userId ? conv.unreadCount + 1 : conv.unreadCount,
      );
    }).toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    state = AsyncData(updated);
  }

  void markConversationAsRead(String conversationId) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.map((conv) {
      if (conv.id != conversationId) return conv;
      return conv.copyWith(unreadCount: 0);
    }).toList());
  }

  Future<void> refresh() async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;
    state = AsyncData(await _fetchConversations(client, user.id));
  }
}

Future<List<ConversationSummary>> _fetchConversations(
  SupabaseClient client,
  String userId,
) async {
  final rows = await client
      .from('conversations')
      .select()
      .or('participant_a.eq.$userId,participant_b.eq.$userId')
      .order('last_message_at', ascending: false);

  if (rows.isEmpty) return [];

  final participantIds = <String>{};
  final matchIds = <String>[];
  for (final row in rows) {
    final isA = row['participant_a'] == userId;
    participantIds
        .add(isA ? row['participant_b'] as String : row['participant_a'] as String);
    final matchId = row['match_id'] as String?;
    if (matchId != null) matchIds.add(matchId);
  }

  final convIds = rows.map((r) => r['id'] as String).toList();

  // Batch parallel queries
  final managersFuture = client
      .from('managers')
      .select('id, full_name')
      .inFilter('id', participantIds.toList());

  final lastMessagesFuture = client
      .from('messages')
      .select('conversation_id, content, type, created_at')
      .inFilter('conversation_id', convIds)
      .order('created_at', ascending: false)
      .limit(convIds.length * 3);

  // Single RPC call replaces N+1 individual count queries
  final unreadCountFuture = client.rpc('get_unread_counts', params: {
    'p_user_id': userId,
    'p_conv_ids': convIds,
  });

  final matchesFuture = matchIds.isNotEmpty
      ? client
          .from('matches')
          .select('id, client_a_id, client_b_id')
          .inFilter('id', matchIds)
      : Future.value(<Map<String, dynamic>>[]);

  final baseResults = await Future.wait([
    managersFuture,
    lastMessagesFuture,
    matchesFuture,
  ]);
  // RPC returns dynamic — await separately to avoid type inference issues
  final unreadRows = await unreadCountFuture as List<dynamic>;

  final managerMap = <String, String>{};
  for (final m in baseResults[0] as List<dynamic>) {
    managerMap[m['id'] as String] = m['full_name'] as String;
  }

  final lastMessageMap = <String, Map<String, dynamic>>{};
  for (final msg in baseResults[1] as List<dynamic>) {
    final convId = msg['conversation_id'] as String;
    if (!lastMessageMap.containsKey(convId)) {
      lastMessageMap[convId] = msg as Map<String, dynamic>;
    }
  }

  final unreadCountMap = <String, int>{};
  for (final row in unreadRows) {
    unreadCountMap[row['conversation_id'] as String] =
        (row['unread_count'] as num).toInt();
  }

  final matchClientIds = <String>{};
  final matchRows = baseResults[2] as List<dynamic>;
  for (final m in matchRows) {
    matchClientIds.add(m['client_a_id'] as String);
    matchClientIds.add(m['client_b_id'] as String);
  }

  Map<String, String> clientNameMap = {};
  if (matchClientIds.isNotEmpty) {
    final clientRows = await client
        .from('clients')
        .select('id, full_name')
        .inFilter('id', matchClientIds.toList());
    for (final c in clientRows) {
      clientNameMap[c['id'] as String] = c['full_name'] as String;
    }
  }

  final matchContextMap = <String, String>{};
  for (final m in matchRows) {
    final matchId = m['id'] as String;
    final nameA = clientNameMap[m['client_a_id'] as String] ?? '?';
    final nameB = clientNameMap[m['client_b_id'] as String] ?? '?';
    matchContextMap[matchId] = '$nameA ↔ $nameB';
  }

  return rows.map((row) {
    final convId = row['id'] as String;
    final isA = row['participant_a'] == userId;
    final otherId =
        isA ? row['participant_b'] as String : row['participant_a'] as String;
    final lastMsg = lastMessageMap[convId];
    final matchId = row['match_id'] as String?;

    return ConversationSummary(
      id: convId,
      participantId: otherId,
      participantName: managerMap[otherId] ?? '?',
      lastMessage: lastMsg?['content'] as String? ?? '',
      lastMessageType: lastMsg?['type'] as String? ?? 'text',
      lastMessageAt: row['last_message_at'] != null
          ? DateTime.parse(row['last_message_at'] as String)
          : DateTime.now(),
      unreadCount: unreadCountMap[convId] ?? 0,
      isOnline: false,
      matchId: matchId,
      matchContext: matchId != null ? matchContextMap[matchId] : null,
    );
  }).toList();
}

// ─── Derived: Total Unread Count ─────────────────────────────

@riverpod
int totalUnreadCount(Ref ref) {
  final conversations = ref.watch(conversationsListProvider).valueOrNull ?? [];
  return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
}

// ─── Derived: Conversation Detail ────────────────────────────

@riverpod
ConversationSummary? conversationDetail(Ref ref, String conversationId) {
  final conversations = ref.watch(conversationsListProvider).valueOrNull ?? [];
  return conversations.where((c) => c.id == conversationId).firstOrNull;
}

// ─── Conversation Messages (Pagination Notifier) ─────────────

@riverpod
class ConversationMessages extends _$ConversationMessages {
  int _currentPage = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<ChatMessage>> build(String conversationId) async {
    _currentPage = 0;
    _hasMore = true;
    return _fetchPage(0);
  }

  Future<List<ChatMessage>> _fetchPage(int page) async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return [];

    final from = page * _messagePageSize;
    final to = from + _messagePageSize - 1;

    final rows = await client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .range(from, to);

    if (rows.length < _messagePageSize) {
      _hasMore = false;
    }

    return rows.reversed
        .map((row) => ChatMessage.fromMap(row, currentUserId: user.id))
        .toList();
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final currentState = state;
    if (currentState is! AsyncData<List<ChatMessage>>) return;

    _currentPage++;
    final olderMessages = await _fetchPage(_currentPage);

    state = AsyncData([...olderMessages, ...currentState.value]);
  }
}

// ─── Local Messages (optimistic + realtime incoming) ─────────

@riverpod
class LocalMessages extends _$LocalMessages {
  @override
  List<ChatMessage> build(String conversationId) => [];

  void add(ChatMessage msg) {
    state = [...state, msg];
  }

  void remove(String id) {
    state = state.where((m) => m.id != id).toList();
  }

  void replace(String id, ChatMessage replacement) {
    state = state.map((m) => m.id == id ? replacement : m).toList();
  }
}

// ─── Chat Room Entries (computed — merges server + local) ─────

@riverpod
List<ChatListEntry> chatRoomEntries(Ref ref, String conversationId) {
  final serverMessages = ref.watch(
    conversationMessagesProvider(conversationId),
  ).valueOrNull ?? [];
  final localMessages = ref.watch(localMessagesProvider(conversationId));
  return _buildChatEntries(serverMessages, localMessages);
}

List<ChatListEntry> _buildChatEntries(
  List<ChatMessage> serverMessages,
  List<ChatMessage> localMessages,
) {
  final seenIds = <String>{};
  final allMessages = <ChatMessage>[];

  for (final msg in serverMessages) {
    if (seenIds.add(msg.id)) allMessages.add(msg);
  }
  for (final msg in localMessages) {
    if (seenIds.add(msg.id)) allMessages.add(msg);
  }

  allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final entries = <ChatListEntry>[];
  DateTime? lastDate;

  for (var i = 0; i < allMessages.length; i++) {
    final msg = allMessages[i];
    final msgDate =
        DateTime(msg.createdAt.year, msg.createdAt.month, msg.createdAt.day);

    if (lastDate == null || msgDate != lastDate) {
      entries.add(DateEntry(msg.createdAt));
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

    entries
        .add(MessageEntry(msg, showAvatar: isFirstFromSender && !msg.isMine));
  }

  return entries.reversed.toList();
}

// ─── Mutations ───────────────────────────────────────────────

@riverpod
Future<void> sendMessage(
  Ref ref, {
  required String conversationId,
  required String content,
  String type = 'text',
  String? imageUrl,
}) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  await client.from('messages').insert({
    'conversation_id': conversationId,
    'sender_id': user.id,
    'content': content,
    'type': type,
    'image_url': imageUrl,
  });
}

@riverpod
Future<void> markAsRead(Ref ref, String conversationId) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  await client
      .from('messages')
      .update({'is_read': true})
      .eq('conversation_id', conversationId)
      .neq('sender_id', user.id)
      .eq('is_read', false);

  // Locally update unread count instead of full refetch
  ref
      .read(conversationsListProvider.notifier)
      .markConversationAsRead(conversationId);
}

@riverpod
Future<String> uploadChatImage(
  Ref ref, {
  required String conversationId,
  required List<int> bytes,
}) async {
  final client = ref.read(supabaseClientProvider);

  final storagePath =
      '$conversationId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  await client.storage
      .from('chat-images')
      .uploadBinary(storagePath, Uint8List.fromList(bytes));

  return 'chat-images/$storagePath';
}
