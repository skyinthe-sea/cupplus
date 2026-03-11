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
}
