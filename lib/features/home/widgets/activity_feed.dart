import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/activity_feed_item.dart';

final _timeFormat = DateFormat('HH:mm');

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({
    super.key,
    required this.items,
    this.onItemTap,
    this.onRegisterTap,
    this.onViewAll,
  });

  final List<ActivityFeedItem> items;
  final void Function(ActivityFeedItem item)? onItemTap;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
            child: Row(
              children: [
                Text(
                  l10n.homeRecentActivity,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: homeColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      l10n.homeActivityViewAll,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: homeColors.pointColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (items.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48.r,
                    color: homeColors.textPrimary.withValues(alpha: 0.15),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10n.homeActivityEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: homeColors.textPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: onRegisterTap,
                    child: Text(l10n.homeActivityEmptyAction),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...items.take(10).map((item) => _FeedItem(
                  item: item,
                  l10n: l10n,
                  onTap: () => onItemTap?.call(item),
                  homeColors: homeColors,
                  theme: theme,
                )),
          ],
        ],
      ),
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({
    required this.item,
    required this.l10n,
    required this.onTap,
    required this.homeColors,
    required this.theme,
  });

  final ActivityFeedItem item;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final HomeColors homeColors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isMatchType = item.type != ActivityType.clientRegistered;
    final statusColors = theme.extension<StatusColors>()!;

    final (text, statusText, statusColor) = switch (item.type) {
      ActivityType.matchRequested => (
          '${item.clientAName ?? '?'} ↔ ${item.clientBName ?? '?'}',
          l10n.matchStatusPending,
          statusColors.pending,
        ),
      ActivityType.matchReceivedRequest => (
          '${item.clientAName ?? '?'} ↔ ${item.clientBName ?? '?'}',
          l10n.matchStatusPending,
          statusColors.pending,
        ),
      ActivityType.matchAccepted => (
          '${item.clientAName ?? '?'} ↔ ${item.clientBName ?? '?'}',
          l10n.matchStatusAccepted,
          statusColors.accepted,
        ),
      ActivityType.matchDeclined => (
          '${item.clientAName ?? '?'} ↔ ${item.clientBName ?? '?'}',
          l10n.matchStatusDeclined,
          statusColors.declined,
        ),
      ActivityType.matchCancelled => (
          '${item.clientAName ?? '?'} ↔ ${item.clientBName ?? '?'}',
          l10n.matchStatusCancelled,
          statusColors.declined,
        ),
      ActivityType.clientRegistered => (
          l10n.homeActivityClientRegistered(item.clientName ?? '?'),
          '',
          Colors.transparent,
        ),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        child: Row(
          children: [
            // Avatar(s)
            if (isMatchType)
              _DoubleAvatar(
                nameA: item.clientAName ?? '?',
                nameB: item.clientBName ?? '?',
                colorA: homeColors.pointColor,
                colorB: theme.colorScheme.secondary,
              )
            else
              _SingleAvatar(
                name: item.clientName ?? '?',
                color: homeColors.pointColor,
              ),
            SizedBox(width: 12.w),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: homeColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (statusText.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Time + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _timeFormat.format(item.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: homeColors.textPrimary.withValues(alpha: 0.4),
                  ),
                ),
                if (statusText.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoubleAvatar extends StatelessWidget {
  const _DoubleAvatar({
    required this.nameA,
    required this.nameB,
    required this.colorA,
    required this.colorB,
  });

  final String nameA;
  final String nameB;
  final Color colorA;
  final Color colorB;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.r,
      height: 28.r,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 14.r,
              backgroundColor: colorA,
              child: Text(
                nameA.characters.first,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 14.r,
            child: CircleAvatar(
              radius: 14.r,
              backgroundColor: colorB,
              child: Text(
                nameB.characters.first,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleAvatar extends StatelessWidget {
  const _SingleAvatar({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14.r,
      backgroundColor: color,
      child: Text(
        name.characters.first,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
