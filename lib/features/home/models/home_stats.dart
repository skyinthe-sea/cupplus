import 'package:flutter/foundation.dart';

@immutable
class HomeStats {
  const HomeStats({
    required this.pendingMatches,
    required this.todayMatches,
    required this.pendingVerifications,
    required this.newMessages,
  });

  final int pendingMatches;
  final int todayMatches;
  final int pendingVerifications;
  final int newMessages;
}
