import 'package:flutter/foundation.dart';

@immutable
class ClientNote {
  const ClientNote({
    required this.id,
    required this.clientId,
    required this.managerId,
    required this.regionId,
    this.noteType = 'general',
    required this.content,
    this.scheduledAt,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientNote.fromMap(Map<String, dynamic> row) {
    return ClientNote(
      id: row['id'] as String,
      clientId: row['client_id'] as String,
      managerId: row['manager_id'] as String,
      regionId: row['region_id'] as String,
      noteType: row['note_type'] as String? ?? 'general',
      content: row['content'] as String,
      scheduledAt: row['scheduled_at'] != null
          ? DateTime.tryParse(row['scheduled_at'] as String)
          : null,
      isCompleted: (row['is_completed'] as bool?) ?? false,
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'] as String)
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.tryParse(row['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String clientId;
  final String managerId;
  final String regionId;
  final String noteType;
  final String content;
  final DateTime? scheduledAt;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
