import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/marketplace_providers.dart';
import '../widgets/marketplace_filter_sheet.dart';
import '../widgets/marketplace_gender_tabs.dart';
import '../widgets/marketplace_header.dart';
import '../widgets/marketplace_list_view.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/marketplace_shimmer_card.dart';
import '../widgets/match_empty_state.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(marketplaceFilterNotifierProvider);
    final countsAsync = ref.watch(profileCountsProvider);

    final counts = countsAsync.valueOrNull ?? (all: 0, female: 0, male: 0, liked: 0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketplaceHeader(
              totalCount: counts.all,
              activeFilterCount: filter.activeFilterCount,
              onFilterTap: () => MarketplaceFilterSheet.show(context),
            ),
            MarketplaceSearchBar(
              onSearchChanged: (query) {
                ref
                    .read(marketplaceFilterNotifierProvider.notifier)
                    .updateSearchQuery(query);
              },
            ),
            MarketplaceGenderTabs(
              controller: _tabController,
              allCount: counts.all,
              femaleCount: counts.female,
              maleCount: counts.male,
              likesCount: counts.liked,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(l10n, null, 'all'),
                  _buildProfileTab(l10n, 'F', 'female'),
                  _buildProfileTab(l10n, 'M', 'male'),
                  _buildLikesTab(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(AppLocalizations l10n, String? genderFilter, String heroPrefix) {
    final profilesAsync = ref.watch(
      marketplaceProfileListProvider(genderOverride: genderFilter),
    );
    final notifier = ref.read(
      marketplaceProfileListProvider(genderOverride: genderFilter).notifier,
    );

    return profilesAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) {
          return MatchEmptyState(
            title: l10n.marketplaceEmptyTitle,
            subtitle: l10n.marketplaceEmptySubtitle,
          );
        }
        return MarketplaceListView(
          profiles: profiles,
          heroTagPrefix: heroPrefix,
          hasMore: notifier.hasMore,
          onLoadMore: notifier.loadMore,
          onRefresh: () async {
            ref.invalidate(
              marketplaceProfileListProvider(genderOverride: genderFilter),
            );
            ref.invalidate(profileCountsProvider);
          },
        );
      },
      loading: () => ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 120.h),
        itemCount: 5,
        itemBuilder: (_, __) => const MarketplaceShimmerCard(),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.commonError),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => ref.invalidate(
                marketplaceProfileListProvider(genderOverride: genderFilter),
              ),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikesTab(AppLocalizations l10n) {
    final likesAsync = ref.watch(likedProfilesProvider);

    return likesAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) {
          return MatchEmptyState(
            title: l10n.marketplaceEmptyTitle,
            subtitle: l10n.marketplaceEmptySubtitle,
          );
        }
        return MarketplaceListView(
          profiles: profiles,
          heroTagPrefix: 'liked',
          showDimForMatched: true,
          onRefresh: () async {
            ref.invalidate(likedProfilesProvider);
          },
        );
      },
      loading: () => ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 120.h),
        itemCount: 3,
        itemBuilder: (_, __) => const MarketplaceShimmerCard(),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.commonError),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => ref.invalidate(likedProfilesProvider),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
