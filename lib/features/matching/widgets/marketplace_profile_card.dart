import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/client_summary.dart';
import '../models/marketplace_profile.dart';
import '../providers/marketplace_providers.dart';
import 'client_selection_sheet.dart';

class MarketplaceProfileCard extends ConsumerStatefulWidget {
  const MarketplaceProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
    this.isDimmed = false,
    this.heroTagPrefix = 'all',
  });

  final MarketplaceProfile profile;
  final VoidCallback onTap;
  final bool isDimmed;
  final String heroTagPrefix;

  @override
  ConsumerState<MarketplaceProfileCard> createState() =>
      _MarketplaceProfileCardState();
}

class _MarketplaceProfileCardState
    extends ConsumerState<MarketplaceProfileCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  bool _isLikeLoading = false;
  bool _isMatchLoading = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _onLikeTap() async {
    if (_isLikeLoading) return;
    setState(() => _isLikeLoading = true);
    try {
      final provider = toggleLikeProvider(
        widget.profile.id,
        currentlyLiked: widget.profile.isLiked,
      );
      ref.read(provider);
      await ref.read(provider.future);
    } catch (_) {
      // Provider handles error state
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _onMatchTap() async {
    if (_isMatchLoading) return;

    final l10n = AppLocalizations.of(context)!;
    final p = widget.profile;

    setState(() => _isMatchLoading = true);

    try {
      final clients = await ref.read(
        myEligibleClientsProvider(p.gender).future,
      );

      if (!mounted) return;

      if (clients.isEmpty) {
        await _showInfoDialog(l10n.matchRequestNoEligible);
        return;
      }

      if (clients.length == 1) {
        await _showConfirmDialog(clients.first, p);
      } else {
        final selected = await ClientSelectionSheet.show(context, clients);
        if (selected != null && mounted) {
          await _showConfirmDialog(selected, p);
        }
      }
    } finally {
      if (mounted) setState(() => _isMatchLoading = false);
    }
  }

  Future<void> _showInfoDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.commonConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmDialog(ClientSummary myClient, MarketplaceProfile target) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileDetailMatchRequestTitle),
        content: Text(
          l10n.matchRequestConfirmMessage(myClient.fullName, target.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _executeMatch(myClient, target);
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _executeMatch(
      ClientSummary myClient, MarketplaceProfile target) async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() => _isMatchLoading = true);

    try {
      final error = await ref.read(
        createMatchProvider(
          clientAId: myClient.id,
          clientBId: target.id,
        ).future,
      );

      if (!mounted) return;

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.matchRequestSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (error == 'daily_limit') {
        _showInfoDialog(l10n.matchRequestDailyLimit);
      } else if (error == 'unverified') {
        _showVerificationDialog(l10n, isUnverified: true);
      } else if (error == 'pending') {
        _showVerificationDialog(l10n, isUnverified: false);
      } else {
        _showInfoDialog(error);
      }
    } finally {
      if (mounted) setState(() => _isMatchLoading = false);
    }
  }

  void _showVerificationDialog(AppLocalizations l10n,
      {required bool isUnverified}) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          isUnverified
              ? Icons.verified_user_outlined
              : Icons.hourglass_top_rounded,
          size: 40,
          color: isUnverified
              ? theme.colorScheme.primary
              : Colors.amber.shade700,
        ),
        title: Text(
          isUnverified
              ? l10n.matchRequestVerificationRequired
              : l10n.matchRequestVerificationPendingTitle,
        ),
        content: Text(
          isUnverified
              ? l10n.matchRequestVerificationRequiredDesc
              : l10n.matchRequestVerificationPending,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (isUnverified) ...[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.verification);
              },
              child: Text(l10n.matchRequestVerify),
            ),
          ] else
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonConfirm),
            ),
        ],
      ),
    );
  }

  bool get _isNew {
    final registeredAt = widget.profile.registeredAt;
    if (registeredAt == null) return false;
    return DateTime.now().difference(registeredAt).inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final p = widget.profile;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: widget.isDimmed ? 0.5 : 1.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: homeColors.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: homeColors.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Avatar + Identity
                  _buildIdentitySection(theme, homeColors, l10n, p),

                  // Section 2: Divider
                  if (p.hobbies.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Divider(color: homeColors.borderColor, height: 1),
                    SizedBox(height: 12.h),
                    // Section 3: Hobby badges
                    _buildHobbyBadges(homeColors, p),
                  ],

                  SizedBox(height: 12.h),

                  // Section 4: Bottom action row
                  _buildBottomRow(theme, homeColors, l10n, p),

                  // Matched tag for likes tab
                  if (widget.isDimmed &&
                      p.clientStatus != null &&
                      p.clientStatus != 'active') ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: homeColors.textPrimary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        l10n.marketplaceMatchCompleted,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: homeColors.textPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySection(
    ThemeData theme,
    HomeColors homeColors,
    AppLocalizations l10n,
    MarketplaceProfile p,
  ) {
    const dustyRose = Color(0xFFB4637A);
    final genderColor = p.gender == 'F' ? dustyRose : homeColors.pointColor;
    final genderLabel =
        p.gender == 'F' ? l10n.homeGenderFemale : l10n.homeGenderMale;

    return Row(
      children: [
        // Avatar with gender badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Hero(
              tag: 'marketplace_avatar_${widget.heroTagPrefix}_${p.id}',
              child: CircleAvatar(
                radius: 32.r,
                backgroundColor:
                    homeColors.textPrimary.withValues(alpha: 0.08),
                child: Text(
                  p.fullName.isNotEmpty ? p.fullName[0] : '?',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: homeColors.textPrimary,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -2.r,
              bottom: -2.r,
              child: Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  color: genderColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: homeColors.cardColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    genderLabel,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Age + NEW badge
              Row(
                children: [
                  Flexible(
                    child: Text(
                      p.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: homeColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.homeAgeSuffix(p.age),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: homeColors.textPrimary.withValues(alpha: 0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                  if (_isNew) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: homeColors.pointColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        l10n.marketplaceNewBadge,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 3.h),
              // Occupation · Company
              Text(
                p.occupation.isNotEmpty && p.company != null
                    ? '${p.occupation} · ${p.company}'
                    : p.occupation.isNotEmpty
                        ? p.occupation
                        : p.company ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: homeColors.textPrimary.withValues(alpha: 0.55),
                  fontSize: 12.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Education
              if (p.education != null) ...[
                SizedBox(height: 2.h),
                Text(
                  p.education!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: homeColors.textPrimary.withValues(alpha: 0.4),
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHobbyBadges(HomeColors homeColors, MarketplaceProfile p) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: p.hobbies.take(5).map((hobby) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: homeColors.pointColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            hobby,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: homeColors.pointColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(
    ThemeData theme,
    HomeColors homeColors,
    AppLocalizations l10n,
    MarketplaceProfile p,
  ) {
    return Row(
      children: [
        // Calendar + relative date
        Icon(
          Icons.calendar_today_rounded,
          size: 12.r,
          color: homeColors.textPrimary.withValues(alpha: 0.4),
        ),
        SizedBox(width: 4.w),
        Text(
          _formatDate(p.registeredAt ?? DateTime.now()),
          style: theme.textTheme.bodySmall?.copyWith(
            color: homeColors.textPrimary.withValues(alpha: 0.4),
            fontSize: 10.sp,
          ),
        ),
        const Spacer(),
        // Heart button
        GestureDetector(
          onTap: _onLikeTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.isLiked
                  ? homeColors.pointColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(color: homeColors.borderColor, width: 1),
            ),
            child: Icon(
              p.isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 16.r,
              color: p.isLiked
                  ? homeColors.pointColor
                  : homeColors.textPrimary.withValues(alpha: 0.4),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // "매칭하기" CTA pill
        GestureDetector(
          onTap: _onMatchTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: homeColors.ctaBar,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: _isMatchLoading
                ? SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded,
                          size: 14.r, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        l10n.marketplaceMatchButton,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      if (diff.inHours < 1) return l10n.chatJustNow;
      return l10n.chatHoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return l10n.chatDaysAgo(diff.inDays);
    } else {
      return l10n.chatDateFormat(date.month, date.day);
    }
  }
}
