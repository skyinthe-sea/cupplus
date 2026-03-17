import 'package:flutter/foundation.dart';

@immutable
class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatarUrl,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.isOnline,
    this.matchId,
    this.matchContext,
  });

  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatarUrl;
  final String lastMessage;
  final String lastMessageType; // 'text' | 'image' | 'file'
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isOnline;
  final String? matchId;
  final String? matchContext; // "회원A ↔ 회원B"

  ConversationSummary copyWith({
    String? lastMessage,
    String? lastMessageType,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ConversationSummary(
      id: id,
      participantId: participantId,
      participantName: participantName,
      participantAvatarUrl: participantAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      matchId: matchId,
      matchContext: matchContext,
    );
  }

  factory ConversationSummary.fromMap(
    Map<String, dynamic> map, {
    required String currentUserId,
    required String participantName,
    String? matchContext,
    int unreadCount = 0,
  }) {
    final isParticipantA = map['participant_a'] == currentUserId;
    final participantId = isParticipantA
        ? map['participant_b'] as String
        : map['participant_a'] as String;

    final lastMessageAt = map['last_message_at'] != null
        ? DateTime.parse(map['last_message_at'] as String)
        : DateTime.now();

    return ConversationSummary(
      id: map['id'] as String,
      participantId: participantId,
      participantName: participantName,
      lastMessage: map['last_message'] as String? ?? '',
      lastMessageType: map['last_message_type'] as String? ?? 'text',
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
      isOnline: false,
      matchId: map['match_id'] as String?,
      matchContext: matchContext,
    );
  }
}
