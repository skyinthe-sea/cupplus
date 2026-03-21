import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/supabase_config.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/widgets/illustration_placeholder.dart';
import '../../home/providers/home_providers.dart';

class MatchHistoryScreen extends ConsumerStatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  ConsumerState<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends ConsumerState<MatchHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myMatchHistory, style: TextStyle(fontFamily: serifFontFamily, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.matchesTabPending),
            Tab(text: l10n.matchesTabActive),
            Tab(text: l10n.matchesTabDone),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MatchHistoryTab(status: 'pending'),
          _MatchHistoryTab(status: 'active'),
          _MatchHistoryTab(status: 'done'),
        ],
      ),
    );
  }
}

class _MatchHistoryTab extends ConsumerWidget {
  const _MatchHistoryTab({required this.status});

  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final matchesAsync = ref.watch(matchesByStatusProvider(status));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IllustrationImage(
                  assetPath: 'assets/images/illustrations/empty_match_history.png',
                  width: 56.r,
                  height: 56.r,
                ),
                SizedBox(height: 12.h),
                Text(
                  status == 'pending'
                      ? l10n.matchesEmptyPendingTitle
                      : status == 'active'
                          ? l10n.matchesEmptyActiveTitle
                          : l10n.matchesEmptyDoneTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  status == 'pending'
                      ? l10n.matchesEmptyPendingSubtitle
                      : status == 'active'
                          ? l10n.matchesEmptyActiveSubtitle
                          : l10n.matchesEmptyDoneSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(matchesByStatusProvider(status));
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return _MatchHistoryCard(match: match);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.commonError)),
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  const _MatchHistoryCard({required this.match});

  final Map<String, dynamic> match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final clientA = match['client_a'] as Map<String, dynamic>?;
    final clientB = match['client_b'] as Map<String, dynamic>?;
    final clientAName = clientA?['full_name'] as String? ?? '?';
    final clientBName = clientB?['full_name'] as String? ?? '?';
    final status = match['status'] as String? ?? 'pending';
    final matchedAt = match['matched_at'] as String?;
    final matchId = match['id'] as String;

    String dateText = '';
    if (matchedAt != null) {
      dateText = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(matchedAt));
    }

    final (statusText, statusColor) = switch (status) {
      'pending' => (l10n.matchStatusPending, Colors.amber.shade700),
      'accepted' => (l10n.matchStatusAccepted, Colors.green.shade600),
      'declined' => (l10n.matchStatusDeclined, theme.colorScheme.error),
      'meeting_scheduled' => (
        l10n.matchStatusMeetingScheduled,
        theme.colorScheme.primary
      ),
      'completed' => (l10n.matchStatusCompleted, theme.colorScheme.secondary),
      _ => (status, theme.colorScheme.onSurfaceVariant),
    };

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: theme.extension<HomeColors>()!.borderColor,
        ),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.matchDetail(matchId)),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$clientAName ↔ $clientBName',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dateText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
