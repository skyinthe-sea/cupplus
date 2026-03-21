import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
  });

  final String userName;

  String _getTimeGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return l10n.homeGreetingTimeMorning;
    if (hour >= 12 && hour < 18) return l10n.homeGreetingTimeAfternoon;
    if (hour >= 18 && hour < 22) return l10n.homeGreetingTimeEvening;
    return l10n.homeGreetingTimeNight;
  }

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
        top: 8.h,
        bottom: 12.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line 1: "GOOD MORNING"
          Text(
            _getTimeGreeting(l10n),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: 3.0,
              color: homeColors.textPrimary.withValues(alpha: 0.35),
            ),
          ),
          SizedBox(height: 6.h),
          // Line 2-3: Serif "안녕하세요," + name (bold italic coral) + " 매니저님"
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${l10n.homeGreetingHello}\n',
                  style: headlineStyle?.copyWith(
                    fontFamily: serifFontFamily,
                    fontWeight: FontWeight.w400,
                    color: homeColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: userName,
                  style: headlineStyle?.copyWith(
                    fontFamily: serifFontFamily,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: homeColors.pointColor,
                  ),
                ),
                TextSpan(
                  text: ' ${l10n.homeGreetingSuffix}',
                  style: headlineStyle?.copyWith(
                    fontFamily: serifFontFamily,
                    fontWeight: FontWeight.w400,
                    color: homeColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
