import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';

class MatchStatusChip extends StatelessWidget {
  const MatchStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final (color, label) = switch (status) {
      'pending' => (statusColors.pending, l10n.matchStatusPending),
      'accepted' => (statusColors.accepted, l10n.matchStatusAccepted),
      'declined' => (statusColors.declined, l10n.matchStatusDeclined),
      'meeting_scheduled' => (statusColors.accepted, l10n.matchStatusMeetingScheduled),
      'completed' => (statusColors.verified, l10n.matchStatusCompleted),
      _ => (statusColors.pending, status),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
