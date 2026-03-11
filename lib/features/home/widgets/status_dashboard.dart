import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../models/home_stats.dart';
import 'status_card.dart';

class StatusDashboard extends StatelessWidget {
  const StatusDashboard({super.key, required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatusCard(
                  icon: Icons.link_rounded,
                  label: l10n.homePendingMatches,
                  count: stats.pendingMatches,
                  tintColor: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: StatusCard(
                  icon: Icons.favorite_rounded,
                  label: l10n.homeTodayMatches,
                  count: stats.todayMatches,
                  tintColor: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: StatusCard(
                  icon: Icons.description_rounded,
                  label: l10n.homePendingVerifications,
                  count: stats.pendingVerifications,
                  tintColor: theme.colorScheme.secondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: StatusCard(
                  icon: Icons.chat_bubble_rounded,
                  label: l10n.homeNewMessages,
                  count: stats.newMessages,
                  tintColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
