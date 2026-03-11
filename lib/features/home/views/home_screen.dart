import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../providers/home_dummy_data.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/profile_carousel.dart';
import '../widgets/status_dashboard.dart';
import '../widgets/tip_banner.dart';

String? _nonEmpty(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final managerProfile = ref.watch(managerProfileProvider);
    final clients = ref.watch(recommendedClientsProvider);
    final stats = ref.watch(homeStatsProvider);
    final tipText = ref.watch(homeTipTextProvider);

    final nickname = managerProfile.valueOrNull?['nickname'] as String?;
    final managerName = managerProfile.valueOrNull?['full_name'] as String?;
    final userName = _nonEmpty(nickname) ??
        _nonEmpty(managerName) ??
        _nonEmpty(user?.userMetadata?['full_name'] as String?) ??
        _nonEmpty(user?.email?.split('@').first) ??
        'User';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            const SliverToBoxAdapter(
              child: HomeAppBar(unreadCount: 3),
            ),

            // Greeting
            SliverToBoxAdapter(
              child: GreetingHeader(
                userName: userName,
                recommendedCount: clients.length,
              ),
            ),

            // Recommended Profiles Section
            SliverToBoxAdapter(
              child: SectionHeader(title: l10n.homeRecommendedTitle),
            ),
            SliverToBoxAdapter(
              child: ProfileCarousel(clients: clients),
            ),

            // Activity Status Section
            SliverToBoxAdapter(
              child: SectionHeader(title: l10n.homeStatusTitle),
            ),
            SliverToBoxAdapter(
              child: StatusDashboard(stats: stats),
            ),

            // Tip Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 24.h),
                child: TipBanner(tipText: tipText),
              ),
            ),

            // Bottom padding for floating nav bar
            SliverToBoxAdapter(
              child: SizedBox(height: 120.h),
            ),
          ],
        ),
      ),
    );
  }
}
