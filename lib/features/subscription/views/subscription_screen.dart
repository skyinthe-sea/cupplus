import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../config/constants.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tierAsync = ref.watch(currentSubscriptionTierProvider);
    final usageAsync = ref.watch(todayMatchUsageProvider);
    final clientCountAsync = ref.watch(myActiveClientCountProvider);
    final packagesAsync = ref.watch(availablePackagesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptionTitle)),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        children: [
          // Current plan card
          tierAsync.when(
            data: (tier) => _CurrentPlanCard(
              tier: tier,
              usageAsync: usageAsync,
              clientCountAsync: clientCountAsync,
              l10n: l10n,
              theme: theme,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _FallbackPlanCard(l10n: l10n, theme: theme),
          ),

          SizedBox(height: 24.h),

          // Plan comparison
          Text(
            l10n.subscriptionChangePlan,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),

          _PlanCard(
            tier: SubscriptionTier.free,
            title: l10n.subscriptionFree,
            desc: l10n.subscriptionFreePlanDesc,
            matchLimit: '${AppConstants.freeMatchDailyLimit}${l10n.profileDetailMatchRequestUnit}/일',
            clientLimit: AppConstants.freeClientLimit,
            color: theme.colorScheme.outline,
            currentTier: tierAsync.valueOrNull ?? SubscriptionTier.free,
            theme: theme,
            l10n: l10n,
          ),
          SizedBox(height: 8.h),
          _PlanCard(
            tier: SubscriptionTier.silver,
            title: l10n.subscriptionSilver,
            desc: l10n.subscriptionSilverPlanDesc,
            matchLimit: '${AppConstants.silverMatchDailyLimit}${l10n.profileDetailMatchRequestUnit}/일',
            clientLimit: AppConstants.silverClientLimit,
            price: '7,700',
            originalPrice: '23,100',
            color: const Color(0xFF7B5EA7),
            currentTier: tierAsync.valueOrNull ?? SubscriptionTier.free,
            theme: theme,
            l10n: l10n,
            onUpgrade: () => _handleUpgrade(context, ref, packagesAsync, 'silver'),
          ),
          SizedBox(height: 8.h),
          _PlanCard(
            tier: SubscriptionTier.gold,
            title: l10n.subscriptionGold,
            desc: l10n.subscriptionGoldPlanDesc,
            matchLimit: '${AppConstants.goldMatchDailyLimit}${l10n.profileDetailMatchRequestUnit}/일',
            clientLimit: AppConstants.goldClientLimit,
            price: '14,900',
            originalPrice: '44,700',
            color: const Color(0xFFD4A017),
            currentTier: tierAsync.valueOrNull ?? SubscriptionTier.free,
            theme: theme,
            l10n: l10n,
            onUpgrade: () => _handleUpgrade(context, ref, packagesAsync, 'gold'),
          ),

          SizedBox(height: 24.h),

          // Restore purchases
          Center(
            child: TextButton(
              onPressed: () => _restorePurchases(context, ref, l10n),
              child: Text(l10n.subscriptionRestoreTitle),
            ),
          ),

          // Dev mode tier switcher (debug only)
          if (kDebugMode) ...[
            SizedBox(height: 24.h),
            _DevModeTierSwitcher(l10n: l10n, theme: theme),
          ],

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Future<void> _handleUpgrade(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Package>> packagesAsync,
    String targetEntitlement,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final packages = packagesAsync.valueOrNull ?? [];

    if (packages.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subscriptionNotConfigured)),
        );
      }
      return;
    }

    final pkg = packages.firstWhere(
      (p) => p.identifier.toLowerCase().contains(targetEntitlement),
      orElse: () => packages.first,
    );

    final success = await ref.read(purchasePackageProvider(pkg).future);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.subscriptionChangePlan} ✓')),
        );
      }
    }
  }

  Future<void> _restorePurchases(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final restored = await ref.read(restorePurchasesProvider.future);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored
                ? l10n.subscriptionRestoreSuccess
                : l10n.subscriptionRestoreFailed,
          ),
        ),
      );
    }
  }
}

