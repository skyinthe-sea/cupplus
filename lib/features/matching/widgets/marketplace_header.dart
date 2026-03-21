import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';

class MarketplaceHeader extends StatelessWidget {
  const MarketplaceHeader({
    super.key,
    required this.totalCount,
    required this.activeFilterCount,
    required this.onFilterTap,
  });

  final int totalCount;
  final int activeFilterCount;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final headlineStyle = theme.textTheme.headlineMedium;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 20.w,
        top: 16.h,
        bottom: 8.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: "PROFILE MARKET"
                Text(
                  l10n.marketplaceHeaderLabel,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 3.0,
                    color: homeColors.textPrimary.withValues(alpha: 0.35),
                  ),
                ),
                SizedBox(height: 6.h),
                // Line 2: Serif "프로필" + " " + "마켓" (bold italic coral)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.marketplaceHeaderSerif1,
                        style: headlineStyle?.copyWith(
                          fontFamily: serifFontFamily,
                          fontWeight: FontWeight.w400,
                          color: homeColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: l10n.marketplaceHeaderSerif2,
                        style: headlineStyle?.copyWith(
                          fontFamily: serifFontFamily,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: homeColors.pointColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                // Line 3: total count
                Text(
                  l10n.marketplaceTotalCount(totalCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: homeColors.textPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Filter icon in bordered circle
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: GestureDetector(
              onTap: onFilterTap,
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: homeColors.cardColor,
                  border: Border.all(
                    color: homeColors.borderColor,
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 22.r,
                      color: homeColors.textPrimary,
                    ),
                    if (activeFilterCount > 0)
                      Positioned(
                        right: 10.r,
                        top: 10.r,
                        child: Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: BoxDecoration(
                            color: homeColors.pointColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: homeColors.cardColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
