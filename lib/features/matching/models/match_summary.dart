import 'package:flutter/foundation.dart';

import '../../../shared/models/client_summary.dart';

@immutable
class MatchSummary {
  const MatchSummary({
    required this.id,
    required this.clientA,
    required this.clientB,
    required this.status,
    required this.matchedAt,
    this.respondedAt,
    this.notes,
  });

  final String id;
  final ClientSummary clientA;
  final ClientSummary clientB;
  final String status;
  final DateTime matchedAt;
  final DateTime? respondedAt;
  final String? notes;
}
