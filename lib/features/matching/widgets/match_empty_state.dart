import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../home/widgets/illustration_placeholder.dart';

class MatchEmptyState extends StatelessWidget {
  const MatchEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IllustrationImage(
              assetPath: 'assets/images/illustrations/empty_matches.png',
              width: 80.r,
              height: 80.r,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: serifFontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: homeColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: homeColors.textPrimary.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
