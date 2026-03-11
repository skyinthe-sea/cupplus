import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/marketplace_providers.dart';
import '../widgets/marketplace_filter_sheet.dart';
import '../widgets/marketplace_gender_tabs.dart';
import '../widgets/marketplace_header.dart';
import '../widgets/marketplace_list_view.dart';
import '../widgets/marketplace_search_bar.dart';
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
    final allProfiles = ref.watch(filteredMarketplaceProfilesProvider);
    final femaleProfiles = ref.watch(femaleProfilesProvider);
    final maleProfiles = ref.watch(maleProfilesProvider);
    final filter = ref.watch(marketplaceFilterNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketplaceHeader(
              totalCount: allProfiles.length,
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
              allCount: allProfiles.length,
              femaleCount: femaleProfiles.length,
              maleCount: maleProfiles.length,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All tab
                  allProfiles.isEmpty
                      ? MatchEmptyState(
                          icon: Icons.person_search_rounded,
                          title: l10n.marketplaceEmptyTitle,
                          subtitle: l10n.marketplaceEmptySubtitle,
                        )
                      : MarketplaceListView(profiles: allProfiles),

                  // Female tab
                  femaleProfiles.isEmpty
                      ? MatchEmptyState(
                          icon: Icons.person_search_rounded,
                          title: l10n.marketplaceEmptyTitle,
                          subtitle: l10n.marketplaceEmptySubtitle,
                        )
                      : MarketplaceListView(profiles: femaleProfiles),

                  // Male tab
                  maleProfiles.isEmpty
                      ? MatchEmptyState(
                          icon: Icons.person_search_rounded,
                          title: l10n.marketplaceEmptyTitle,
                          subtitle: l10n.marketplaceEmptySubtitle,
                        )
                      : MarketplaceListView(profiles: maleProfiles),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
