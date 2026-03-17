import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';

class TodayTasks extends StatelessWidget {
  const TodayTasks({
    super.key,
    required this.pendingMatches,
    required this.newMessages,
    required this.onPendingMatchesTap,
    required this.onNewMessagesTap,
    this.upcomingSchedules = 0,
    this.onSchedulesTap,
  });

  final int pendingMatches;
  final int newMessages;
  final VoidCallback onPendingMatchesTap;
  final VoidCallback onNewMessagesTap;
  final int upcomingSchedules;
  final VoidCallback? onSchedulesTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final items = <Widget>[
      _TaskItem(
        icon: Icons.link_rounded,
        iconColor: Colors.amber.shade700,
        text: l10n.homeTodayPendingMatches(pendingMatches),
        actionLabel: l10n.homeTodayView,
        onTap: onPendingMatchesTap,
        muted: pendingMatches == 0,
      ),
      _TaskItem(
        icon: Icons.chat_bubble_rounded,
        iconColor: theme.colorScheme.primary,
        text: l10n.homeTodayNewMessages(newMessages),
        actionLabel: l10n.homeTodayView,
        onTap: onNewMessagesTap,
        muted: newMessages == 0,
      ),
      if (onSchedulesTap != null)
        _TaskItem(
          icon: Icons.calendar_today_rounded,
          iconColor: Colors.blue.shade600,
          text: l10n.homeTodaySchedules(upcomingSchedules),
          actionLabel: l10n.homeTodayView,
          onTap: onSchedulesTap!,
          muted: upcomingSchedules == 0,
        ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 10.h, top: 24.h),
            child: Text(
              l10n.homeTodayTasks,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...items.expand((item) sync* {
            if (item != items.first) yield SizedBox(height: 8.h);
            yield item;
          }),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.actionLabel,
    required this.onTap,
    this.muted = false,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final String actionLabel;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.55)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: (muted
                          ? theme.colorScheme.onSurfaceVariant
                          : iconColor)
                      .withValues(alpha: muted ? 0.08 : 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon,
                    size: 18.r,
                    color: muted
                        ? theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)
                        : iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: muted
                        ? theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5)
                        : null,
                  ),
                ),
              ),
              Text(
                actionLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted
                      ? theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3)
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 16.r,
                color: muted
                    ? theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3)
                    : theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
