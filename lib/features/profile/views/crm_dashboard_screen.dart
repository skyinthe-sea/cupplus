import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/crm_stats_provider.dart';

class CrmDashboardScreen extends ConsumerWidget {
  const CrmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statsAsync = ref.watch(crmStatsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.crmDashboardTitle, style: TextStyle(fontFamily: serifFontFamily, fontWeight: FontWeight.w700))),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(crmStatsProvider),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            children: [
              // This month summary
              Text(
                l10n.crmThisMonth,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: serifFontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.person_add_rounded,
                      label: l10n.crmNewRegistrations,
                      value: '${stats.thisMonthRegistrations}',
                      color: const Color(0xFF43A047),
                      theme: theme,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite_rounded,
                      label: l10n.crmNewMatches,
                      value: '${stats.thisMonthMatches}',
                      color: const Color(0xFFE53935),
                      theme: theme,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.note_alt_rounded,
                      label: l10n.crmTotalNotes,
                      value: '${stats.totalNotes}',
                      color: const Color(0xFF1E88E5),
                      theme: theme,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Client overview
              Text(
                l10n.crmClientOverview,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: serifFontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  side: BorderSide(
                    color: theme.extension<HomeColors>()!.borderColor,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      // Total clients with status breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${stats.totalClients}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.crmTotalClients,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Status bars
                      if (stats.totalClients > 0) ...[
                        _StatusBar(stats: stats, theme: theme),
                        SizedBox(height: 12.h),
                      ],

                      // Status legend
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 12.w,
                        runSpacing: 6.h,
                        children: [
                          _LegendItem(
                            color: Colors.green,
                            label: l10n.myClientDetailStatusActive,
                            count: stats.activeClients,
                            theme: theme,
                          ),
                          _LegendItem(
                            color: Colors.orange,
                            label: l10n.myClientDetailStatusPaused,
                            count: stats.pausedClients,
                            theme: theme,
                          ),
                          _LegendItem(
                            color: theme.colorScheme.primary,
                            label: l10n.myClientDetailStatusMatched,
                            count: stats.matchedClients,
                            theme: theme,
                          ),
                          if (stats.totalClients - stats.activeClients - stats.pausedClients - stats.matchedClients > 0)
                            _LegendItem(
                              color: Colors.grey.shade400,
                              label: l10n.crmOtherStatus,
                              count: stats.totalClients - stats.activeClients - stats.pausedClients - stats.matchedClients,
                              theme: theme,
                            ),
                        ],
                      ),

                      SizedBox(height: 16.h),
                      Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      SizedBox(height: 16.h),

                      // Gender & age
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoChip(
                            icon: Icons.male_rounded,
                            label: l10n.commonMale,
                            value: '${stats.maleClients}',
                            theme: theme,
                          ),
                          _InfoChip(
                            icon: Icons.female_rounded,
                            label: l10n.commonFemale,
                            value: '${stats.femaleClients}',
                            theme: theme,
                          ),
                          _InfoChip(
                            icon: Icons.cake_rounded,
                            label: l10n.crmAvgAge,
                            value: stats.avgAge > 0 ? '${stats.avgAge.toStringAsFixed(1)}${l10n.homeAgeSuffix(stats.avgAge.round()).replaceAll(RegExp(r'[0-9]+'), '').trim()}' : '-',
                            theme: theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Matching performance
              Text(
                l10n.crmMatchPerformance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: serifFontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _PerformanceCard(
                      label: l10n.crmSuccessRate,
                      value: '${stats.matchSuccessRate.toStringAsFixed(1)}%',
                      subValue: '${stats.acceptedMatches}/${stats.totalMatches}',
                      color: const Color(0xFF43A047),
                      theme: theme,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _PerformanceCard(
                      label: l10n.crmDeclineRate,
                      value: '${stats.matchDeclineRate.toStringAsFixed(1)}%',
                      subValue: '${stats.declinedMatches}/${stats.totalMatches}',
                      color: const Color(0xFFE53935),
                      theme: theme,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _PerformanceCard(
                      label: l10n.crmPendingMatches,
                      value: '${stats.pendingMatches}',
                      subValue: l10n.crmWaitingResponse,
                      color: Colors.amber,
                      theme: theme,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _PerformanceCard(
                      label: l10n.crmTotalMatchesLabel,
                      value: '${stats.totalMatches}',
                      subValue: l10n.crmAllTime,
                      color: theme.colorScheme.primary,
                      theme: theme,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonError)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.stats, required this.theme});
  final CrmStats stats;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalClients;
    if (total == 0) return const SizedBox.shrink();

    final other = total - stats.activeClients - stats.pausedClients - stats.matchedClients;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: SizedBox(
        height: 8.h,
        child: Row(
          children: [
            if (stats.activeClients > 0)
              Expanded(
                flex: stats.activeClients,
                child: Container(color: Colors.green),
              ),
            if (stats.pausedClients > 0)
              Expanded(
                flex: stats.pausedClients,
                child: Container(color: Colors.orange),
              ),
            if (stats.matchedClients > 0)
              Expanded(
                flex: stats.matchedClients,
                child: Container(color: theme.colorScheme.primary),
              ),
            if (other > 0)
              Expanded(
                flex: other,
                child: Container(color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
    required this.theme,
  });

  final Color color;
  final String label;
  final int count;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '$label $count',
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20.r, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final String subValue;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).extension<HomeColors>()!.borderColor,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subValue,
              style: TextStyle(
                fontSize: 11.sp,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
