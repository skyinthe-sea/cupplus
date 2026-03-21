import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/supabase_config.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../providers/home_providers.dart';
import '../widgets/activity_feed.dart';
import '../../../config/routes.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/landing_home.dart';
import '../widgets/match_creation_sheet.dart';
import '../widgets/match_management_sheet.dart';
import '../widgets/pending_match_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/stats_row.dart';

String? _nonEmpty(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final user = ref.watch(currentUserProvider);

    // Show landing page when not logged in
    if (user == null) return const LandingHome();

    final managerProfile = ref.watch(managerProfileProvider);
    final statsAsync = ref.watch(homeTodayStatsProvider);
    final scheduleCount =
        ref.watch(upcomingScheduleCountProvider).valueOrNull ?? 0;
    final feedAsync = ref.watch(activityFeedProvider);

    final nickname = managerProfile.valueOrNull?['nickname'] as String?;
    final managerName = managerProfile.valueOrNull?['full_name'] as String?;
    final userName = _nonEmpty(nickname) ??
        _nonEmpty(managerName) ??
        _nonEmpty(user.userMetadata?['full_name'] as String?) ??
        _nonEmpty(user.email?.split('@').first) ??
        'User';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeTodayStatsProvider);
            ref.invalidate(activityFeedProvider);
            ref.invalidate(unreadNotificationCountProvider);
          },
          child: CustomScrollView(
            slivers: [
              // 1. AppBar
              SliverToBoxAdapter(
                child: HomeAppBar(userName: userName),
              ),

              // 2. Greeting Header
              SliverToBoxAdapter(
                child: GreetingHeader(userName: userName),
              ),

              // 3. Pending Match Hero Card
              SliverToBoxAdapter(
                child: statsAsync.when(
                  data: (stats) => PendingMatchCard(
                    pendingCount: stats.pendingMatches,
                    onTap: stats.pendingMatches > 0
                        ? () => _showMatchManagement(context)
                        : () => context.go(AppRoutes.matches),
                  ),
                  loading: () => PendingMatchCard(
                    pendingCount: 0,
                    onTap: () => context.go(AppRoutes.matches),
                  ),
                  error: (_, __) => PendingMatchCard(
                    pendingCount: 0,
                    onTap: () => context.go(AppRoutes.matches),
                  ),
                ),
              ),

              // 4. Stats Row
              SliverToBoxAdapter(
                child: statsAsync.when(
                  data: (stats) {
                    return StatsRow(
                      pendingMatches: stats.pendingMatches,
                      newMessages: stats.newMessages,
                      schedules: scheduleCount,
                      onPendingTap: () => _showMatchManagement(context),
                      onMessagesTap: () => context.go(AppRoutes.chat),
                      onSchedulesTap: () => context.push(AppRoutes.myClients),
                    );
                  },
                  loading: () => const StatsRow(
                    pendingMatches: 0,
                    newMessages: 0,
                    schedules: 0,
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // 5. Quick Actions
              SliverToBoxAdapter(
                child: QuickActions(
                  onRegisterClient: () => _showClientRegistration(context),
                  onCreateMatch: () => _showMatchCreation(context),
                ),
              ),

              // 6. Activity Feed
              SliverToBoxAdapter(
                child: feedAsync.when(
                  data: (items) => ActivityFeed(
                    items: items,
                    onItemTap: (item) {
                      if (item.matchId != null) {
                        context.push(AppRoutes.matchDetail(item.matchId!));
                      } else if (item.clientId != null) {
                        context.push(AppRoutes.profileDetail(item.clientId!));
                      }
                    },
                    onRegisterTap: () => _showClientRegistration(context),
                  ),
                  loading: () => Padding(
                    padding: EdgeInsets.all(24.r),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Center(
                      child: Text(
                        l10n.commonError,
                        style: TextStyle(
                          color: homeColors.textPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 7. Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 120.h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClientRegistration(BuildContext context) {
    context.push(AppRoutes.clientRegistration);
  }

  void _showMatchCreation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const MatchCreationSheet(),
    );
  }

  void _showMatchManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const MatchManagementSheet(),
    );
  }
}
