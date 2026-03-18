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
    this.deletedAt,
    this.deletedBy,
    this.replyToId,
    this.replyToContent,
    this.replyToSenderId,
    this.replyToType,
    this.replyToIsDeleted,
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

  // Soft delete
  final DateTime? deletedAt;
  final String? deletedBy;

  bool get isDeleted => deletedAt != null;

  // Reply/quote — stores sender ID, name is resolved in UI
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSenderId;
  final String? replyToType;
  final bool? replyToIsDeleted;

  ChatMessage copyWith({
    String? id,
    String? content,
    String? type,
    String? imageUrl,
    bool? isRead,
    DateTime? deletedAt,
    String? deletedBy,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
    String? replyToType,
    bool? replyToIsDeleted,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId,
      senderId: senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      isMine: isMine,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderId: replyToSenderId ?? this.replyToSenderId,
      replyToType: replyToType ?? this.replyToType,
      replyToIsDeleted: replyToIsDeleted ?? this.replyToIsDeleted,
    );
  }

  factory ChatMessage.fromMap(
    Map<String, dynamic> map, {
    required String currentUserId,
  }) {
    // Parse reply_to embedded resource (joined via Supabase select)
    final replyTo = map['reply_to'] as Map<String, dynamic>?;
    String? replyToSenderId;
    bool? replyToIsDeleted;
    String? replyToContent;
    String? replyToType;

    if (replyTo != null) {
      replyToIsDeleted = replyTo['deleted_at'] != null;
      replyToContent = replyTo['content'] as String?;
      replyToType = replyTo['type'] as String?;
      replyToSenderId = replyTo['sender_id'] as String?;
    }

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
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      deletedBy: map['deleted_by'] as String?,
      replyToId: map['reply_to_id'] as String?,
      replyToContent: replyToContent,
      replyToSenderId: replyToSenderId,
      replyToType: replyToType,
      replyToIsDeleted: replyToIsDeleted,
    );
  }
}
