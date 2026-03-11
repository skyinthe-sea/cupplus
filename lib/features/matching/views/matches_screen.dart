import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/matches_dummy_data.dart';
import '../widgets/match_empty_state.dart';
import '../widgets/match_list_view.dart';
import '../widgets/matches_header.dart';
import '../widgets/matches_tab_bar.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
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
    final allMatches = ref.watch(allMatchesProvider);
    final pending = ref.watch(pendingMatchesProvider);
    final active = ref.watch(activeMatchesProvider);
    final done = ref.watch(doneMatchesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MatchesHeader(totalCount: allMatches.length),
            MatchesTabBar(
              controller: _tabController,
              pendingCount: pending.length,
              activeCount: active.length,
              doneCount: done.length,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pending tab
                  pending.isEmpty
                      ? MatchEmptyState(
                          icon: Icons.hourglass_empty_rounded,
                          title: l10n.matchesEmptyPendingTitle,
                          subtitle: l10n.matchesEmptyPendingSubtitle,
                        )
                      : MatchListView(matches: pending),

                  // Active tab
                  active.isEmpty
                      ? MatchEmptyState(
                          icon: Icons.handshake_outlined,
                          title: l10n.matchesEmptyActiveTitle,
                          subtitle: l10n.matchesEmptyActiveSubtitle,
                        )
                      : MatchListView(matches: active),

                  // Done tab
                  done.isEmpty
                      ? MatchEmptyState(
                          icon: Icons.archive_outlined,
                          title: l10n.matchesEmptyDoneTitle,
                          subtitle: l10n.matchesEmptyDoneSubtitle,
                        )
                      : MatchListView(matches: done),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Placeholder for match creation
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.matchCreate),
        ),
      ),
    );
  }
}
