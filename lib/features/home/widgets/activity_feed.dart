import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../models/activity_feed_item.dart';

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({
    super.key,
    required this.items,
    this.onItemTap,
    this.onRegisterTap,
  });

  final List<ActivityFeedItem> items;
  final void Function(ActivityFeedItem item)? onItemTap;
  final VoidCallback? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48.r,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.homeActivityEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: onRegisterTap,
              child: Text(l10n.homeActivityEmptyAction),
            ),
          ],
        ),
      );
    }

    // Group items by date
    final grouped = _groupByDate(items, l10n);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 8.h, left: 4.w),
              child: Text(
                entry.key,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...entry.value.map((item) => _FeedItem(
                  item: item,
                  l10n: l10n,
                  onTap: () => onItemTap?.call(item),
                )),
          ],
        ],
      ),
    );
  }

  Map<String, List<ActivityFeedItem>> _groupByDate(
    List<ActivityFeedItem> items,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateFormat = DateFormat('M/d');

    final grouped = <String, List<ActivityFeedItem>>{};
    for (final item in items) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );

      final String label;
      if (itemDate == today) {
        label = l10n.homeActivityToday;
      } else if (itemDate == yesterday) {
        label = l10n.homeActivityYesterday;
      } else {
        label = dateFormat.format(item.timestamp);
      }

      grouped.putIfAbsent(label, () => []).add(item);
    }
    return grouped;
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({
    required this.item,
    required this.l10n,
    required this.onTap,
  });

  final ActivityFeedItem item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    final (icon, color, text) = switch (item.type) {
      ActivityType.matchRequested => (
          Icons.send_rounded,
          Colors.amber.shade700,
          l10n.homeActivityMatchRequested(
              item.clientAName ?? '?', item.clientBName ?? '?'),
        ),
      ActivityType.matchReceivedRequest => (
          Icons.call_received_rounded,
          Colors.amber.shade700,
          l10n.homeActivityMatchReceived(
              item.clientAName ?? '?', item.clientBName ?? '?'),
        ),
      ActivityType.matchAccepted => (
          Icons.favorite_rounded,
          const Color(0xFF2E7D32),
          l10n.homeActivityMatchAccepted(
              item.clientAName ?? '?', item.clientBName ?? '?'),
        ),
      ActivityType.matchDeclined => (
          Icons.cancel_rounded,
          const Color(0xFFC62828),
          l10n.homeActivityMatchDeclined(
              item.clientAName ?? '?', item.clientBName ?? '?'),
        ),
      ActivityType.matchCancelled => (
          Icons.cancel_rounded,
          const Color(0xFFC62828),
          l10n.homeActivityMatchCancelled(
              item.clientAName ?? '?', item.clientBName ?? '?'),
        ),
      ActivityType.clientRegistered => (
          Icons.person_add_rounded,
          theme.colorScheme.primary,
          l10n.homeActivityClientRegistered(item.clientName ?? '?'),
        ),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, size: 15.r, color: color),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              timeFormat.format(item.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
