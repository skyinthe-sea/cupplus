import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';

class ChatListHeader extends StatelessWidget {
  const ChatListHeader({super.key, required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final headlineStyle = theme.textTheme.headlineMedium;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 16.h,
        bottom: 8.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line 1: "MESSAGES" uppercase label
          Text(
            l10n.chatListSectionLabel,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: 3.0,
              color: homeColors.textPrimary.withValues(alpha: 0.35),
            ),
          ),
          SizedBox(height: 6.h),
          // Line 2: Serif title
          Text(
            l10n.chatListHeadline,
            style: headlineStyle?.copyWith(
              fontFamily: serifFontFamily,
              fontWeight: FontWeight.w400,
              color: homeColors.textPrimary,
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(height: 4.h),
            Text(
              l10n.chatListUnreadCount(unreadCount),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: homeColors.pointColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
