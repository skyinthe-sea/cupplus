import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/marketplace_profile.dart';
import '../providers/marketplace_providers.dart';

class MarketplaceProfileCard extends ConsumerStatefulWidget {
  const MarketplaceProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
    this.isDimmed = false,
  });

  final MarketplaceProfile profile;
  final VoidCallback onTap;
  final bool isDimmed;

  @override
  ConsumerState<MarketplaceProfileCard> createState() =>
      _MarketplaceProfileCardState();
}

class _MarketplaceProfileCardState
    extends ConsumerState<MarketplaceProfileCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

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

  void _onLikeTap() {
    ref.read(
      toggleLikeProvider(
        widget.profile.id,
        currentlyLiked: widget.profile.isLiked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColors = theme.extension<StatusColors>()!;
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainer
                            .withValues(alpha: 0.55)
                        : theme.colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.45),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Avatar + Name/Info
                      Row(
                        children: [
                          Hero(
                            tag: 'marketplace_avatar_${p.id}',
                            child: CircleAvatar(
                              radius: 28.r,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              child: Text(
                                p.fullName.isNotEmpty ? p.fullName[0] : '?',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        p.fullName,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (p.isVerified) ...[
                                      SizedBox(width: 4.w),
                                      Container(
                                        padding: EdgeInsets.all(1.5.r),
                                        decoration: BoxDecoration(
                                          color: statusColors.verified
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.verified_rounded,
                                          size: 14.r,
                                          color: statusColors.verified,
                                        ),
                                      ),
                                    ],
                                    SizedBox(width: 6.w),
                                    Text(
                                      '${l10n.homeAgeSuffix(p.age)} · ${p.gender == "M" ? l10n.homeGenderMale : l10n.homeGenderFemale}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  p.company != null
                                      ? '${p.occupation} · ${p.company}'
                                      : p.occupation,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (p.education != null) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    p.education!,
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
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
                      ),

                      SizedBox(height: 12.h),

                      // Hobbies + Region row
                      Row(
                        children: [
                          if (p.regionName != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                p.regionName!,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Expanded(
                            child: Wrap(
                              spacing: 4.w,
                              runSpacing: 2.h,
                              children: p.hobbies.take(3).map((hobby) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHigh
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    hobby,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // Bottom row: date + like button
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12.r,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(p.registeredAt ?? DateTime.now()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                              fontSize: 10.sp,
                            ),
                          ),
                          const Spacer(),
                          // Like count
                          if (p.likeCount > 0) ...[
                            Text(
                              '${p.likeCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.tertiary
                                    .withValues(alpha: 0.7),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 3.w),
                          ],
                          // Heart toggle button
                          GestureDetector(
                            onTap: () {
                              // Stop event propagation to card tap
                              _onLikeTap();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                p.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18.r,
                                color: p.isLiked
                                    ? const Color(0xFFB4637A)
                                    : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),

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
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            l10n.marketplaceMatchCompleted,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.colorScheme.onSurfaceVariant,
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
        ),
      ),
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
