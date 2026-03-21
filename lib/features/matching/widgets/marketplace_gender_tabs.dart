import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';

class MarketplaceGenderTabs extends StatelessWidget {
  const MarketplaceGenderTabs({
    super.key,
    required this.controller,
    required this.allCount,
    required this.femaleCount,
    required this.maleCount,
    required this.likesCount,
  });

  final TabController controller;
  final int allCount;
  final int femaleCount;
  final int maleCount;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final activeIndex = controller.animation?.value.round() ?? controller.index;
          return Row(
            children: [
              _PillTab(
                label: '${l10n.commonAll} $allCount',
                isActive: activeIndex == 0,
                onTap: () => controller.animateTo(0),
              ),
              SizedBox(width: 8.w),
              _PillTab(
                label: '${l10n.commonFemale} $femaleCount',
                isActive: activeIndex == 1,
                onTap: () => controller.animateTo(1),
              ),
              SizedBox(width: 8.w),
              _PillTab(
                label: '${l10n.commonMale} $maleCount',
                isActive: activeIndex == 2,
                onTap: () => controller.animateTo(2),
              ),
              SizedBox(width: 8.w),
              _PillTab(
                icon: Icons.favorite_rounded,
                isActive: activeIndex == 3,
                onTap: () => controller.animateTo(3),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String? label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    const dustyRose = Color(0xFFB4637A);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? 12.w : 14.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isActive ? homeColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: isActive
              ? null
              : Border.all(color: homeColors.borderColor, width: 1),
        ),
        child: icon != null
            ? Icon(
                icon,
                size: 16.r,
                color: isActive ? homeColors.cardColor : dustyRose,
              )
            : Text(
                label!,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? homeColors.cardColor
                      : homeColors.textPrimary,
                ),
              ),
      ),
    );
  }
}
