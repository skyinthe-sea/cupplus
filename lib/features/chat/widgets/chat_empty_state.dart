import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/widgets/illustration_placeholder.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IllustrationImage(
              assetPath: 'assets/images/illustrations/empty_chat.png',
              width: 80.r,
              height: 80.r,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.chatEmptyTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: serifFontFamily,
                fontWeight: FontWeight.w600,
                color: homeColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.chatEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
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
