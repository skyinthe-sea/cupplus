import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'illustration_placeholder.dart';

class PendingMatchCard extends StatefulWidget {
  const PendingMatchCard({
    super.key,
    required this.pendingCount,
    required this.onTap,
  });

  final int pendingCount;
  final VoidCallback onTap;

  @override
  State<PendingMatchCard> createState() => _PendingMatchCardState();
}

class _PendingMatchCardState extends State<PendingMatchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final statusColors = theme.extension<StatusColors>()!;
    final hasPending = widget.pendingCount > 0;

    // Content built once, not affected by animation
    final content = Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 16.w, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPending) ...[
                      Row(
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: statusColors.accepted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: homeColors.pointColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              l10n.homePendingMatchBadge,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.homePendingMatchTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: serifFontFamily,
                          color: homeColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n.homePendingMatchSubtitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: serifFontFamily,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: homeColors.pointColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10n.homePendingMatchDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: homeColors.textPrimary.withValues(alpha: 0.6),
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 4.h),
                      Text(
                        l10n.homeNoMatchTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: serifFontFamily,
                          fontWeight: FontWeight.w700,
                          color: homeColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10n.homeNoMatchDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: homeColors.textPrimary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Illustration — clipped to show upper portion of tall image
              SizedBox(
                width: 140.r,
                height: 120.r,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: const Alignment(0, -0.6),
                    maxHeight: 220.r,
                    child: IllustrationImage(
                      assetPath: hasPending
                          ? 'assets/images/illustrations/home_pending_match.png'
                          : 'assets/images/illustrations/home_searching_match.png',
                      width: 140.r,
                      height: 220.r,
                      darkOpacity: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
          color: homeColors.ctaBar,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasPending
                      ? l10n.homePendingMatchCta(widget.pendingCount)
                      : l10n.homeNoMatchCta,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.r,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Subtle shift: begin drifts between topLeft and topCenter,
            // end drifts between bottomRight and bottomCenter.
            // Range is only 0.15 alignment units — barely perceptible.
            final t = _controller.value;
            final begin = Alignment(-1.0 + 0.5 * t, -1.0 + 0.3 * t);
            final end = Alignment(1.0 - 0.5 * t, 1.0 - 0.3 * t);

            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: begin,
                  end: end,
                  colors: [
                    homeColors.pendingCardBg,
                    homeColors.pendingCardBgEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: child,
            );
          },
          child: RepaintBoundary(child: content),
        ),
      ),
    );
  }
}
