import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../models/match_summary.dart';
import 'client_mini_profile.dart';
import 'match_status_chip.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match});

  final MatchSummary match;

  IconData get _statusIcon => switch (match.status) {
        'pending' => Icons.link_rounded,
        'accepted' => Icons.check_circle_rounded,
        'meeting_scheduled' => Icons.calendar_month_rounded,
        'declined' => Icons.link_off_rounded,
        'completed' => Icons.done_all_rounded,
        _ => Icons.link_rounded,
      };

  Color _statusIconColor(StatusColors statusColors) => switch (match.status) {
        'pending' => statusColors.pending,
        'accepted' => statusColors.accepted,
        'meeting_scheduled' => statusColors.accepted,
        'declined' => statusColors.declined,
        'completed' => statusColors.verified,
        _ => statusColors.pending,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColors = theme.extension<StatusColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.55)
                  : theme.colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.45),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Client A ↔ Status Icon ↔ Client B
                Row(
                  children: [
                    Expanded(
                      child: ClientMiniProfile(client: match.clientA),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: _statusIconColor(statusColors)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _statusIcon,
                          size: 20.r,
                          color: _statusIconColor(statusColors),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClientMiniProfile(client: match.clientB),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                  ),
                ),

                // Bottom row: status chip + date + notes icon
                Row(
                  children: [
                    MatchStatusChip(status: match.status),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13.r,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(match.matchedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                    if (match.notes != null) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 14.r,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.6),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('M/d').format(date);
    }
  }
}
