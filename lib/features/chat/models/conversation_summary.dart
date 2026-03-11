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
}
