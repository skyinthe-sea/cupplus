import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../../../shared/models/client_summary.dart';
import '../models/activity_feed_item.dart';

part 'home_providers.g.dart';

DateTime _parseDateTime(dynamic value) {
  if (value is String) return DateTime.parse(value);
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
}) async* {
  // Initial fetch
  yield await fetcher();

  // Subscribe to Realtime changes on all specified tables
  final controller = StreamController<void>.broadcast();
  var ch = client.channel(channelName);
  for (final table in tables) {
    ch = ch.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      callback: (_) {
        if (!controller.isClosed) controller.add(null);
      },
    );
  }

  ref.onDispose(() {
    controller.close();
    client.removeChannel(ch);
  });

  ch.subscribe();

  await for (final _ in controller.stream) {
    yield await fetcher();
  }
}

// ─── Today Stats (Realtime) ──────────────────────────────────

@riverpod
Stream<({int pendingMatches, int newMessages})> homeTodayStats(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) {
    return Stream.value((pendingMatches: 0, newMessages: 0));
  }

  return _realtimeStream(
    ref: ref,
    client: client,
    channelName: 'home-stats-rt',
    tables: ['matches', 'messages'],
    fetcher: () async {
      final pendingResult = await client
          .from('matches')
          .select('id')
          .eq('manager_id', user.id)
          .eq('status', 'pending');

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
  final user = client.auth.currentUser;
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
          .eq('is_read', false);
      return result.length;
    },
  );
}

// ─── Notifications List (Realtime) ───────────────────────────

@riverpod
Stream<List<Map<String, dynamic>>> notificationsList(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
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
  final user = client.auth.currentUser;
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

  final matches = await client
      .from('matches')
      .select()
      .eq('manager_id', userId)
      .gte('matched_at', sevenDaysAgo)
      .order('matched_at', ascending: false)
      .limit(20);

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

    items.add(ActivityFeedItem(
      id: '${match['id']}_created',
      type: ActivityType.matchCreated,
      timestamp: matchedAt,
      clientAName: clientAName,
      clientBName: clientBName,
      matchId: match['id'] as String,
    ));

    final respondedAt = match['responded_at'] as String?;
    if (respondedAt != null &&
        (status == 'accepted' || status == 'declined')) {
      items.add(ActivityFeedItem(
        id: '${match['id']}_$status',
        type: status == 'accepted'
            ? ActivityType.matchAccepted
            : ActivityType.matchDeclined,
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
  final user = client.auth.currentUser;
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
  final user = client.auth.currentUser;
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
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
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
      statuses = ['completed', 'declined'];
    default:
      statuses = [status];
  }

  final matches = await client
      .from('matches')
      .select()
      .eq('manager_id', userId)
      .inFilter('status', statuses)
      .order('matched_at', ascending: false)
      .limit(50);

  final clientIds = <String>{};
  for (final m in matches) {
    if (m['client_a_id'] != null) clientIds.add(m['client_a_id'] as String);
    if (m['client_b_id'] != null) clientIds.add(m['client_b_id'] as String);
  }

  final clientMap = <String, Map<String, dynamic>>{};
  if (clientIds.isNotEmpty) {
    final clients = await client
        .from('clients')
        .select('id, full_name, gender, birth_date')
        .inFilter('id', clientIds.toList());
    for (final c in clients) {
      clientMap[c['id'] as String] = c;
    }
  }

  return matches.map((m) {
    return {
      ...m,
      'client_a': clientMap[m['client_a_id']],
      'client_b': clientMap[m['client_b_id']],
    };
  }).toList();
}