// ─── Current Plan Card ──────────────────────────────────────────────────

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.tier,
    required this.usageAsync,
    required this.clientCountAsync,
    required this.l10n,
    required this.theme,
  });

  final SubscriptionTier tier;
  final AsyncValue<int> usageAsync;
  final AsyncValue<int> clientCountAsync;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (planName, planColor, matchLimit, clientLimit) = switch (tier) {
      SubscriptionTier.free => (
          l10n.subscriptionFree,
          theme.colorScheme.outline,
          AppConstants.freeMatchDailyLimit,
          AppConstants.freeClientLimit,
        ),
      SubscriptionTier.silver => (
          l10n.subscriptionSilver,
          const Color(0xFF7B5EA7),
          AppConstants.silverMatchDailyLimit,
          AppConstants.silverClientLimit,
        ),
      SubscriptionTier.gold => (
          l10n.subscriptionGold,
          const Color(0xFFD4A017),
          AppConstants.goldMatchDailyLimit,
          AppConstants.goldClientLimit,
        ),
    };

    final used = usageAsync.valueOrNull ?? 0;
    final clientCount = clientCountAsync.valueOrNull ?? 0;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            planColor.withValues(alpha: 0.15),
            planColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: planColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: planColor, size: 28.r),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscriptionCurrentPlan,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    planName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: planColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Match usage bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: matchLimit > 0 ? (used / matchLimit).clamp(0.0, 1.0) : 0.0,
              backgroundColor: planColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(planColor),
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.subscriptionDailyUsage(used, matchLimit),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          // Client count
          Text(
            '${l10n.subscriptionClientLimit}: $clientCount/$clientLimit${l10n.profileDetailMatchRequestUnit}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackPlanCard extends StatelessWidget {
  const _FallbackPlanCard({required this.l10n, required this.theme});
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded,
              color: theme.colorScheme.outline, size: 28.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '${l10n.subscriptionFree} · ${l10n.subscriptionDailyUsage(0, AppConstants.freeMatchDailyLimit)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan Card ──────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.tier,
    required this.title,
    required this.desc,
    required this.matchLimit,
    required this.clientLimit,
    required this.color,
    required this.currentTier,
    required this.theme,
    required this.l10n,
    this.price,
    this.originalPrice,
    this.onUpgrade,
  });

  final SubscriptionTier tier;
  final String title;
  final String desc;
  final String matchLimit;
  final int clientLimit;
  final Color color;
  final SubscriptionTier currentTier;
  final ThemeData theme;
  final AppLocalizations l10n;
  final String? price;
  final String? originalPrice;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isCurrent = tier == currentTier;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isCurrent
            ? color.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isCurrent ? color : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    tier == SubscriptionTier.gold
                        ? Icons.diamond_rounded
                        : tier == SubscriptionTier.silver
                            ? Icons.star_rounded
                            : Icons.person_rounded,
                    color: color,
                    size: 22.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isCurrent ? color : null,
                            ),
                          ),
                          if (isCurrent) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                l10n.subscriptionCurrentPlan,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${l10n.subscriptionFeatureMatches}: $matchLimit · ${l10n.subscriptionClientLimit}: ${l10n.subscriptionClientLimitValue(clientLimit)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Price row for paid tiers
            if (price != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  SizedBox(width: 52.w), // align with text above
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      l10n.subscriptionLaunchPrice,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${price!}원/월',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (originalPrice != null)
                    Text(
                      '${originalPrice!}원',
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  const Spacer(),
                  if (!isCurrent && onUpgrade != null)
                    FilledButton(
                      onPressed: onUpgrade,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding:
                            EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        l10n.subscriptionChangePlan,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ] else ...[
              // Free tier — show upgrade button inline
              if (!isCurrent && onUpgrade != null) ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: onUpgrade,
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.subscriptionChangePlan,
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Dev Mode Tier Switcher ─────────────────────────────────────────────

class _DevModeTierSwitcher extends ConsumerWidget {
  const _DevModeTierSwitcher({required this.l10n, required this.theme});
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOverride = ref.watch(devSubscriptionTierOverrideProvider);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_mode, color: Colors.orange, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                l10n.subscriptionDevModeTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: [
              _DevTierChip(
                label: l10n.subscriptionFree,
                isSelected: currentOverride == SubscriptionTier.free,
                onTap: () {
                  ref.read(devSubscriptionTierOverrideProvider.notifier).state =
                      SubscriptionTier.free;
                },
              ),
              _DevTierChip(
                label: l10n.subscriptionSilver,
                isSelected: currentOverride == SubscriptionTier.silver,
                onTap: () {
                  ref.read(devSubscriptionTierOverrideProvider.notifier).state =
                      SubscriptionTier.silver;
                },
              ),
              _DevTierChip(
                label: l10n.subscriptionGold,
                isSelected: currentOverride == SubscriptionTier.gold,
                onTap: () {
                  ref.read(devSubscriptionTierOverrideProvider.notifier).state =
                      SubscriptionTier.gold;
                },
              ),
              _DevTierChip(
                label: 'Off',
                isSelected: currentOverride == null,
                onTap: () {
                  ref.read(devSubscriptionTierOverrideProvider.notifier).state =
                      null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DevTierChip extends StatelessWidget {
  const _DevTierChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.orange.withValues(alpha: 0.2),
      checkmarkColor: Colors.orange,
    );
  }
}
