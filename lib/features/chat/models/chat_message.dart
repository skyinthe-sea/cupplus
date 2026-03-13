import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    this.imageUrl,
    required this.isRead,
    required this.createdAt,
    required this.isMine,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type; // 'text' | 'image' | 'file'
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;
  final bool isMine;

  factory ChatMessage.fromMap(
    Map<String, dynamic> map, {
    required String currentUserId,
  }) {
    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String? ?? '',
      type: map['type'] as String? ?? 'text',
      imageUrl: map['image_url'] as String?,
      isRead: map['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      isMine: map['sender_id'] == currentUserId,
    );
  }
}
