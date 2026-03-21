import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/widgets/illustration_placeholder.dart';
import '../../../shared/models/client_summary.dart';
import '../providers/my_clients_provider.dart';

class MyClientsScreen extends ConsumerStatefulWidget {
  const MyClientsScreen({super.key});

  @override
  ConsumerState<MyClientsScreen> createState() => _MyClientsScreenState();
}

class _MyClientsScreenState extends ConsumerState<MyClientsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clientsAsync = ref.watch(myClientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myClientsTitle, style: TextStyle(fontFamily: serifFontFamily, fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: () => _navigateToRegister(context),
            icon: Icon(Icons.add, size: 18.r),
            label: Text(l10n.myClientsRegister),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.h),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.myClientsSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).extension<HomeColors>()!.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              // Status tabs
              clientsAsync.when(
                data: (clients) => _buildTabs(l10n, clients),
                loading: () => _buildTabs(l10n, []),
                error: (_, __) => _buildTabs(l10n, []),
              ),
            ],
          ),
        ),
      ),
      body: clientsAsync.when(
        data: (clients) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildClientList(clients, null, l10n),
              _buildClientList(clients, 'active', l10n),
              _buildClientList(clients, 'paused', l10n),
              _buildClientList(clients, 'matched', l10n),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.commonError),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => ref.invalidate(myClientsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(AppLocalizations l10n, List<ClientSummary> clients) {
    final allCount = clients.length;
    final activeCount =
        clients.where((c) => c.matchStatus == 'active').length;
    final pausedCount =
        clients.where((c) => c.matchStatus == 'paused').length;
    final matchedCount =
        clients.where((c) => c.matchStatus == 'matched').length;

    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: '${l10n.myClientsTabAll} $allCount'),
        Tab(text: '${l10n.myClientsTabActive} $activeCount'),
        Tab(text: '${l10n.myClientsTabPaused} $pausedCount'),
        Tab(text: '${l10n.myClientsTabMatched} $matchedCount'),
      ],
      isScrollable: true,
      tabAlignment: TabAlignment.start,
    );
  }

  Widget _buildClientList(
    List<ClientSummary> clients,
    String? statusFilter,
    AppLocalizations l10n,
  ) {
    var filtered = clients;
    if (statusFilter != null) {
      filtered = filtered
          .where((c) => c.matchStatus == statusFilter)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((c) => c.fullName.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myClientsProvider),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _ClientCard(
            client: filtered[index],
            onTap: () => context.push(AppRoutes.myClientDetail(filtered[index].id)),
            delay: index,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IllustrationImage(
            assetPath: 'assets/images/illustrations/empty_clients.png',
            width: 80.r,
            height: 80.r,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.myClientsEmpty,
            style: theme.textTheme.titleMedium?.copyWith(
              color: homeColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: () => _navigateToRegister(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.myClientsEmptyAction),
          ),
        ],
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    context.push(AppRoutes.clientRegistration);
  }
}

class _ClientCard extends StatefulWidget {
  const _ClientCard({
    required this.client,
    required this.onTap,
    required this.delay,
  });

  final ClientSummary client;
  final VoidCallback onTap;
  final int delay;

  @override
  State<_ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<_ClientCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final delay = Duration(milliseconds: widget.delay.clamp(0, 10) * 60);
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    Future.delayed(delay, () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final c = widget.client;

    final statusColor = switch (c.matchStatus) {
      'active' => Colors.green,
      'paused' => Colors.orange,
      'matched' => theme.colorScheme.primary,
      _ => Colors.grey,
    };

    final statusLabel = switch (c.matchStatus) {
      'active' => AppLocalizations.of(context)!.myClientDetailStatusActive,
      'paused' => AppLocalizations.of(context)!.myClientDetailStatusPaused,
      'matched' => AppLocalizations.of(context)!.myClientDetailStatusMatched,
      _ => c.matchStatus ?? '',
    };

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Card(
          margin: EdgeInsets.only(bottom: 8.h),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: homeColors.borderColor,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor:
                        homeColors.pointColor.withValues(alpha: 0.1),
                    backgroundImage: c.profilePhotoUrl != null
                        ? NetworkImage(c.profilePhotoUrl!)
                        : null,
                    child: c.profilePhotoUrl == null
                        ? Text(
                            c.fullName.isNotEmpty ? c.fullName[0] : '?',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: homeColors.pointColor,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              c.fullName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${c.age}세 · ${c.gender == 'M' ? '남' : '여'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          [
                            if (c.occupation.isNotEmpty) c.occupation,
                            if (c.company != null) c.company,
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
