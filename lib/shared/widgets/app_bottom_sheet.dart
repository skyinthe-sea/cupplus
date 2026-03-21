import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';

/// Unified bottom sheet wrapper with HomeColors design language.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
  });

  final String? title;
  final Widget child;

  /// Show a modal bottom sheet with the unified design.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool isScrollControlled = false,
  }) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: homeColors.cardColor,
      isScrollControlled: isScrollControlled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => AppBottomSheet(
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: homeColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            if (title != null) ...[
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  title!,
                  style: TextStyle(
                    fontFamily: serifFontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: homeColors.textPrimary,
                  ),
                ),
              ),
            ],
            SizedBox(height: 8.h),
            child,
          ],
        ),
      ),
    );
  }
}
