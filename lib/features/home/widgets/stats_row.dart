import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.pendingMatches,
    required this.newMessages,
    required this.schedules,
    this.onPendingTap,
    this.onMessagesTap,
    this.onSchedulesTap,
  });

  final int pendingMatches;
  final int newMessages;
  final int schedules;
  final VoidCallback? onPendingTap;
  final VoidCallback? onMessagesTap;
  final VoidCallback? onSchedulesTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                count: pendingMatches,
                label: l10n.homeStatsPendingMatches,
                showBadge: pendingMatches > 0,
                onTap: onPendingTap,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatCard(
                count: newMessages,
                label: l10n.homeStatsNewMessages,
                onTap: onMessagesTap,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatCard(
                count: schedules,
                label: l10n.homeStatsSchedules,
                onTap: onSchedulesTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    this.showBadge = false,
    this.onTap,
  });

  final int count;
  final String label;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final statusColors = theme.extension<StatusColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: homeColors.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: homeColors.borderColor),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBadge) ...[
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: statusColors.declined,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: homeColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: homeColors.textPrimary.withValues(alpha: 0.45),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
