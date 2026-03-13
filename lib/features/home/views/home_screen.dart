import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../providers/home_providers.dart';
import '../widgets/activity_feed.dart';
import '../../../config/routes.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/match_creation_sheet.dart';
import '../widgets/match_management_sheet.dart';
import '../widgets/quick_actions.dart';
import '../widgets/today_tasks.dart';

String? _nonEmpty(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final managerProfile = ref.watch(managerProfileProvider);
    final statsAsync = ref.watch(homeTodayStatsProvider);
    final feedAsync = ref.watch(activityFeedProvider);

    final nickname = managerProfile.valueOrNull?['nickname'] as String?;
    final managerName = managerProfile.valueOrNull?['full_name'] as String?;
    final userName = _nonEmpty(nickname) ??
        _nonEmpty(managerName) ??
        _nonEmpty(user?.userMetadata?['full_name'] as String?) ??
        _nonEmpty(user?.email?.split('@').first) ??
        'User';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeTodayStatsProvider);
            ref.invalidate(activityFeedProvider);
            ref.invalidate(unreadNotificationCountProvider);
          },
          child: CustomScrollView(
            slivers: [
              // 1-1. AppBar
              const SliverToBoxAdapter(
                child: HomeAppBar(),
              ),

              // 1-2. Greeting Header (time-based)
              SliverToBoxAdapter(
                child: GreetingHeader(userName: userName),
              ),

              // 1-3. Quick Actions
              SliverToBoxAdapter(
                child: QuickActions(
                  onRegisterClient: () => _showClientRegistration(context),
                  onCreateMatch: () => _showMatchCreation(context),
                ),
              ),

              // 1-4. Today's Tasks
              SliverToBoxAdapter(
                child: statsAsync.when(
                  data: (stats) {
                    final scheduleCount = ref.watch(upcomingScheduleCountProvider).valueOrNull ?? 0;
                    return TodayTasks(
                      pendingMatches: stats.pendingMatches,
                      newMessages: stats.newMessages,
                      onPendingMatchesTap: () =>
                          _showMatchManagement(context),
                      onNewMessagesTap: () => context.go(AppRoutes.chat),
                      upcomingSchedules: scheduleCount,
                      onSchedulesTap: () => context.go(AppRoutes.myClients),
                    );
                  },
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
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // 1-5. Activity Feed Header
              SliverToBoxAdapter(
                child: SectionHeader(title: l10n.homeRecentActivity),
              ),

              // 1-5. Activity Feed Content
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
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom padding for floating nav bar
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const MatchManagementSheet(),
    );
  }
}
