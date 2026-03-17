import 'package:flutter/foundation.dart';

enum ActivityType {
  matchRequested,
  matchReceivedRequest,
  matchAccepted,
  matchDeclined,
  matchCancelled,
  clientRegistered,
}

@immutable
class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.type,
    required this.timestamp,
    this.clientAName,
    this.clientBName,
    this.clientName,
    this.matchId,
    this.clientId,
  });

  final String id;
  final ActivityType type;
  final DateTime timestamp;
  final String? clientAName;
  final String? clientBName;
  final String? clientName;
  final String? matchId;
  final String? clientId;
}
