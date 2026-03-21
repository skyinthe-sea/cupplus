import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'illustration_placeholder.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onRegisterClient,
    required this.onCreateMatch,
    this.onSchedule,
  });

  final VoidCallback onRegisterClient;
  final VoidCallback onCreateMatch;
  final VoidCallback? onSchedule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;

    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 24.h, bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Text(
              l10n.homeQuickActionsTitle,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: homeColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(
            height: 170.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: EdgeInsets.only(right: 20.w),
              children: [
                _QuickActionCard(
                  title: l10n.homeQuickMatch,
                  tag: l10n.homeQuickMatchTag,
                  onTap: onCreateMatch,
                  homeColors: homeColors,
                  assetPath: 'assets/images/illustrations/home_quick_match.png',
                ),
                SizedBox(width: 10.w),
                _QuickActionCard(
                  title: l10n.homeQuickRegister,
                  tag: l10n.homeQuickRegisterTag,
                  onTap: onRegisterClient,
                  homeColors: homeColors,
                  assetPath: 'assets/images/illustrations/home_quick_register.png',
                ),
                SizedBox(width: 10.w),
                _QuickActionCard(
                  title: l10n.homeQuickScheduleTitle,
                  tag: l10n.homeQuickScheduleTag,
                  onTap: onSchedule ?? () {},
                  homeColors: homeColors,
                  assetPath: 'assets/images/illustrations/home_quick_schedule.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.tag,
    required this.onTap,
    required this.homeColors,
    required this.assetPath,
  });

  final String title;
  final String tag;
  final VoidCallback onTap;
  final HomeColors homeColors;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    Widget illustration = IllustrationImage(assetPath: assetPath, width: 80.r, height: 80.r);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        padding: EdgeInsets.only(
          left: 16.r,
          right: 12.r,
          top: 16.r,
          bottom: 2.r,
        ),
        decoration: BoxDecoration(
          color: homeColors.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: homeColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: homeColors.textPrimary,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: homeColors.pointColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: homeColors.pointColor,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.bottomRight,
              child: illustration,
            ),
          ],
        ),
      ),
    );
  }
}
