import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;

    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 28.h, bottom: 10.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 3.0,
          color: homeColors.textPrimary.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
