import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../../../shared/models/client_summary.dart';
import '../models/activity_feed_item.dart';

part 'home_providers.g.dart';

DateTime _parseDateTime(dynamic value) {
  if (value is String) return DateTime.parse(value).toLocal();
  return DateTime.now();
}

// ─── Helper: Realtime-backed stream ──────────────────────────
// Creates a stream that fetches initial data, then refetches on
// Realtime changes for the specified tables.

Stream<T> _realtimeStream<T>({
  required Ref ref,
  required SupabaseClient client,
  required String channelName,
  required List<String> tables,
  required Future<T> Function() fetcher,
  Duration debounce = const Duration(milliseconds: 300),
}) async* {
  // Initial fetch
  yield await fetcher();

  // Subscribe to Realtime changes on all specified tables
  final controller = StreamController<T>.broadcast();
  Timer? debounceTimer;
  var ch = client.channel(channelName);
  for (final table in tables) {
    ch = ch.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      callback: (_) {
        if (controller.isClosed) return;
        debounceTimer?.cancel();
        debounceTimer = Timer(debounce, () async {
          if (controller.isClosed) return;
          try {
            controller.add(await fetcher());
          } catch (_) {}
        });
      },
    );
  }

  ref.onDispose(() {
    debounceTimer?.cancel();
    controller.close();
    client.removeChannel(ch);
  });

  ch.subscribe();

  await for (final data in controller.stream) {
    yield data;
  }
}

// ─── Today Stats (Realtime) ──────────────────────────────────

@riverpod
Stream<({int pendingMatches, int newMessages})> homeTodayStats(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  // Watch currentUser so provider rebuilds on login/logout
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value((pendingMatches: 0, newMessages: 0));
  }

  return _realtimeStream(
    ref: ref,
    client: client,
    channelName: 'home-stats-rt',
    tables: ['matches', 'messages'],
    fetcher: () async {
      // Get my client IDs to find both sent and received pending matches
      final myClientsForStats = await client
          .from('clients')
          .select('id')
          .eq('manager_id', user.id);
      final myClientIdsForStats =
          myClientsForStats.map((c) => c['id'] as String).toList();

      List<dynamic> pendingResult = [];
      if (myClientIdsForStats.isNotEmpty) {
        final sentPending = await client
            .from('matches')
            .select('id')
            .inFilter('client_a_id', myClientIdsForStats)
            .eq('status', 'pending');
        final receivedPending = await client
            .from('matches')
            .select('id')
            .inFilter('client_b_id', myClientIdsForStats)
            .eq('status', 'pending');
        final pendingIds = <String>{};
        for (final m in sentPending) {
          pendingIds.add(m['id'] as String);
        }
        for (final m in receivedPending) {
          pendingIds.add(m['id'] as String);
        }
        pendingResult = pendingIds.toList();
      }

      final conversations = await client
          .from('conversations')
          .select('id')
          .or('participant_a.eq.${user.id},participant_b.eq.${user.id}');

      int unreadCount = 0;
      if (conversations.isNotEmpty) {
        final convIds =
            conversations.map((c) => c['id'] as String).toList();
        final unread = await client
            .from('messages')
            .select('id')
            .inFilter('conversation_id', convIds)
            .neq('sender_id', user.id)
            .eq('is_read', false);
        unreadCount = unread.length;
      }

      return (pendingMatches: pendingResult.length, newMessages: unreadCount);
    },
  );
}

// ─── Unread Notification Count (Realtime) ────────────────────

@riverpod
Stream<int> unreadNotificationCount(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(0);

  return _realtimeStream(
    ref: ref,
    client: client,
    channelName: 'notif-count-rt',
    tables: ['notifications'],
    fetcher: () async {
      final result = await client
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .neq('type', 'new_message')
          .eq('is_read', false);
      return result.length;
    },
  );
}

// ─── Notifications List (Realtime) ───────────────────────────

