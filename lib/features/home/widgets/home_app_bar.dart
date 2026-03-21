import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../providers/home_providers.dart';
import 'notification_bottom_sheet.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final unreadAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

    // Extract up to 2 characters for avatar (Korean names: last 2 chars)
    final avatarText = userName.length >= 2
        ? userName.substring(userName.length - 2)
        : (userName.isEmpty ? 'U' : userName);

    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 20.w, top: 16.h, bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // cup+ logo: "cup" in dark, "+" in pointColor
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: 'cup',
                  style: TextStyle(color: homeColors.textPrimary),
                ),
                TextSpan(
                  text: '+',
                  style: TextStyle(color: homeColors.pointColor),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Bell icon in circle with border
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.r)),
                    ),
                    builder: (_) => const NotificationBottomSheet(),
                  );
                },
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
                        Icons.notifications_outlined,
                        size: 22.r,
                        color: homeColors.textPrimary,
                      ),
                      if (unreadCount > 0)
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
              SizedBox(width: 10.w),
              // Gradient avatar
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFFe06848),
                            const Color(0xFFd4845a),
                          ]
                        : [
                            const Color(0xFFc8523a),
                            const Color(0xFFd48a5c),
                          ],
                  ),
                ),
                child: Center(
                  child: Text(
                    avatarText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