@riverpod
Stream<List<Map<String, dynamic>>> notificationsList(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return _realtimeStream(
    ref: ref,
    client: client,
    channelName: 'notif-list-rt',
    tables: ['notifications'],
    fetcher: () async {
      final result = await client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .neq('type', 'new_message')
          .order('created_at', ascending: false)
          .limit(50);
      return result;
    },
  );
}

// ─── Activity Feed (Realtime) ────────────────────────────────

@riverpod
Stream<List<ActivityFeedItem>> activityFeed(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return _realtimeStream(
    ref: ref,
    client: client,
    channelName: 'activity-feed-rt',
    tables: ['matches', 'clients'],
    fetcher: () => _fetchActivityFeed(client, user.id),
  );
}

Future<List<ActivityFeedItem>> _fetchActivityFeed(
  SupabaseClient client,
  String userId,
) async {
  final sevenDaysAgo =
      DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

  // Get my client IDs to find both sent and received matches
  final myClientsResult = await client
      .from('clients')
      .select('id')
      .eq('manager_id', userId);
  final myClientIds =
      myClientsResult.map((c) => c['id'] as String).toList();

  // Fetch sent matches (manager_id == me) and received matches (my client is client_b, other manager sent)
  List<Map<String, dynamic>> sentMatches = [];
  List<Map<String, dynamic>> receivedMatches = [];

  // Sent: I created this match
  sentMatches = await client
      .from('matches')
      .select()
      .eq('manager_id', userId)
      .gte('matched_at', sevenDaysAgo)
      .order('matched_at', ascending: false)
      .limit(20);

  // Received: my client is client_b and someone else created the match
  if (myClientIds.isNotEmpty) {
    receivedMatches = await client
        .from('matches')
        .select()
        .inFilter('client_b_id', myClientIds)
        .neq('manager_id', userId)
        .gte('matched_at', sevenDaysAgo)
        .order('matched_at', ascending: false)
        .limit(20);
  }

  final matches = <Map<String, dynamic>>[];
  final seenIds = <String>{};
  for (final m in sentMatches) {
    final id = m['id'] as String;
    if (seenIds.add(id)) matches.add({...m, '_is_sent': true});
  }
  for (final m in receivedMatches) {
    final id = m['id'] as String;
    if (seenIds.add(id)) matches.add({...m, '_is_sent': false});
  }

  final clientIds = <String>{};
  for (final m in matches) {
    if (m['client_a_id'] != null) clientIds.add(m['client_a_id'] as String);
    if (m['client_b_id'] != null) clientIds.add(m['client_b_id'] as String);
  }

  final clientNames = <String, String>{};
  if (clientIds.isNotEmpty) {
    final clientsResult = await client
        .from('clients')
        .select('id, full_name')
        .inFilter('id', clientIds.toList());
    for (final c in clientsResult) {
      clientNames[c['id'] as String] = c['full_name'] as String;
    }
  }

  final recentClients = await client
      .from('clients')
      .select('id, full_name, created_at')
      .eq('manager_id', userId)
      .gte('created_at', sevenDaysAgo)
      .order('created_at', ascending: false)
      .limit(20);

  final items = <ActivityFeedItem>[];

  for (final match in matches) {
    final clientAName = clientNames[match['client_a_id'] as String] ?? '?';
    final clientBName = clientNames[match['client_b_id'] as String] ?? '?';
    final status = match['status'] as String;
    final matchedAt = _parseDateTime(match['matched_at']);
    final isSent = match['_is_sent'] as bool;

    // Show "매칭 요청" (sent) or "매칭 요청 받음" (received)
    items.add(ActivityFeedItem(
      id: '${match['id']}_requested',
      type: isSent
          ? ActivityType.matchRequested
          : ActivityType.matchReceivedRequest,
      timestamp: matchedAt,
      clientAName: clientAName,
      clientBName: clientBName,
      matchId: match['id'] as String,
    ));

    // Show "매칭 성사", "매칭 거절", or "매칭 취소" when responded
    final respondedAt = match['responded_at'] as String?;
    if (respondedAt != null &&
        (status == 'accepted' || status == 'declined' || status == 'cancelled')) {
      final activityType = switch (status) {
        'accepted' => ActivityType.matchAccepted,
        'cancelled' => ActivityType.matchCancelled,
        _ => ActivityType.matchDeclined,
      };
      items.add(ActivityFeedItem(
        id: '${match['id']}_$status',
        type: activityType,
        timestamp: _parseDateTime(respondedAt),
        clientAName: clientAName,
        clientBName: clientBName,
        matchId: match['id'] as String,
      ));
    }
  }

  for (final c in recentClients) {
    items.add(ActivityFeedItem(
      id: '${c['id']}_registered',
      type: ActivityType.clientRegistered,
      timestamp: _parseDateTime(c['created_at']),
      clientName: c['full_name'] as String,
      clientId: c['id'] as String,
    ));
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items.take(20).toList();
}

// ─── Recommended Clients (FutureProvider — low frequency) ────

@riverpod
Future<List<ClientSummary>> homeRecommendedClients(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final result = await client
      .from('clients')
      .select()
      .eq('manager_id', user.id)
      .eq('status', 'active')
      .order('created_at', ascending: false)
      .limit(5);

  return result.map((row) {
    final birthDate = row['birth_date'] as String?;
    int birthYear = 1990;
    if (birthDate != null) {
      birthYear = DateTime.parse(birthDate).year;
    }

    return ClientSummary(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      gender: row['gender'] as String,
      birthYear: birthYear,
      occupation: row['occupation'] as String? ?? '',
      company: row['company'] as String?,
      education: row['education'] as String?,
      heightCm: row['height_cm'] as int?,
      profilePhotoUrl: row['profile_photo_url'] as String?,
    );
  }).toList();
}

// ─── Upcoming Schedules (from client_notes) ──────────────────

@riverpod
Future<int> upcomingScheduleCount(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final result = await client
      .from('client_notes')
      .select('id')
      .eq('manager_id', user.id)
      .eq('note_type', 'schedule')
      .eq('is_completed', false)
      .gte('scheduled_at', DateTime.now().toIso8601String());

  return result.length;
}

// ─── Matches By Status (Realtime) ────────────────────────────

@riverpod
Stream<List<Map<String, dynamic>>> matchesByStatus(
  Ref ref,
  String status,
) {
  // Keep data alive for 30s after last listener detaches (prevents data loss on back navigation)
  final link = ref.keepAlive();
  Timer? timer;
  ref.onCancel(() {
    timer = Timer(const Duration(seconds: 30), link.close);
  });
  ref.onResume(() {
    timer?.cancel();
  });

  final client = ref.watch(supabaseClientProvider);
  // Watch currentUser so provider rebuilds on login/logout
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return _realtimeStream(
    ref: ref,
    client: client,
    channelName: 'matches-$status-rt',
    tables: ['matches'],
    fetcher: () => _fetchMatchesByStatus(client, user.id, status),
  );
}

Future<List<Map<String, dynamic>>> _fetchMatchesByStatus(
  SupabaseClient client,
  String userId,
  String status,
) async {
  final List<String> statuses;
  switch (status) {
    case 'pending':
      statuses = ['pending'];
    case 'active':
      statuses = ['accepted', 'meeting_scheduled'];
    case 'done':
      statuses = ['completed', 'declined', 'cancelled'];
    default:
      statuses = [status];
  }

  // First, get all client IDs belonging to the current user
  final myClients = await client
      .from('clients')
      .select('id')
      .eq('manager_id', userId);
  final myClientIds =
      myClients.map((c) => c['id'] as String).toSet();

  if (myClientIds.isEmpty) return [];

  // Fetch matches where client_a OR client_b belongs to one of my clients
  final sentMatches = await client
      .from('matches')
      .select()
      .inFilter('client_a_id', myClientIds.toList())
      .inFilter('status', statuses)
      .order('matched_at', ascending: false)
      .limit(50);

  final receivedMatches = await client
      .from('matches')
      .select()
      .inFilter('client_b_id', myClientIds.toList())
      .inFilter('status', statuses)
      .order('matched_at', ascending: false)
      .limit(50);

  // Merge and deduplicate (a match could appear in both if both clients are mine)
  final matchMap = <String, Map<String, dynamic>>{};
  for (final m in sentMatches) {
    matchMap[m['id'] as String] = {...m, 'is_sender': true};
  }
  for (final m in receivedMatches) {
    final id = m['id'] as String;
    if (!matchMap.containsKey(id)) {
      matchMap[id] = {...m, 'is_sender': false};
    }
    // If already exists from sent, keep is_sender: true
  }

  final matches = matchMap.values.toList()
    ..sort((a, b) {
      final aTime = a['matched_at'] as String? ?? '';
      final bTime = b['matched_at'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

  // Fetch client details
  final clientIds = <String>{};
  for (final m in matches) {
    if (m['client_a_id'] != null) clientIds.add(m['client_a_id'] as String);
    if (m['client_b_id'] != null) clientIds.add(m['client_b_id'] as String);
  }

  final clientDetailMap = <String, Map<String, dynamic>>{};
  if (clientIds.isNotEmpty) {
    final clients = await client
        .from('clients')
        .select('id, full_name, gender, birth_date, manager_id')
        .inFilter('id', clientIds.toList());
    for (final c in clients) {
      clientDetailMap[c['id'] as String] = c;
    }
  }

  return matches.map((m) {
    final clientA = clientDetailMap[m['client_a_id']];
    final clientB = clientDetailMap[m['client_b_id']];

    // Determine which client is "mine" based on manager_id
    final isSender = m['is_sender'] as bool;
    final myClient = isSender ? clientA : clientB;
    final otherClient = isSender ? clientB : clientA;

    return {
      ...m,
      'client_a': clientA,
      'client_b': clientB,
      'my_client': myClient,
      'other_client': otherClient,
    };
  }).toList();
}

// ─── Match Detail (cached via Riverpod) ──────────────────────

@riverpod
Future<Map<String, dynamic>?> matchDetail(Ref ref, String matchId) async {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final matchRows = await client
      .from('matches')
      .select()
      .eq('id', matchId)
      .limit(1);

  if (matchRows.isEmpty) return null;
  final match = matchRows.first;

  final clientAId = match['client_a_id'] as String?;
  final clientBId = match['client_b_id'] as String?;
  final clientIds = [
    if (clientAId != null) clientAId,
    if (clientBId != null) clientBId,
  ];

  final clientMap = <String, Map<String, dynamic>>{};
  if (clientIds.isNotEmpty) {
    final clientRows =
        await client.from('clients').select().inFilter('id', clientIds);
    for (final c in clientRows) {
      clientMap[c['id'] as String] = c;
    }
  }

  final managerId = match['manager_id'] as String?;
  String? managerName;
  if (managerId != null) {
    final mgrRows = await client
        .from('managers')
        .select('full_name')
        .eq('id', managerId)
        .limit(1);
    if (mgrRows.isNotEmpty) {
      managerName = mgrRows.first['full_name'] as String?;
    }
  }

  String? conversationId;
  final convRows = await client
      .from('conversations')
      .select('id')
      .eq('match_id', matchId)
      .limit(1);
  if (convRows.isNotEmpty) {
    conversationId = convRows.first['id'] as String;
  }

  // Determine sender perspective
  final clientA = clientMap[clientAId];
  final isSender = clientA != null && clientA['manager_id'] == user.id;

  return {
    'match': match,
    'client_a': clientA,
    'client_b': clientMap[clientBId],
    'manager_name': managerName,
    'conversation_id': conversationId,
    'is_sender': isSender,
  };
}
